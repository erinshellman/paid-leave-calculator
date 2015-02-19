require(shiny)
set.seed(1)

shinyServer(

  function(input, output) {

    simulation_results = reactive({
      # Source in the simulation functions
      source('leave_benefits_simulation.R') # load up the code for the simulations

      replacement_settings = c(posting_costs = input$posting_costs,
                               interview_costs = input$interview_costs,
                               reference_check = input$reference_check,
                               relocation = input$relocation,
                               training = input$training,
                               losses = input$losses,
                               consulting_fees = input$consulting_fees,
                               overtime_expense = input$overtime_expense,
                               ext_rec_fee = input$ext_rec_fee,
                               signon_bonus = input$signon_bonus,
                               salary_increase = input$salary_increase)

      # run the simulation and plot the results
      out = list()
      for (i in 1:30) {

        out[[i]] = simulate_costs(input$days_of_absence, input$salary_mean,
                     (input$percent_of_salary / 100), input$num_employees_on_leave, replacement_settings)

      }

      plyr::rbind.fill(out) %>% group_by(n, condition) %>% summarize(cost = mean(cost))

    })

    output$cost_plot = renderPlot({

      ggplot(simulation_results(), aes(x = n, y = cost, group = factor(condition), color = factor(condition))) +
        geom_line(size = 3) +
        geom_vline(xintercept = input$num_employees_on_leave, color = "#E74C3C", linetype = 2) +
        theme_minimal() +
        scale_y_continuous("Cost", labels = dollar) +
        scale_x_continuous("Number of Employees on Leave") +
        scale_colour_manual("", breaks = c("before", "after"), labels = c('No paid leave', 'Paid leave'), values = c("#3498DB","#F39C12")) +
        theme(
          text = element_text(family = 'Lato', color = 'darkslategray'),
          plot.title = element_text(lineheight = 0.8, face = "bold", size = 25),
          axis.text.x = element_text(size = 20),
          axis.text.y = element_text(size = 20),
          axis.title.x = element_text(size = 30, vjust = -1),
          axis.title.y = element_text(size = 30, vjust = 1),
          legend.position = "top",
          axis.text.x = element_text(angle = 90, hjust = 1),
          legend.text = element_text(size = 20))

    })
  }
)