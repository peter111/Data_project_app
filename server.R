require(shiny)
require(gbm)
require(survival)
require(lattice)
require(splines)
require(parallel)
require(elmNN)
require(MASS)
require(caret)
require(ggplot2)
require(e1071)
require(plyr)
require(caTools)
require(randomForest)
require(party)
require(grid)
require(mvtnorm)
require(modeltools)
require(stats4)
require(strucchange)
require(zoo)
require(sandwich)
require(mboost)
require(stabs)
require(nnet)
data(GermanCredit)
dim(GermanCredit)

# Define server logic for random distribution application
shinyServer(function(input, output) {

  
  data<-reactive({  
    set.seed(10)
    inTrain<-createDataPartition(y=GermanCredit$Class,p=input$n,list=FALSE)  
    training<-GermanCredit[inTrain,]
    control <- trainControl(method="repeatedcv", number=10, repeats=3)
    set.seed(20)
    modFit<-train(Class~.,method=input$type,trControl=control,data=training)  
  })
  
  output$plot <- renderPlot({  
    ggplot(data())
  })
    
  output$final_model <- renderPrint({
    data()$finalModel
  })
    
  # Generate an HTML table view of the data
    
    
  output$table <- renderPrint({
    set.seed(10)
    inTrain<-createDataPartition(y=GermanCredit$Class,p=input$n,list=FALSE)  
    testing<-GermanCredit[-inTrain,]
    pred<-predict(data(),newdata=testing)
    confusionMatrix(data=pred,testing$Class)
  })
  
  
  output$plot_all<-renderPlot({
        set.seed(10)
        inTrain<-createDataPartition(y=GermanCredit$Class,p=input$n,list=FALSE)  
        training<-GermanCredit[inTrain,]
        control <- trainControl(method="repeatedcv", number=10, repeats=3)
        set.seed(20)
        mod_gbm<-train(Class~.,method="gbm",trControl=control,data=training,verbose=F)
        set.seed(20)
        mod_rf<-train(Class~.,method="rf",data=training,trControl=control)
        set.seed(20)
        mod_elm<-train(Class~.,method="elm",data=training,trControl=control)
        set.seed(20)
        mod_blackboost<-train(Class~.,method="blackboost",data=training,trControl=control)
        set.seed(20)
        mod_nnet<-train(Class~.,method="nnet",data=training,trControl=control, verbose=F)
        set.seed(20)
        mod_lb<-train(Class~.,method="LogitBoost",data=training,trControl=control, verbose=F)
        results_train <- resamples(list(GBM=mod_gbm, RF=mod_rf,ELM=mod_elm,
                                   BLACKBOOST=mod_blackboost,NNET=mod_nnet,
                                   LogitBoost=mod_lb))
        dotplot(results_train)
  })
  
  filedata <- reactive({
    infile <- input$file
    if (is.null(infile)) {
      # User has not uploaded a file yet
      return(NULL)
    }
    read.csv(infile$datapath,header=T)
  })
  
  output$prediction<-renderText({
    if(!is.null(filedata())){
      paste("Based on the inputed data credit worthiness is:",predict(data(),newdata=filedata()),"\n")  
    }
    
  })
  output$example <- renderTable({
    t(GermanCredit[1,-10])
  })
  
  output$downloadData<-downloadHandler(
    filename="example.csv",
    content=function(file){
      sep<-","
      write.table(GermanCredit[1,-10],file,sep=sep,row.names=FALSE)
    }
      
  )
  
  output$text<-renderText({
    paste("Introduction","\n","\n","Main goal of the presented shiny app is to predict credit worthiness (bad or good) of applicant based on related attributes such as:  checking account status, duration, credit history, purpose of the loan, amount of the loan, savings accounts or bonds, employment duration, Installment rate in percentage of disposable income, personal information, other debtors/guarantors, residence duration, property, age, other installment plans, housing, number of existing credits, job information, Number of people being liable to provide maintenance for, telephone, and foreign worker status using machine learning algorithms, whose will be introduced in the next part. The source dataset is German Credit Data from package caret.",
          "\n","\n","Inputs","\n","\n","Application has three main inputs:","\n","\t","selection bar-user can select different machine learning algorithms (pre-selected option is Logit Boost)","\n","\n","\t","slider input- for reactive partition of German Credit Data into training and testing dataset (pre-selected partition is 70% of the data are placed to training set, 30% to testing set)","\n","\n",
          "\t","file input- for loading new dataset to predict credit worthiness based on the selected partition and model (user can download example csv file from the side panel: example.csv, loaded file can have many rows, but example file format must be kept)","\n","\n",
          "User can select from six models:","\n","\t","gbm-Stochastic Gradient Boosting model","\n","\t","rf- Random Forest model","\n","\t","elm- Extreme Machine Learning model","\n","\t","Blackboost- Boosted Tree model","\n",
          "\t","nnet-Neural Network model","\n","\t","LogitBoost- Boosted Logistic Regression model","\n","\n","Outputs","\n","\n",
          "Application has 7 tabPanel outputs. Please keep in mind that all algorithms need time to finish computation. Computation is executed with every change of input. The first output tabPanel is tabPanel with this documentation, to make it easier for user to use the shiny App. After clicking on one of the next three tabPanels the actual computation for selected model begins. The tabPanel Final training model shows final model selected algorithm on partioned training data. The next tabPlot plots generic ggplot for selected model. Fourth tabPanel summarizes prediction accuracy of selected model on testing dataset. Fifth tabPanel compares all models for selected partiotion of data in one chart(Accuracy and Kappa). Please keep in mind that after clicking on this tabPanel, actual calculation might take a while to finish, because it's running all 6 estimations. The sixth panel is just preview of transponded example file, which can be dowloaded. The last panel shows prediction of user's data, where result will be rendered after loading data and it will answer the question if the credit worthiness is bad or good."
          )
  })
  
  
})