library(shiny)
library(rmarkdown)

fluidPage(
  tags$style(HTML("
    body {
      font-family: 'Palatino Linotype', 'Book Antiqua', Palatino, serif;
    }
    
    .shiny-html-output {
      font-size: 1.15em;
    }
  ")),
  
  titlePanel("🥂 White Wine Quality Estimator 🥂"),
  
  fluidRow(
    column(
      4,
      helpText(
        "Want to estimate what the predicted quality of your white wine is based on a particular regression model?
Start by selecting a regression model, enter your predictor variable(s), then the value of the variable to render the model and the estimated value based on the data.
"
      ),
      hr(),
      selectInput(
        inputId = 'regression',
        label = 'Regression Model Type',
        choices = regressionChoices,
        selected = regressionChoices[[1]]
      ),
      conditionalPanel(
        condition = "input.regression == 'lm_simple'",
        selectInput('xcol', 'Select Predictor (X) Variable', var_choices),
        numericInput(
          'x_value',
          'Enter X Variable Value',
          value = 0,
          min = 0,
          step = 0.1
        )
      ),
      
      conditionalPanel(
        condition = "input.regression == 'lm_multiple'",
        selectInput(
          'm_xcols',
          'Select Predictor (X) Variables',
          var_choices,
          multiple = TRUE
        ),
        uiOutput('m_xvalues'),
      )
    ),
    
    column(8, plotOutput('plot1'))
  ),
  
  fluidRow(column(
    12,
    hr(),
    h3("Estimated Wine Quality:"),
    verbatimTextOutput('prediction_output')
  )),
  
  uiOutput('markdown')
)