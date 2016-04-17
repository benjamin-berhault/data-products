library(shiny)
library(ggmap)

# Define server logic required to present data
shinyServer(function(input, output) {
  
  # Compute and format data from NYC OpenData to visualise Emergency Response Incidents data of New York City
  # by date range and incident type
  # 
  # This app provides the user an intuitive way to deal with this data
  # check that : https://rstudio.github.io/shinydashboard/get_started.html
  

  ## Testing values
  if (FALSE) {  
    input <- list()
    input <- append(input, list(type = "roadmap"))
    input <- append(input, list(zoom = 13))
    input <- append(input, list(bins = 15))
    input <- append(input, list(low = "yellow"))
    input <- append(input, list(high = "red"))
    input <- append(input, list(incident_type = "Fire"))
  }
  
  # Smoothing data representation with the kernel density estimation between differents kind of incident 
  custom_tanh <- function(x){tanh(2*x)}
  
  # Data loading 
  #NY_emergency_response_URL <-"https://data.cityofnewyork.us/api/views/pasr-j7fb/rows.csv?accessType=DOWNLOAD"
  NY_emergency_response_File <- "./NY_emergency_response.csv"
  if (!file.exists(NY_emergency_response_File))
    NY_emergency_response <- read.csv("https://data.cityofnewyork.us/api/views/pasr-j7fb/rows.csv", na.strings=c("NA","#DIV/0!","","Active"), strip.white=TRUE)
  else
    NY_emergency_response <- read.csv(NY_emergency_response_File, na.strings=c("NA","#DIV/0!","","Active"), strip.white=TRUE)

  
  # Remove rows with mlissing data
  NY_emergency_response <- na.omit(NY_emergency_response)
  row.names(NY_emergency_response) <- 1:nrow(NY_emergency_response)
  
  # Convert date string columns to POSIXct format
  NY_emergency_response$Creation.Date = as.POSIXct(NY_emergency_response$Creation.Date,format='%m/%d/%Y %H:%M:%S')
  NY_emergency_response$Closed.Date = as.POSIXct(NY_emergency_response$Closed.Date,format='%m/%d/%Y %H:%M:%S')
  
  # Explode Incident.Type column in category and subcategory columns  :
  # - Incident.Type
  # - Incident.Type.Sub
  NY_emergency_response$Incident.Type.Sub <- lapply(strsplit(as.character(NY_emergency_response$Incident.Type), "\\-"), "[", 2)
  col_idx <- grep("Incident.Type.Sub", names(NY_emergency_response))
  NY_emergency_response <- NY_emergency_response[, c(1, col_idx, (2:ncol(NY_emergency_response))[-(col_idx-1)])]
  NY_emergency_response$Incident.Type <- lapply(strsplit(as.character(NY_emergency_response$Incident.Type), "\\-"), "[", 1)
  
  # Rename columns with friendly names
  NY_emergency_response$Incident.Type[NY_emergency_response$Incident.Type=="HazMat"] <- "Hazardous Materials"
  NY_emergency_response$Incident.Type[NY_emergency_response$Incident.Type=="LawEnforcement"] <- "Law Enforcement"
  
  # Count occurrences by category from the initial dataset
  incident_occurences <- c()
  for(incident in unique(NY_emergency_response$Incident.Type)) {
    incident_occurences[[ incident ]] <- length(which(NY_emergency_response$Incident.Type == incident)) 
  }
  

  ## Restrict dataset by category and date range
  create.df <- reactive({
  
    # Restrict data by category 
    data_type <- NY_emergency_response[NY_emergency_response$Incident.Type == input$incident_type,]
    # Restriction data by date range
    data_type_range <- data_type[(data_type$Creation.Date >= as.character(input$dateRange[1])) & (data_type$Closed.Date <= as.character(input$dateRange[2])),]    
    data_type_range

  })

  
  ## Get map type selected
  map.type <- reactive({
    input$map_type
  })

  
  ## Define map color type
  map.bw <- reactive({
    if(input$bw) 
      "bw"
    else
      "color"
  })

  ## Set low temperature color
  gradient.low <- reactive({
    input$gradient_low
  })

  
  ## Set color for high temperature geo points
  gradient.high <- reactive({
    input$gradient_high
  })
  
  
  ## Map type representation events
  representation.type <- reactive({
    input$representation_type
  })
  
  
  output$map <- renderPlot({
    
    ## Use Reactive Functions
    temp.map_type <- map.type()
    temp.representation_type <- representation.type() 
    temp.map_bw <- map.bw()
    temp.low_gradient <- gradient.low()
    temp.high_gradient <- gradient.high()
    
    ## Get New York City geocode
    map.geocode <- suppressMessages(data.frame(geocode = geocode("New York, United States")));
    
    ## Message while map loading
    withProgress(message = 'Making plot...', value = 0, { 
    
      # Base map
      # Google Maps JavaScript API : https://developers.google.com/maps/documentation/javascript/reference
      map.base <- get_googlemap(
        as.matrix(map.geocode),
        maptype = temp.map_type, ## Map type : roadmap, terrain, satellite, hybrid
        zoom = 13, ## for example : 14 is just about right for a 1-mile radius
        color = temp.map_bw,   ## "color" or "bw" (black & white)
        scale = 2   ## Set it to 2 for high resolution output
      )
      
      ## Convert the base map into a ggplot object
      ## All added Cartesian coordinates to enable more geom options later on
      map.base <- ggmap(map.base, extend = "device") + coord_cartesian() + coord_fixed(ratio = 1.5) +
        ## Axis labels    
        labs(x = "Longitude", y = "Latitude")     

      # Kernel density representation
      if (temp.representation_type == "Kernel Density Estimation"){
  
          map.custom <- map.base +
        
          # Add Kernel density estimation layer
          stat_density2d(aes(x = Longitude, 
                             y = Latitude, 
                             fill = ..level.., 
                             alpha = ..level..),
                         na.rm = TRUE, 
                         bins = 15, ## Change and experiment with no. of bins
                         data = create.df(), 
                         geom = "polygon") +
          
          # Define color range for Kernel density visualization
          scale_fill_gradient(low = temp.low_gradient, high = temp.high_gradient, guide=FALSE) +
            
          # Compute a nicer data representation with the kernel density estimation for the different types of incidents
          scale_alpha(range = c(0, custom_tanh(nrow(create.df())/max(incident_occurences))), guide=FALSE)
  
      # Geo points representation
      } else {
        
        map.custom <- map.base +
        
          # Add geo points layer
          geom_point(aes(x=Longitude, y=Latitude), colour=temp.high_gradient, alpha=1, size=2, data=create.df())
        
      }
      
    })
    
    ## Display ggplot2 object
    print(map.custom)
    
  }, width = 900, height = 900)
  
  
  output$trends <- renderPlot({
    
    ## Dataset restrict by category and date range
    log <- create.df()
    
    ## Make a histogram Periods by Amount
    hist(log$Creation.Date, "months", format = "%Y-%m", col="orange",addDensityCurve=TRUE, 
          main="Trends for the 'Incident type' and 'Date range' selected", xlab="Periods", ylab="Amount",
              yaxt='n') 
     
  }, width = 1000, height = 900)

  
  # Display full dataset
  output$InitialData <- renderDataTable({
    
    initial.dataset <- NY_emergency_response
    initial.dataset$Creation.Date <- format(initial.dataset$Creation.Date,'%Y/%m/%d')
    initial.dataset$Closed.Date <- format(initial.dataset$Closed.Date,'%Y/%m/%d')
    initial.dataset
    
  },options = list(iDisplayLength = 15))
  

  # Display dataset restricted by category and date range
  output$Data <- renderDataTable({

    sub.dataset <- create.df()
    sub.dataset$Creation.Date <- format(sub.dataset$Creation.Date,'%Y/%m/%d')
    sub.dataset$Closed.Date <- format(sub.dataset$Closed.Date,'%Y/%m/%d')
    sub.dataset
    
  },options = list(iDisplayLength = 15))

  
  # Display occurences incidents types based on the full dataset
  output$Occurences <- renderDataTable({
    incident_occurences <- as.data.frame(t(incident_occurences))
    incident_occurences <- cbind(colnames(incident_occurences), t(incident_occurences))
    colnames(incident_occurences) <- c("Incidents","Occurences")
    incident_occurences

  },options = list(iDisplayLength = 15))
  
  
})
