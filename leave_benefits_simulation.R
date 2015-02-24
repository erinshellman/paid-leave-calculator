require(ggplot2)
require(shiny)
require(shinythemes)
require(reshape2)
require(scales)
require(dplyr)
set.seed(1)

compute_replacement_cost = function(salary, replacement_settings) {

  cost =
    replacement_settings['posting_costs'] +
    replacement_settings['interview_costs'] +
    replacement_settings['reference_check'] +
    replacement_settings['relocation'] +
    replacement_settings['training'] +
    replacement_settings['losses'] +
    replacement_settings['consulting_fees'] +
    replacement_settings['overtime_expense'] +
    (salary * 0.33)*replacement_settings['ext_rec_fee'] + # external recruiting fees
    (salary * 0.1)*replacement_settings['salary_increase'] + # salary increase (salary * 10%)
    ((salary * 1.1) * 0.05)*replacement_settings['signon_bonus'] # sign on bonus (increased salary * 5%)

  return(cost)

}

compute_cost_of_leave = function(days_of_absence, salary, percent_of_salary) {

  # The 1.2 scalar is to account for employee overhead costs like 401K matching,
  # health insurance, and other perks that are distinct from salary.
  cost = (((salary * 1.2) / 365) * percent_of_salary) * days_of_absence

  return(cost)

}

simulate_costs = function (days_of_absence, salary_mean,
                           percent_of_salary, num_employees_on_leave,
                           replacement_settings) {

  # Construct the salary space
  sd = salary_mean * 0.25
  n_range = seq(ifelse(num_employees_on_leave - 20 <= 0, 1, num_employees_on_leave - 20), num_employees_on_leave + 20, 5)
  out = data.frame()

  for (n in n_range) {

    salaries = round(rnorm(n = n, mean = salary_mean, sd = sd), 2)

    replacement_costs = data.frame()
    attrited = 0
    while(sum(attrited) == 0) { # make sure there's at least one attrition event

      attrited = rbinom(n = n, size = 1, prob = 0.33)

      replacement_costs = data.frame(salaries = salaries,
                                     attrited = attrited,
                                     cost_of_replacement = compute_replacement_cost(salaries, replacement_settings),
                                     cost_of_benefits = compute_cost_of_leave(days_of_absence, salaries, percent_of_salary),
                                     condition = 'before')
    }

    attrited_indices = which(replacement_costs$attrited == 1)

    # Store the costs of benies!
    benefits_costs = replacement_costs

    index_samples = sample(attrited_indices, size = ceiling(0.5 * length(attrited_indices)))
    benefits_costs[index_samples, ]$attrited = 0
    benefits_costs$condition = 'after'

    costs = rbind(replacement_costs, benefits_costs)
    melted_costs = melt(costs,
                        id.vars = c('condition', 'attrited', 'salaries'),
                        measure.vars = c('cost_of_replacement', 'cost_of_benefits'))

    aggregated_costs = melted_costs %>%
      group_by(attrited, variable, condition) %>%
      summarize(num_of_people = n(), total_cost = sum(value))

    before = filter(aggregated_costs, variable == 'cost_of_replacement' &
                      condition == 'before' &
                      attrited == 1)$total_cost
    after = sum(filter(aggregated_costs, variable == 'cost_of_benefits' & condition == 'after' & attrited == 0)$total_cost, # people retained with benefits
                filter(aggregated_costs, variable == 'cost_of_replacement' & condition == 'after' & attrited == 1)$total_cost,
                filter(aggregated_costs, variable == 'cost_of_benefits' & condition == 'after' & attrited == 1)$total_cost
    )

  out = rbind(out, c(n, before, after))

  }

  colnames(out) = c('n', 'before', 'after')
  out = melt(out, id.vars = 'n', variable.name = 'condition', value.name = 'cost')
  return(out)

}

# test calls
run_test = function () {
  simulate_costs(days_of_absence = 90,
                 salary_mean = 100000,
                 percent_of_salary = 40,
                 num_employees_on_leave = 50,
                 replacement_settings = c(posting_costs = 1600,
                                          interview_costs = 4200,
                                          reference_check = 1000,
                                          relocation = 5000,
                                          training = 7000,
                                          losses = 77000,
                                          consulting_fees = 18000,
                                          overtime_expense = 5500))
}

# test_output = run_test()