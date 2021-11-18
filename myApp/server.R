library(shiny)
library(tidyverse)
library(ggplot2)

shinyServer(function(input, output) {
  can_lang = read_csv(file = 'https://raw.githubusercontent.com/UBC-DSCI/introduction-to-datascience/master/data/can_lang.csv')
  
  output$table1 = renderTable(head(can_lang, 10))
  
  output$text1 = renderText(dim(can_lang)[1])
  
  output$text2 = renderText(dim(can_lang)[2])
  
  output$text3 = renderText(any(is.na(can_lang)))
  
  output$text4 = renderText(any(duplicated(can_lang)))
  
  output$table2 = renderTable({
    cat_df = as.data.frame(table(can_lang$category))
    colnames(cat_df) = c('Category', 'Frequency')
    cat_df
  })
  
  output$text5 = renderText(input$slider1)
  
  output$plot1 = renderPlot({
    n = input$slider1
    cate = input$select1
    cate_lang = filter(can_lang, category == cate)
    arranged_cate_lang = arrange(cate_lang, by = desc(mother_tongue))
    topN_cate_lang = slice(arranged_cate_lang, 1:n)
    ggplot(topN_cate_lang, aes(x = mother_tongue, 
                               y = reorder(language, mother_tongue))) +
      geom_bar(stat = "identity") +
      xlab("Mother Tongue (Number of Canadian Residents)") +
      ylab("Language") +
      theme(axis.text.x = element_text(color = "grey40", size = 15, hjust = .5, vjust = .5),
            axis.text.y = element_text(color = "grey40", size = 15, hjust = 1, vjust = .5),  
            axis.title.x = element_text(color = "grey20", size = 18, hjust = .5, vjust = 0),
            axis.title.y = element_text(color = "grey20", size = 18, hjust = .5, vjust = 1)
      )
  })
  
  cate_model2 = reactive({
    cate = input$select1
    cate_lang = filter(can_lang, category == cate)
    arranged_cate_lang = arrange(cate_lang, by = desc(mother_tongue))
    top20_cate_lang = slice(arranged_cate_lang, 1:20)
    brushed_cate_lang = brushedPoints(top20_cate_lang, input$brush1,
                                      xvar = 'most_at_home', yvar = 'most_at_work'
    )
    if(nrow(brushed_cate_lang)<2) {return(NULL)}
    lm(most_at_work ~ most_at_home, data = brushed_cate_lang)
  })
  
  output$plot2 = renderPlot({
    # Extract top 20 languages of selected category
    cate = input$select1
    cate_lang = filter(can_lang, category == cate)
    arranged_cate_lang = arrange(cate_lang, by = desc(mother_tongue))
    top20_cate_lang = slice(arranged_cate_lang, 1:20)
    # Fit linear model
    cate_model = lm(most_at_work ~ most_at_home, data = top20_cate_lang)
    # Predict value of most_at_work given new value of most_at_home
    homeNew = input$number1
    if(!is.null(cate_model2())) {
      workNew2 = predict(cate_model2(), newdata = data.frame(most_at_home = homeNew))
    }
    workNew = predict(cate_model, newdata = data.frame(most_at_home = homeNew))
    # Set up max value of x and y axes
    xlim_max = ifelse(cate == 'Aboriginal languages', 40000, 500000)
    ylim_max = ifelse(cate == 'Aboriginal languages', 10000, 70000)
    main = paste('Category:', cate)
    # Create scatter plot
    with(top20_cate_lang, 
         plot(x = most_at_home, y = most_at_work,
              main = main,
              xlab = 'No of People Speaking a Language at Home', 
              ylab = 'No of People Speaking a Language at Work',
              xlim = c(0, xlim_max), 
              ylim = c(0, ylim_max), 
              pch = 16
         )
    )
    # Add linear regression line of model 1 and 2 to scatter plot
    abline(cate_model, lwd = 2, col = 'red')
    if(!is.null(cate_model2())) {
      abline(cate_model2(), lwd = 2, col = 'blue')
    }
    # Add predicted point of model 1 and 2 to scatter plot
    points(homeNew, workNew, cex = 1.5, pch = 16, col = 'red')
    if(!is.null(cate_model2())) {
      points(homeNew, workNew2, cex = 1.5, pch = 16, col = 'blue')
    }
    legend('bottomright', c('Model from all 20 data points', 'Model from brushed data points'),
           pch = 16, col = c('red', 'blue'))
  })
  
  output$text6 = renderText({
    cate = input$select1
    cate_lang = filter(can_lang, category == cate)
    arranged_cate_lang = arrange(cate_lang, by = desc(mother_tongue))
    top20_cate_lang = slice(arranged_cate_lang, 1:20)
    cate_model = lm(most_at_work ~ most_at_home, data = top20_cate_lang)
    homeNew = input$number1
    workNew = predict(cate_model, newdata = data.frame(most_at_home = homeNew))
    ylim_max = ifelse(cate == 'Aboriginal languages', 10000, 70000)
    ylim_min = 0
    if(workNew>ylim_max | workNew<ylim_min) {
      paste(round(workNew), 'The point is not displayed because it is out of the range of the plot', sep = '. ')
    } else {
      round(workNew)
    }
  })
  
  output$text7 = renderText({
    cate = input$select1
    homeNew = input$number1
    if(is.null(cate_model2())) {return('not valid because no model is found')}
    workNew = predict(cate_model2(), newdata = data.frame(most_at_home = homeNew))
    ylim_max = ifelse(cate == 'Aboriginal languages', 10000, 70000)
    ylim_min = 0
    if(workNew>ylim_max | workNew<ylim_min) {
      paste(round(workNew), 'The point is not displayed because it is out of the range of the plot', sep = '. ')
    } else {
      round(workNew)
    }
  })
  
  output$text8 = renderText({
    homeNew = input$number1
    cate = input$select1
    xlim_max = ifelse(cate == 'Aboriginal languages', 40000, 500000)
    xlim_min = 0
    if(homeNew>xlim_max | homeNew<xlim_min) {
      paste("The entered value should be within the range of [0, ", xlim_max, "] in case of ", cate, sep ="") 
    } else {
      "The entered value is valid"
    }
  })
})
