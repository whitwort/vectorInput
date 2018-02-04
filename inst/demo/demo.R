#' @import shiny
library(shiny)

ui <- fluidPage( titlePanel("Widget Demo")
               , fluidRow(column( 12
                                , vectorInput( inputId    = 'namedVector'
                                             , type       = 'text'
                                             , nameLabel  = 'Name'
                                             , valueLabel = 'Value'
                                             )
                                )
                         )
               , fluidRow(column( 12
                                , verbatimTextOutput('namedVectorOutput')
                                )
                         )
               , fluidRow(column( 3
                                , actionButton('setNamed', "Set values")
                                )
                         )
               , fluidRow(column( 12
                                , vectorInput( inputId    = 'unnamedVector'
                                             , type       = 'text'
                                             , nameLabel  = NA
                                             , valueLabel = 'Value'
                                             )
                                )
                         )
               , fluidRow(column( 12
                                , verbatimTextOutput('unnamedVectorOutput')
                                )
                         )
               , fluidRow(column( 3
                                , actionButton('setUnnamed', "Set values")
                                )
                         )
               )

server <- function(input, output, session) {
  output$namedVectorOutput <- renderPrint({
    input$namedVector
  })
  output$unnamedVectorOutput <- renderPrint({
    input$unnamedVector
  })
  observeEvent(input$setNamed, {
    updateVectorInput(session, 'namedVector', c(a = "A", b = "B", c = "C"))
  })
  observeEvent(input$setUnnamed, {
    updateVectorInput(session, 'unnamedVector', c("A", "B", "C"))
  })
}

shinyApp(ui, server)
