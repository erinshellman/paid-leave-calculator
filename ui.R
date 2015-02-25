require(ggplot2)
require(shiny)
require(shinyapps)
require(shinythemes)
require(reshape2)
require(scales)
require(markdown)

# Define UI for application that plots random distributions
shinyUI(
  navbarPage("family leave calculator",

             # About
             #tabPanel("about", fluidRow(column(9, includeMarkdown("about.md")))),
             tabPanel("about", fluidRow(tags$h1("Computing the cost of leave programs"),
                                        column(12, align = 'center', img(src = "images/example_scenario.png", width = "65%")),
                                        column(12, align = 'center', includeMarkdown("about.md")))),

             # Calculator
             tabPanel("calculator", #icon("sliders", class = NULL, lib = "font-awesome"),
                      # Application title
                      tags$h1("How much does paid leave cost?"),
                      hr(),

                      fluidRow(
                        column(5,
                               align = 'center', includeMarkdown("calculator.md")
                        ),
                        column(7,
                               plotOutput("cost_plot", height = "600px")
                        )
                      ),

                      fluidRow(
                        column(3, tags$h4("Configure workforce")),
                        column(3, tags$h4("Configure replacement costs")),
                        column(3, tags$h4("")),
                        column(3, tags$h4("Configure leave program"))
                      ),

                      wellPanel(
                        fluidRow(
                          column(3,
                                 sliderInput("salary_mean", "Mean employee salary ($USD):", min = 10000, max = 300000, value = 100000, step = 5000),
                                 sliderInput("num_employees_on_leave", "Number of employees taking family leave:", min = 0, max = 100, value = 10),
                                 sliderInput("attrition_rate", "Attrition rate (% of employees not returning):", min = 0, max = 100, value = 33)
                          ),
                          # Replacement costs configuration
                          column(3,
                                 sliderInput("posting_costs", "Creation and management of job posting:", min = 0, max = 3000, value = 1600, step = 10),
                                 sliderInput("interview_costs", "Interviewing costs (7 candidates x 3hrs ea x $100/hr):", min = 0, max = 4200, value = 2100, step = 10),
                                 sliderInput("reference_check", "Pre-employment testing/reference check:", min = 0, max = 4000, value = 1000, step = 50),
                                 sliderInput("relocation", "Relocation costs:", min = 0, max = 10000, value = 5000, step = 100)
                          ),
                          column(3,
                                 sliderInput("training", "New employee training:", min = 0, max = 10000, value = 7000, step = 100),
                                 sliderInput("losses", "Institutional losses:", min = 0, max = 100000, value = 77000, step = 1000),
                                 sliderInput("consulting_fees", "Consulting fees:", min = 0, max = 50000, value = 18000, step = 1000),
                                 sliderInput("overtime_expense", "Overtime expense:", min = 0, max = 10000, value = 5500, step = 100),
                                 h5("External recruiting fees:"), checkboxInput("external_recruiter_fee", "33% of salary", TRUE),
                                 h5("Salary increase:"), checkboxInput("salary_increase", "1% of salary", TRUE),
                                 h5("Sign-on bonus:"), checkboxInput("signon_bonus", "5% of increased salary", TRUE)
                          ),
                          # Leave program configuration
                          column(3,
                                 sliderInput("days_of_absence", "Days of leave offered:", min = 90, max = 365, value = 90, step = 10),
                                 sliderInput("percent_of_salary", "Percent of salary:", min = 0, max = 100, value = 60)
                          )
                        )
                      )),

             # Set the theme
             theme = shinytheme("flatly"),
             tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
))