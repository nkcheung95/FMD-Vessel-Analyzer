library(shiny)
library(shinycssloaders)
library(later)
library(tcltk)

# Define UI
ui <- fluidPage(
  titlePanel("FMD Vessel Analysis"),
  
  # Centered button layout
  fluidRow(
    column(12, align = "center",
           actionButton("setwd_btn", "Set Working/Output Directory", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("vessel_clean", "Clean Vessel app diameters", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_mod", "FMD Analysis with viscosity model (flow, finger pressure)", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_mod_flip", "FMD Analysis with viscosity model (finger pressure, flow)", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_sp", "FMD Analysis with single-point viscosity (flow, finger pressure)", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_sp_flip", "FMD Analysis with single-point viscosity (finger pressure, flow)", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_no_v", "FMD Analysis without viscosity (flow, finger pressure)", width = '800px', style = "font-size: 14px; margin: 20px;"),
           actionButton("fmd_no_v_flip", "FMD Analysis without viscosity (finger pressure, flow)", width = '800px', style = "font-size: 14px; margin: 20px;")
           
    )
  ),
  
  # Spinner and status message below buttons
  fluidRow(
    column(12, align = "center",
           uiOutput("spinner"),
           uiOutput("status_message")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive values to control spinner visibility and status messages
  busy <- reactiveVal(FALSE)
  status <- reactiveVal(NULL)
  
  # Update spinner UI based on button presses
  output$spinner <- renderUI({
    if (busy()) {
      tagList(
        withSpinner(textOutput("loading_text"), type = 6)
      )
    }
  })
  
  # Update status message
  output$status_message <- renderUI({
    if (!is.null(status())) {
      tagList(
        h3(status(), style = "color: green;")
      )
    }
  })
  
  observeEvent(input$setwd_btn, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Selecting Directory and Checking Permissions..." })
    
    # Open directory selection dialog
    dir_path <- tryCatch({
      tk_choose.dir()
    }, error = function(e) {
      status(paste("Error selecting directory:", e$message))
      busy(FALSE)
      return(NULL)
    })
    
    if (is.null(dir_path) || dir_path == "") {
      status("No directory selected.")
      busy(FALSE)
      return()
    }
    
    # Create directory if it doesn't exist
    if (!dir.exists(dir_path)) {
      tryCatch({
        dir.create(dir_path, recursive = TRUE)
      }, error = function(e) {
        status(paste("Error creating directory:", e$message))
        busy(FALSE)
        return()
      })
    }
    
    # Try to set the working directory
    tryCatch({
      setwd(dir_path)
      can_write <- file.access(dir_path, 2) == 0
      if (can_write) {
        status(paste("Working directory set to:", dir_path, "and permissions are OK."))
      } else {
        status(paste("Working directory set to:", dir_path, "but permissions are not sufficient."))
      }
    }, error = function(e) {
      status(paste("Error setting working directory:", e$message))
    })
    
    busy(FALSE)
  })
  
  observeEvent(input$fmd_mod, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis with viscosity model" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_mod_visc.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  }) 
  observeEvent(input$fmd_mod_flip, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis with viscosity model" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_mod_visc_FLIPPED.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  })
  
  observeEvent(input$fmd_sp, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis with single-point viscosity" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_sp_visc.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  })
  observeEvent(input$fmd_sp_flip, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis with single-point viscosity" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_sp_visc_FLIPPED.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  })
  
  observeEvent(input$fmd_no_v, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis without viscosity" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_mod_visc.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  })
  
  observeEvent(input$fmd_no_v_flip, {
    busy(TRUE)
    status(NULL)
    output$loading_text <- renderText({ "Running FMD Analysis without viscosity" })
    
    # Simulate a script run with a delay
    later::later(function() {
      # Try to source the  Analysis script
      tryCatch({
        source("https://github.com/nkcheung95/FMD-brachialtools-analyzer/blob/main/FMD_R_no_visc_FLIPPED.r?raw=TRUE")
        status("FMD Analysis Completed!")
      }, error = function(e) {
        status(paste("Error during FMD Analysis:", e$message))
      })
      busy(FALSE)
    }, delay = 2)  # Adjust delay as needed
  })
  
  
} 
# Run the application 
shinyApp(ui = ui, server = server)
