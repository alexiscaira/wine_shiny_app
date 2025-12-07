library(splitTools)
library(ggplot2)
library(knitr)
library(rmarkdown)

function(input, output, session) {
  set.seed(42)
  
  indices <- partition(
    y = wine_data$quality,
    p = c(train = 0.8, test = 0.2),
    type = "stratified"
  )
  
  train_data <- wine_data[indices$train, ]
  test_data <- wine_data[indices$test, ]
  
  get_display_name <- function(raw_name) {
    name_index <- which(var_choices == raw_name)
    if (length(name_index) > 0) {
      return(names(var_choices)[name_index[1]])
    }
    return(raw_name)
  }
  
  output$m_xvalues <- renderUI({
    if (is.null(input$m_xcols) || length(input$m_xcols) == 0) {
      return(helpText(
        "Select one or more predictor variables above to enter their values."
      ))
    }
    
    tagList(lapply(input$m_xcols, function(var_name) {
      display_name <- get_display_name(var_name)
      
      inputId <- paste0("val_", var_name)
      
      numericInput(
        inputId = inputId,
        label = paste("Enter Value for:", display_name),
        value = 0,
        min = 0,
        step = 0.1
      )
    }))
  })
  
  wine_model <- reactive({
    req(train_data)
    
    if (input$regression == "lm_simple") {
      formula_str <- paste("quality ~", input$xcol)
      lm(formula_str, data = train_data)
      
    } else if (input$regression == "lm_multiple") {
      req(input$m_xcols)
      formula_str <- paste("quality ~", paste(input$m_xcols, collapse = " + "))
      lm(formula_str, data = train_data)
    }
  })
  
  user_input_data <- reactive({
    if (input$regression == "lm_simple") {
      req(input$xcol, input$x_value)
      df <- data.frame('value' = input$x_value,
                       stringsAsFactors = FALSE)
      names(df) <- input$xcol
      return(df)
      
    } else if (input$regression == "lm_multiple") {
      req(input$m_xcols)
      
      values_list <- list()
      for (col_name in input$m_xcols) {
        input_id <- paste0("val_", col_name)
        req(input[[input_id]])
        values_list[[col_name]] <- input[[input_id]]
      }
      return(as.data.frame(values_list))
    }
  })
  
  output$plot1 <- renderPlot({
    if (input$regression == "lm_simple") {
      req(input$xcol, input$x_value, wine_data, wine_model)
      
      x_var <- input$xcol
      y_var <- "quality"
      prediction <- predict(wine_model(), user_input_data())
      x_label <- get_display_name(x_var)
      
      ggplot(train_data, aes_string(x = x_var, y = y_var)) +
        geom_point(color = "#889696", size = 2) +
        geom_smooth(
          method = "lm",
          se = FALSE,
          color = "#D2D4C8",
          linewidth = 1
        ) +
        geom_point(
          data = user_input_data(),
          aes_string(x = x_var, y = prediction),
          color = "#5F7470",
          size = 4,
          shape = 18
        ) +
        labs(
          title = paste(
            "Simple Linear Regression (Trained on 80% Data): Quality vs.",
            x_label
          ),
          x = x_label,
          y = "Quality"
        ) +
        theme_minimal()
      
    } else {
      plot.new()
      text(0.5,
           0.5,
           "Select linear regression to view plots, or view the estimate below.",
           cex = 1.2)
      return()
    }
  })
  
  output$prediction_output <- renderText({
    prediction <- predict(wine_model(), user_input_data())
    paste("Predicted Quality:", round(prediction, 2))
  })
  
  output$markdown <- renderUI({
    HTML(markdown::markdownToHTML(knit('report.rmd', quiet = TRUE)))
  })
}