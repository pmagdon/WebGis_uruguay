library(shiny)
library(leaflet)
library(RPostgreSQL)
library(RColorBrewer)

#driver <- dbDriver("PostgreSQL")
#connection <- dbConnect(driver, host="localhost", dbname="calc", user="calc", password="calc", port=5432)

#sql='SELECT parcela.parcela_id as id,
#           SUM(result.arbol_cantidad) as stems,
#           SUM(result.arbol_area_basal) as ba,
#           SUM(result.arbol_volumen_total) as vol,
#           parcela.pm_coord_x as lon,
#           parcela.pm_coord_y as lat
#    FROM ifn_uruguay_v8._arbol_plot_agg as result,
#         ifn_uruguay_v8.parcela as parcela
#    WHERE result.parcela_id_ = parcela.parcela_id_
#    GROUP BY parcela.parcela_id,lon,lat;'
#plots<-dbGetQuery(connection,sql)
#dbDisconnect(connection)

plots<-plots[complete.cases(plots),]

#save(plots,file='X:/FE_016_Uruguay/final/final_2016-12-04/webgis/GIS_webapp/data/ifn_data.R')
load('X:/FE_016_Uruguay/final/final_2016-12-04/webgis/GIS_webapp/data/ifn_data.R')

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    plots[plots$ba >= input$range[1] & plots$ba <= input$range[2],]
  })
  
  colorpal <- reactive({
    colorNumeric(input$colors, plots$ba)
  })
  
  
  
  output$map <- renderLeaflet({
      leaflet() %>% addTiles()  %>%
      fitBounds(min(plots$lon), min(plots$lat), max(plots$lon), max(plots$lat))
     
  })
  
  observe({
    pal <- colorpal()
    leafletProxy("map", data = filteredData()) %>%
      clearMarkers() %>%
      addCircleMarkers(radius = 3, weight = 1, color = "#777777",
                 fillColor = ~pal(plots$ba), fillOpacity = 0.7, popup = ~paste('PlotID:',plots$id,'\n','Basal Area',round(plots$ba,1))
      )
  })
  
  observe({
    proxy <- leafletProxy("map", data = plots)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~ba, title='Basal Area in m²/ha'
      )
    }
  })
  
}