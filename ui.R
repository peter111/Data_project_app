# # shiny::runApp("C:/Users/Peter/Desktop/coursera/data_product/Data_product_shiny_app",port=4848, display.mode="showcase")

library(shiny)

# Define UI for random distribution application 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("German Credit data prediction algorithm"),
  
  sidebarPanel(
    selectInput("type",label=h3("Estimating algorithm:"),
                choices=list("GBM" = "gbm",
                             "RF" = "rf",
                             "ELM" = "elm",
                             "Blackboost"="blackboost",
                             "NNET"="nnet",
                             "Logit Boost"="LogitBoost"),
                             selected="LogitBoost"),
    br(),
            
    sliderInput("n", 
                "Training/Testing set partition of data:", 
                value = 0.7,
                min = 0.01, 
                max = 1),
    
    downloadButton('downloadData', 'Download data prediction example'),
    
    fileInput("file", label = h3("Choose CSV file"),
              accept=c('text/csv','text/comma-separated-values,text/plain'))
          
  ),
  
  
  # Show a tabset that includes a plot, summary, and table view
  # of the generated distribution
  mainPanel(
    tabsetPanel(
      tabPanel("Documentation", verbatimTextOutput("text")),
      tabPanel("Final training model", verbatimTextOutput("final_model")), 
      tabPanel("Accuracy plot of training set", plotOutput("plot")), 
      tabPanel("Accuracy of testing set", verbatimTextOutput("table")),
      tabPanel("All model comparison plot",plotOutput("plot_all")),
      tabPanel("Example file for prediction",tableOutput("example")),  
      tabPanel("Prediction",verbatimTextOutput("prediction"))
      
  
    )
    
  )
))