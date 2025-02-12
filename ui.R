library(shiny)
library(bslib)
library(DT)
library(wesanderson)
library(shinyBS)

ui = page_sidebar(
	tags$head(
		tags$style(HTML("
      .navbar { background-color: #ff5555 !important; } 
      .main { background-color: #ffdddd !important; }
      .accordion-header { background-color: #ff7777 !important; }
      .accordion-body { background-color: #ff9999 !important; }
      .accordion-button { background-color: #ff7777 !important; } 
    "))
	),
	sidebar = sidebar(
		accordion(
			id = "dataSelection",
			p("Calculate significance for your significant other with love...", style = "font-weight: bold; margin: 1em;"),
			accordion_panel(title = "p-hacking", 
											p("Play with these parameters and get the best p-value to prove your love to your significant other!"),
											sliderInput("sample_n", "Number of samples", min = 5, max = 1000, value = 10, step = 5), 
											sliderInput("sd", "standardDeviation", min = 0.1, max = 100, value = 1, step = 0.1),
											numericInput("groupMeanMe", "Mean Me", value = "10"),
											numericInput("groupMeanSO", "Mean SO", value = "15"),
											checkboxInput("notyoume", "It's not you, it's me", value = FALSE),
											checkboxInput("notmeyou", "It's not me, it's you", value = FALSE)
											),
			accordion_panel(title = "Bring your own data",
											p("Either XLSX or CSV files. At least one column should be the labeled groups and one column should be the values (measure)."),
											fileInput("dataFile", label = "Data file")
											),
			multiple = FALSE
		),
		
		selectInput("measure", "Measure", choices = list()),
		conditionalPanel("input.measure != 'none'", selectInput("groups", "Groups", choices = list())),
		textInput("title", "Title"),
		textInput("subtitle", "Subtitle"),
		textInput("xLab", "x Label"),
		textInput("yLab", "y Label"),
		checkboxInput("legend", "Display legend?"),
		p("Simply performs the test against each other to display signifance over all groups. Statistically not sane but cute I suppose."),
		selectInput("test", "Test", list(`Non-parametric love (Mann-Whitney test)` = "wilcox.test", `Parametric love (Student's t-Test)` = "t.test")),
		p("Palettes generated mostly from 'Wes Anderson' movies (wesanderson package in CRAN). Are there more romantic colors than the theme of Fantastic Mr. Fox?"),
	 	selectInput("color", "Colors", 
							 choices = setNames(names(wes_palettes), names(wes_palettes)), 
							 selected = "FantasticFox1"), 
		
		style = "background: #ff9999"
	),
	title = "Significant Other ♥ (minimal effort for a silly app)",
	window_title = "Significant Other >---♥--->",
	card(
		plotOutput(outputId = "plot"),
		style = "background: #ffbbbb"
	),
	DT::DTOutput("data")
	
)