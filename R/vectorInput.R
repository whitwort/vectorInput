#' @import shiny
#' @import htmltools
NULL
library(shiny)
library(htmltools)

templatePath <- system.file("templates", package = "vectorInput")
wwwPath      <- system.file("www", package = "vectorInput")

#' vectorInput
#'
#' A shiny input widget that returns a (possibly named) vector of values.
#'
#' @param inputId The Shiny inputId
#' @param type An <input> element type.  See Shiny and jsonlight documentation
#'   for conversion rules.
#' @param nameLabel A label to use for the column of value names.  Set to NA to
#'   create an unnamed vector.
#' @param valueLabel A label to use for the column of values.
#' @param values An initial set of values.  Names are ignored if nameLabel = NA.
#' @param template A file path to a handlebars template to use to render the
#'   widget.  Use \code{\link{scaffoldTemplates}} to create a local copy of the
#'   default templates.
#'
#' @return A shiny tagList.
#' @export
vectorInput <- function( inputId
                       , type       = 'text'
                       , nameLabel  = 'name'
                       , valueLabel = 'value'
                       , values     = NULL
                       , template   = if (is.na(nameLabel)) {
                                        file.path(templatePath, "unnamed-vector.html")
                                      } else {
                                        file.path(templatePath, "named-vector.html")
                                      }
                       ) {

  addResourcePath(prefix = "vectorInput", directoryPath = wwwPath)

  registerInputHandler( 'vectorInput.vectorInput'
                      , function(values, shinysession, inputId) {
                          v        <- as.character(values)
                          names(v) <- names(values)
                          v
                        }
                      , force = TRUE
                      )

  tagList( singleton(tags$head(tags$script(src = 'vectorInput/vector-input.js')))
         , singleton(tags$head(tags$link(href  = 'vectorInput/vector-input.css', rel="stylesheet", type = "text/css")))
         , singleton(tags$head(tags$script(src = 'vectorInput/handlebars-v4.0.11.js')))
         , div( id         = inputId
              , class      = 'vector-input'
              , type       = type
              , nameLabel  = nameLabel
              , valueLabel = valueLabel
              , values     = as.list(values)
              )
         , tags$script( id   = paste0("vector-input-template-", inputId)
                      , type = "text/x-handlebars-template"
                      , HTML(readFile(template))
                      )
         )

}

readFile <- function(path) {
  paste0(readLines(path), collapse="\n")
}

#' Update the values in a vectorInput widget
#'
#' @param session Shiny server sesssion object.
#' @param inputId Target inputId.
#' @param values A vector of values.
#'
#' @export
updateVectorInput <- function(session, inputId, values) {
  session$sendInputMessage(inputId, list(values = as.list(values)))
}

#' Scaffold handlebars template files.
#'
#' Creates local copies of the handlebars templates used to render the widget in
#' the client.  This is useful for customizing the appearance of the widget.
#' See the `template` argument in \code{\link{vectorInput}}.
#'
#' @param path Where should template files be written?
#'
#' @export
scaffoldTemplates <- function(path = ".") {
  file.copy(file.path(templatePath, "*"), to = path)
}

#' Run a demo Shiny app
#'
#' Launches a little Shiny app to demo the widget.
#'
#' @export
demoApp <- function() {
  runApp( file.path(system.file("demo", package = "vectorInput"), "demo.R")
        , display.mode = 'showcase'
        )
}
