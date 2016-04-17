require(ggplot2)
require(ggmap)
require(markdown)
require(rmarkdown)
require(shiny)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Application title
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  headerPanel("Emergency Response Incidents | State of New York"),

  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Sidebar Panel
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  sidebarPanel(
      
    wellPanel(
      helpText(HTML("<b>ABOUT</b>")),
      HTML("Visual representation of New York City emergency response incendents for the period from 1 January 2013 to 31 December 2015. (<a href='https://data.cityofnewyork.us/Public-Safety/Emergency-Response-Incidents/pasr-j7fb#Embed'>Data source</a>) <br>"),
      HTML('<br><center>'),
      submitButton("UPDATE GRAPH AND TABLES"),
      HTML('<br><i>'),
      helpText("(Click again the button above after changing settings)"),
      HTML('</i></center>')
      
      ),
    
    wellPanel(
      helpText(HTML("<b>BASIC SETTINGS</b>")),
      
      dateRangeInput("dateRange", "Date range:",
                     start = "2013-01-01",
                     end   = "2015-12-31",
                     min    = "2013-01-01",
                     max    = "2015-12-31",
                     format = "yyyy/mm/dd"),

      selectInput(inputId="incident_type", label="Incident type:", choice = c("Fire","Transportation","Law Enforcement","Hazardous Materials","Utility","Structural","Administration","Rescue","Aviation","Medical","Weather","Marine","Other"))
    ),
    
    wellPanel(
      helpText(HTML("<b>MAP SETTINGS</b>")),
      selectInput("representation_type", "Choose representation type:", choice = c("Kernel Density Estimation","Geo Points")),
      selectInput(inputId="map_type", label="Choose Google Map type:", choice = c("roadmap", "satellite", "hybrid","terrain")),
      checkboxInput("bw", "Black & White?", FALSE)
    ),
    
    wellPanel(
      helpText(HTML("<b>CUSTOMIZATION</b>")),
      selectInput(inputId="gradient_low", "Fill gradient (Low):", 
                  choice = c("yellow", "red", "orange", "green", "blue", "purple", "white", "black", "grey")),
      selectInput(inputId="gradient_high", "Fill gradient (High):", 
                  choice = c("red", "orange", "yellow", "green", "blue", "purple", "white", "black", "grey"))
      ),
        
    wellPanel(
      helpText(HTML("<b>ABOUT ME</b>")),
      HTML('Benjamin Berhault'),
      HTML('<br>'),
      HTML('<a href="https://www.linkedin.com/in/benjaminberhault" target="_blank">LinkedIn</a>, <a href="https://plus.google.com/u/0/+BenjaminBerhaultDS/posts" target="_blank">Google+</a>')
    ),

    width = 3
    
  ),
  
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Main Panel
  ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  mainPanel(
    tabsetPanel(

      ## Core tabs
      tabPanel("Information", includeMarkdown("docs/introduction.md")),
      tabPanel("Heat Map", plotOutput("map")),
      tabPanel("Trends", plotOutput("trends")),
      tabPanel("Initial Dataset", dataTableOutput("InitialData")),
      tabPanel("Sub Dataset", dataTableOutput("Data")),
      tabPanel("Occurences", dataTableOutput("Occurences"),tags$style(type="text/css", '#Occurences tfoot,#Occurences .dataTables_filter,#Occurences .dataTables_length,#Occurences .dataTables_info,#Occurences .dataTables_paginate {display:none;}')),
      selected = "Heat Map"
    ) 
  )
  
))