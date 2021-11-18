library(shiny)

shinyUI(fluidPage(
    titlePanel('Languages in Canada in 2016'),
    p('Huy (Henry) Truong', br(), '2021-11-17'),
    tabsetPanel(
        type = 'pills',
        
        tabPanel(title = 'Introduction',
                 h3(strong('Data')),
                 p('The data set is related to languages spoken by Canadian 
                   residents and collected during the 2016 Canadian census.
                   The link to download the data set can be found in',
                   a(href = 'https://raw.githubusercontent.com/UBC-DSCI/introduction-to-datascience/master/data/can_lang.csv',
                     "this link")
                 ),
                 p('There are', strong(' 214 languages'), ' recorded, each of which has', strong(' 6 properties:')),
                 p(code('category'), ': Higher-level language category', br(),
                   code('language'), ': Name of the language', br(),
                   code('mother_tongue'), ': Number of Canadian residents speaking the language as their mother tongue', br(), 
                   code('most_at_home'), ': Number of Canadian residents speaking the language most often at home', br(),
                   code('most_at_work'), ': Number of Canadian residents speaking the language most often at work', br(),
                   code('lang_known'), ': Number of Canadian residents with knowledge of the language'
                 ),
                 h3(strong('Content')),
                 p('This analysis will focus on the following questions:'),
                 p(em('Question 1:'), 
                   'What are the top N from 3 to 10 (selected by the user) 
                   languages of the selected category spoken most as mother tongue?',
                   br(),
                   em('Question 2:'), 
                   'What is predicted value of the number of Canadian residents speaking 
                   a language at work, given the number of them (entered by the user) 
                   speaking it at home?'
                 ),
                 p('To answers the questions, a process of following steps is performed:'),
                 p(em('Step 1:'), 'Getting and Cleaning Data', br(),
                   em('Step 2:'), 'Visualizing Data', br(),
                   em('Step 3:'), 'Building a Prediction Model'
                 ),
                 h3(strong('R Packages')),
                 p('The study uses', code('tidyverse'), 'and', code('ggplot2'), 'packages',
                   br(),
                   'The application with the user interface is created using', code('shiny'), 'packages'
                 ),
                 hr()
        ),
        
        tabPanel(title = 'Getting and Cleaning Data',
                 br(),
                 h4('Load', code('tidyverse'), 'package'),
                 pre('library(tidyverse)'),
                 br(),
                 h4('Download and read in the data set'),
                 pre("can_lang = read_csv(file = 'https://raw.githubusercontent.com/UBC-DSCI/introduction-to-datascience/master/data/can_lang.csv')"),
                 br(),
                 h4('Have a peak at the data set'),
                 pre('can_lang'),
                 tableOutput('table1'),
                 br(),
                 h4('Show the dimension of the data set'),
                 pre('dim(can_lang)'),
                 p('- Number of rows:', strong(textOutput('text1', inline = T)), br(),
                   '- Number of rows:', strong(textOutput('text2', inline = T))
                 ),
                 br(),
                 h4('Check if NA values are present in the data set'),
                 pre('any(is.na(can_lang))'),
                 p('The result is', strong(textOutput('text3', inline = T))),
                 br(),
                 h4('Check if duplicated values are present in the data set'),
                 pre('any(duplicated(can_lang))'),
                 p('The result is', strong(textOutput('text4', inline = T))),
                 br(),
                 p(strong('Note:'), 'The data set seems to be tidy'),
                 br(),
                 h4('Show what elements are in', code('category'), 'column and their frequency'),
                 pre('table(can_lang$category)'),
                 tableOutput('table2'),
                 p(strong('Note:'),
                   'There are 3 categories of languages. 
                   However, the first 2 categories in the table are of interest in this study'
                 ),
                 hr()
        ),
        
        tabPanel(title = 'Visualizing Data',
                 br(),
                 sidebarLayout(
                     sidebarPanel(
                         selectInput('select1', 'Category of Language',
                                     c('Aboriginal languages', 'Non-Official & Non-Aboriginal languages'), 
                                     selected = 'Aboriginal languages', multiple = F
                         ),
                         sliderInput('slider1', 'Top N Languages of Selected Category as Mother Tongue', 
                                     min = 3, max = 10, value = 5
                         ),
                         submitButton('Apply Changes')
                     ),
                     mainPanel(
                         h3('Bar Chart of Top', textOutput('text5', inline = T), 
                            'Languages Spoken as Mother Tongue in Canada in 2016'
                         ),
                         plotOutput('plot1')
                     )
                 ),
                 hr()
                 
        ),
        
        tabPanel(title = 'Building a Prediction Model',
                 br(),
                 sidebarLayout(
                     sidebarPanel(
                         numericInput('number1', 'Enter the number of people speaking a language at home',
                                      value = 20000, min = 0, step = 500),
                         em(textOutput('text8')),
                         br(),
                         submitButton('Apply Changes'),
                         br(),
                         p(strong('Note:'), 
                           'Drag a window on the plot to select points 
                           to build the second model then click the',
                           code('Apply Changes'),
                           'button'
                         )
                     ),
                     mainPanel(
                         h3('Linear Model with', 
                            code('most_at_home'), 
                            'as a Variable and',
                            code('most_at_work'),
                            'as a Response'),
                         plotOutput('plot2', brush = 'brush1'),
                         p('The value predicted from the model built from all 20 data points is',
                           strong(textOutput('text6', inline = T))),
                         p('The value predicted from the model built from brushed data points is',
                           strong(textOutput('text7', inline = T)))
                     )
                 ),
                 hr()
                 
        )
        
        
    )
))
