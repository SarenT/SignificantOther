library(shiny)
library(ggplot2)
library(ggpubr)
library(wesanderson)
library(readxl)

library(tidyr)
library(dplyr)
library(lubridate)

server = function(input, output, session) {
	defaultData = reactive({
		n = input$sample_n
		me = rnorm(n, input$groupMeanMe * ifelse(input$notyoume, 0.5, 1), input$sd)
		sign_other = rnorm(n, input$groupMeanSO * ifelse(input$notmeyou, 0.5, 1), input$sd)
		me_name = "me"
		sign_other_name = "significant other"
		data = tibble(who = rep(c(me_name, sign_other_name), each = n), value = c(me, sign_other))
		return(data)
	})
	
	data = reactive({
		if(isDefaultData()){
			return(defaultData())	
		}
		
		if(endsWith(input$dataFile$datapath, ".xlsx")){
			data = read_xlsx(input$dataFile$datapath)
		}else if(endsWith(input$dataFile$datapath, ".csv")){
			data = read.csv(input$dataFile$datapath)
		}else{
			showNotification("Unrecognized file type.", type = "warning")
			return(NULL)
		}
		
		if(length(colnames(data)) != length(unique(colnames(data)))){
			showNotification("All column names must be unique.", type = "warning")
			return(NULL)
		}
		
		return(data)
	})
	
	isDefaultData = reactive({
		return(is.null(input$dataFile))
	})
	
	columns = reactive({
		names = as.list(colnames(data()))
		names(names) = colnames(data())
		names
	})
	
	unselectedColumns = reactive({
		measure = input$measure
    
    cols = columns()
    
    if(input$measure != 'none' && input$measure != ''){
    	cols[input$measure] = NULL
    }
    cols$`None` = "none"
    return(cols)
	})
	
	observeEvent(columns(), {
		choices = columns()
		choices$`None` = "none"
		
		selected = "none"
		if(isDefaultData()){
			selected = "value"
		}
		
		updateSelectInput(session = session, inputId = "measure", choices = choices, selected = selected)
	})
	
	observeEvent(unselectedColumns(), {
		selected = "none"
		if(isDefaultData()){
			selected = "who"
		}
		
		updateSelectInput(session = session, inputId = "groups", choices = unselectedColumns(), selected = selected)
	})
	
	observeEvent(input$measure, {
		updateTextInput(session = session, inputId = "xLab", value = input$measure)
	})
	
	observeEvent(input$groups, {
		updateTextInput(session = session, inputId = "yLab", value = input$groups)
	})
	
	output$isDataNull = reactive({
		as.character(isDefaultData())
	})
	
	nGroups = reactive({
		return(length(unique(data()[[input$groups]])))
	})
	
	output$plot = renderPlot({
		if(any(c(input$groups, input$measure) == "") || any(c(input$groups, input$measure) == "none")){
			return()
		}
		
		x = input$groups
		y = input$measure
		
		title = input$title
		subtitle = input$subtitle
		
		comparisons = combn(unique(data()[[x]]), 2, simplify = F)
		
		plt = ggplot(data(), aes(!!sym(x), !!sym(y), colour = !!sym(x), fill = !!sym(x))) + 
			geom_boxplot(alpha = 0.5) + 
			scale_fill_manual(values = wes_palette(n = nGroups(), name = input$color)) + 
			scale_color_manual(values = wes_palette(n = nGroups(), name = input$color)) + 
			labs(title = input$title, subtitle = input$subtitle) + ylab(input$yLab) + xlab(input$xLab) + 
			theme_classic() + stat_compare_means(label = "p.signif", method = input$test, 
																					 comparisons = comparisons, 
																					 symnum.args = list(cutpoints = c(0.0, 0.001, 0.01, 0.05, Inf), 
																					 									 symbols = c("♥♥♥", "♥♥", "♥", "☹"))) + 
			theme(plot.title = element_text(hjust = 0.5), 
						plot.subtitle = element_text(hjust = 0.5, face = "italic", colour = "darkgrey"))
		
		if(!input$legend){
			plt = plt + theme(legend.position = "none")
		}
		
		return(plt)
	}, res = 100)
	
	output$data = DT::renderDT({
		data()
	})
	
	outputOptions(output, "isDataNull", suspendWhenHidden = FALSE)
	
}