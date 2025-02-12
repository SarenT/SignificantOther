library(shiny)
library(bslib)
library(DT)
library(wesanderson)
library(shinyBS)

ui = page_sidebar(
	tags$head(
		tags$style(HTML("
      .navbar { background-color: #ff7777 !important; } 
      .main { background-color: #ffdddd !important; }
    "))
	),
	sidebar = sidebar(
		p("Either XLSX or CSV files. At least one column should be groups and one column should be values (measure)."),
		fileInput("dataFile", label = "Data file"), 
		
		selectInput("measure", "Measure", choices = list()),
		conditionalPanel("input.measure != 'none'", selectInput("groups", "Groups", choices = list())),
		textInput("title", "Title"),
		textInput("subtitle", "Subtitle"),
		textInput("xLab", "x Label"),
		textInput("yLab", "y Label"),
		checkboxInput("legend", "Display legend?"),
		p("Simply performs the test against each other to display signifance over all groups. Statistically not sane but cute I suppose."),
		selectInput("test", "Test", list(`Mann-Whitney test` = "wilcox.test", `Student's t-Test` = "t.test")),
		p("Palettes generated mostly from 'Wes Anderson' movies (wesanderson package in CRAN). Are there more romantic colors than the theme of Fantastic Mr. Fox?"),
	 	selectInput("color", "Colors", 
							 choices = setNames(names(wes_palettes), names(wes_palettes)), 
							 selected = "FantasticFox1"), 
		style = "background: #ff9999"
	),
	title = "Significant Other ♥",
	window_title = "Significant Other ♥",
	card(
		plotOutput(outputId = "plot"),
		style = "background: #ffbbbb"
	),
	DT::DTOutput("data")
	
)