library(shiny)
library(leaflet)
library(RPostgreSQL)
library(RColorBrewer)
driver <- dbDriver("PostgreSQL")
connection <- dbConnect(driver, host="localhost", dbname="calc", user="calc", password="calc", port=5432)

sql='SELECT parcela.parcela_id as id,
SUM(result.arbol_cantidad) as stems,
SUM(result.arbol_area_basal) as ba,
SUM(result.arbol_volumen_total) as vol,
parcela.pm_coord_x as lon,
parcela.pm_coord_y as lat
FROM ifn_uruguay_v8._arbol_plot_agg as result,
ifn_uruguay_v8.parcela as parcela
WHERE result.parcela_id_ = parcela.parcela_id_
GROUP BY parcela.parcela_id,lon,lat;'
plots<-dbGetQuery(connection,sql)
dbDisconnect(connection)

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

