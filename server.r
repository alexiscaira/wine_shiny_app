library(shiny)

function(input, output, session) {
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
}