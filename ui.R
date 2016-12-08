library(shiny)
library(leaflet)
library(RPostgreSQL)
library(RColorBrewer)
load('X:/FE_016_Uruguay/final/final_2016-12-04/webgis/GIS_webapp/data/ifn_data.R')
plots<-plots[complete.cases(plots),]



ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  
    absolutePanel(top = 10, right = 10,
                sliderInput("range", "Basal Area m²/ha",0, max(plots$ba),
                            value = range(plots$ba), step = 10
                ),
    selectInput("colors", "Color Scheme",
                rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)

