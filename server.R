#source('prepare_findGSE.R')
library(shiny)
library(shinyjs)
library(shinyBS)
library(DT)
library(ggplot2)
library(stringr)
library(seqinr)


#library(shinyanimate)
# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  #output$UFoldImage <-renderImage({
  #      list(src = paste0("www/","UFold_logo.png"))
#
  #  })
  #startAnim(session = session(), "UFoldImage", "bounceInLeft")
  shinyjs::disable("ResultDown")
  shinyjs::hide("seq_name")
  shinyjs::hide("dVisualize")
  shinyjs::hide("seq_table")
  #shinyjs::hide("double_click")
  shinyjs::disable("draw_plot")
  #shinyjs::hideElement(id= "panel_varna")
  shinyjs::hideElement(id= "panel_forna")
  #shinyjs::hide("inc")
  observeEvent(input$example,{
    selected_species <- input$example_sel
    sel_file_name <- switch(selected_species,
      "javanica_tetraploid" = "demo_data/javanica.histo",
      "potato_tetraploid" = "demo_data/O_21mer_new20231012.histo",
      "wheat_hexaploid" = "demo_data/wheat.histo",
      "strawberry_octoploid" = "demo_data/strawberry.histo",
      "Chinese_sturgeon_octoploid" = "demo_data/zhonghuaxun_newgenerate.histo"
    )
    shinyjs::disable("example")
    shinyjs::disable("your_text")
    data_example <- read.table(sel_file_name,header =FALSE)
    text_example <- paste(data_example$V1, data_example$V2, sep = " ",collapse="\n")
    updateTextAreaInput(session, "your_text", value = text_example) 
    shinyjs::enable("example")
    shinyjs::enable("your_text")
  })
  observeEvent(input$submit, {
    output$form_table <- renderTable({
      validate(
        #need(stringr::str_detect(input$email,'@') && str_length(input$email) > 3, "Input right email address!!"),
        #need(length(as_bytes(input$your_text)) > 0 & length(as_bytes(input$your_text)) <= 50, "Text should be with 0 to 5000"),
        need(str_length(input$outfile) > 0,"You should specify output file name!!!"),
        need(str_length(input$exp_hom) > 0,"You should specify exp hom number!!!"),
        need(str_length(input$sizek) > 0,"You should specify sizek parameter!!!"),
        need(str_length(input$xlimit) > 0,"You should specify xlimit parameter!!!"),
        need(str_length(input$ylimit) > 0,"You should specify ylimit parameter!!!"),
        need(!is.null(input$file_input) || str_length(input$your_text) > 0, "You should specific either file or text")
      )

      #data.frame('name'=c('Email',  'Text'),
      #           'value'=c(input$email, str_length(input$your_text)),
      #           stringsAsFactors = F)
      data.frame()

    })
  })
  
  
  dt <- reactive({
    if(is.null(input$file_input)){
      return()
    }else{
      #read.fasta(input$file_input, as.string = TRUE,forceDNAtolower = FALSE)
      read.table(input$file_input$datapath,header =FALSE)
    }
  })
  
  observeEvent(input$submit, {
    #session$sendCustomMessage(type = 'testmessage',
    #                          message=('Start processing, please wait'))
    validate(
      #need(stringr::str_detect(input$email,'@') && str_length(input$email) > 3, "Input right email address!!"),
      #need(length(as_bytes(input$your_text)) > 0 & length(as_bytes(input$your_text)) <= 50, "Text should be with 0 to 5000"),
      need(str_length(input$outfile) > 0,"You should specify output file name!!!"),
      need(str_length(input$exp_hom) > 0,"You should specify exp hom number!!!"),
      need(str_length(input$sizek) > 0,"You should specify sizek parameter!!!"),
      need(str_length(input$xlimit) > 0,"You should specify xlimit parameter!!!"),
      need(str_length(input$ylimit) > 0,"You should specify ylimit parameter!!!"),
      need(str_length(input$outfile) > 0,"Output file name should longer that 0!!!"),
      need(!is.null(input$file_input) || str_length(input$your_text) > 0, "You should specific either file or text")
    )
    
    showNotification("Start processing, please wait...",duration = 3)
    #Sys.sleep(1)
    #shinyjs::runjs("swal.close();")
    shinyjs::disable("submit")
    shinyjs::disable("draw_plot")
    shinyjs::disable("ResultDown")

    shinyjs::hide("myImage")
    shinyjs::hide("seq_name")
    shinyjs::hide("dVisualize")
    shinyjs::hide("table")
    #t1 <- try(system("bash test.sh Done!!!", intern = TRUE))
    if(is.null(input$file_input)){
      write.table(input$your_text, paste0('input_histo/',input$outfile,'.histo'), sep = ' ', col.names = F, row.names = F, quote = F)
    }else{
      write.table(dt(), paste0('input_histo/',input$outfile,'.histo'), sep = ' ', col.names = F, row.names = F, quote = F)
    }
    #t1 <- try(system(paste0("bash test.sh input.txt ",input$species," Done!!!"),intern = TRUE))
    #t1 <- try(system("echo Done!!!", intern = TRUE))
    #t1 <- try(system("echo Done!!!", intern = TRUE))
    #temp_file <- tempfile()
    command = paste("/home/shiny/miniconda3/envs/python38/bin/Rscript",
    "findGSE_script.R",
    shQuote("input_histo/"),
    shQuote("potato_7A_21mer.histo"),21,50,4,6,9,150,3.5e+07,shQuote("outfile"),
    sep=" ")
    print(command)
    #command = paste("/home/shiny/miniconda3/envs/python38/bin/Rscript",
    #"findGSE_script.R",
    #shQuote("input_histo/"),
    #shQuote(paste0(input$outfile,'.histo')),input$sizek,input$exp_hom,input$ploidy,input$range_left,input$range_right,input$xlimit,input$ylimit,shQuote("outfile"),
    #sep=" ")
    withProgress(message = 'Running findGSEP', value = 0, {
      # n <- 2
      # Update the progress bar and detail text
      incProgress(1/2, detail = c("Please wait..."))

      # Simulate a long computation
      Sys.sleep(0.1)
      
    
      output_GSE <- system2("/home/shiny/miniconda3/envs/python38/bin/Rscript",
                    c("findGSE_script.R",
                      shQuote("input_histo/"),
                      #shQuote(paste0(input$outfile, ".histo")),
                      shQuote(paste0(input$outfile, ".histo")),
                      input$sizek, input$exp_hom, input$ploidy, input$exp_hom * 0.2, input$exp_hom * 0.2, input$xlimit, input$ylimit,
                      shQuote("outfile")),
                    stdout = TRUE, stderr = TRUE)
      incProgress(1/3, detail = c("Please wait..."))
      cat(output_GSE)

      
      
      incProgress(1/2, detail = c("Task finished."))
      Sys.sleep(1)
    })
    #system(paste(command,">",temp_file))
    output_GSE <- paste(output_GSE, collapse = "\n")
    if (grepl("Program running time",output_GSE)) {
	  result <- ""
	} else if (grepl("You may need to increase the cutoff",output_GSE)) {
          result <- "Problem occurs. -exp_hom You may need to increase the cutoff"
	} else if (grepl("only 0's may be mixed with negative subscripts",output_GSE)) {
  	  result <- "Problem occurs. Please check your exp_hom setttings"
	} else {
  	  result <- "Problem occurs. Please check your data"
	}

    #system(command)
    #output_lines <- readLines(temp_file)

    #unlink(temp_file)
    #t_tmp <- capture.output(findGSE(path='input_histo/', samples=paste0(input$outfile,'.histo'), sizek=input$sizek, exp_hom=input$exp_hom, ploidy=input$ploidy, range_left=input$range_left, range_right=input$range_right, xlimit=input$xlimit, ylimit=input$ylimit, output_dir='outpath/'))
    #Sys.sleep(2)
    #t1 <- R.version.string
    t_count <- try(system("echo $((`cat user_num`+1)) > user_num"))
    session$sendCustomMessage(type = 'testmessage',
                              # message = paste0('The task is done!',tail(output_GSE,n=4), ' thank you for waiting'))
                              message = paste0('The task is done!',' Thank you for waiting.'))
    shinyjs::enable("submit")
    shinyjs::enable("draw_plot")
    #shinyjs::hide("double_click")
    updateTabsetPanel(session,"tabs", selected = "Download")
    showNotification(paste("Congrates, you are the current user number: ",system("echo $((`cat user_num`))",intern=TRUE)),duration = 3)
  })

  observeEvent(input$example_sel, {
      selected_species <- input$example_sel
      if (selected_species == "javanica_tetraploid") {
        updateNumericInput(session, "exp_hom", value = 200)
        updateNumericInput(session, "ploidy", value = 4)
        updateActionButton(session, "example", label = paste("Use", selected_species, "data"))
      } else if (selected_species == "potato_tetraploid") {
        updateNumericInput(session, "exp_hom", value = 200)
        updateNumericInput(session, "ploidy", value = 4)
        updateActionButton(session, "example", label = paste("Use", selected_species, "data"))
      } else if (selected_species == "wheat_hexaploid") {
        updateNumericInput(session, "exp_hom", value = 150)
        updateNumericInput(session, "ploidy", value = 6)
        updateActionButton(session, "example", label = paste("Use", selected_species, "data"))
      } else if (selected_species == "strawberry_octoploid") {
        updateNumericInput(session, "exp_hom", value = 150)
        updateNumericInput(session, "ploidy", value = 8)
        updateActionButton(session, "example", label = paste("Use", selected_species, "data"))
      } else if (selected_species == "Chinese_sturgeon_octoploid") {
        updateNumericInput(session, "exp_hom", value = 100)
        updateNumericInput(session, "ploidy", value = 8)
        updateActionButton(session, "example", label = paste("Use", selected_species, "data"))
      }

  })

  observeEvent(input$draw_plot,{
    #hetfit_count_file = paste("input_histo/", "outfile/", "v1.94.est.",paste0(input$outfile,'.histo'),".genome.size.estimated.k",input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt", sep="")
    png_file = paste0("input_histo/", "outfile/", input$outfile , ".histo_hap_genome_size_est.png")
    if(file.exists(png_file)){
      # t2 <- try(system("awk \'{if(match($1,/^>/))print substr($1,RSTART+1, RLENGTH+100)}\' output.txt", intern = TRUE))
      # updateSelectInput(session, "seq_name",
      #                   choices = t2)
      # shinyjs::show("seq_name")
      shinyjs::enable("ResultDown")
      shinyjs::show("myImage")
      # shinyjs::show("seq_table")
      shinyjs::show("dVisualize")
      shinyjs::show("table")
      #shinyjs::show("panel_varna")
      output$myImage <-renderImage({
        list(src = paste0("input_histo/", "outfile/", input$outfile , ".histo_hap_genome_size_est.png"))
        #list(src = paste0("6JQ5-2D-bpseq.txt_radiatenew.png"), width = "100",align = "center")

      })
      #startAnim(session = getDefaultReactiveDomain(), "myImage", "bounceInRight")
      #shinyjs::show("inc")
    }else{
      return()
    }
    })
  
  seq_name_list <- reactive({
    if(input$draw_plot && file.exists('output.txt')){
      t2 <- try(system("awk \'{if(match($1,/^>/))print substr($1,RSTART+1, RLENGTH+100)}\' output.txt", intern = TRUE))
      t3 <- try(system("awk \'{if(match($1,/^[lm]/))print $1}\' output.txt", intern = TRUE))
      t4 <- try(system("awk \'{if(match($1,/^[0-9]/))print $1}\' output.txt", intern = TRUE))
      seq_name_list_all <- list(name=t2,seq=t3,structure=t4)
      seq_name_list_all
      }else{
      return()
    }
  })
  
  # ' observeEvent(input$seq_name,{
  # '   
  # '   seq_name_list <- seq_name_list()
  # '   index = which(seq_name_list$name %in% input$seq_name)
  # '   
  # '   #updateActionButton()
  # '   link = paste0("window.open('http://nibiru.tbi.univie.ac.at/forna/forna.html?id=url/",seq_name_list$name[index],"&sequence=",seq_name_list$seq[index],"&structure=",seq_name_list$structure[index],"')")
  # '   getPage<-function(seq_name_list,index) {
  # '     return(tags$iframe(src = "http://www.baidu.com" #paste0("http://nibiru.tbi.univie.ac.at/forna/forna.html?id=url/",seq_name_list$name[index],"&sequence=",seq_name_list$seq[index],"&structure=",seq_name_list$structure[index])
  # '                        , style="width:100%;",  frameborder="0"
  # '                        ,id="iframe"
  # '                        , height = "500px"))
  # '   }
  # '   output$inc<-renderUI({
  # '     getPage(seq_name_list,index)
  # '   })
  # '   output$seq_table <- renderTable({
  # '     data.frame('item'=c('name',  'seq', 'structure'),
  # '                'value'=c(seq_name_list$name[index], seq_name_list$seq[index], seq_name_list$structure[index]),
  # '                #'value' = c(index,seq_name_list$seq[1],input$seq_name),
  # '                stringsAsFactors = F)
  # '     
  # '   })
  # '   #onclick("Visualize",runjs("window.open('http://www.baidu.com')"))
  # '   #onclick("Visualize",runjs(link))
  # '   })
  
  out_db <- reactive({
    out_file_base <- paste0("v1.94.est.", input$outfile, ".histo")
    if (!file.exists(file.path("input_histo", "outfile", paste0(out_file_base, ".genome.size.estimated.k", input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt")))) {
      out_file_base <- paste0(out_file_base, "_scaled")
    }
    hetfit_count_file <- file.path("input_histo", "outfile", paste0(out_file_base, ".genome.size.estimated.k", input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt"))
    if(input$draw_plot && file.exists(hetfit_count_file)){
      read.table(hetfit_count_file,header =FALSE)
    }else{
      return()
    }
  })

  out_haploid_size <- reactive({
    haploid_size_file <- paste0("input_histo/outfile/", input$outfile, ".histo_haploid_size.csv")
    scaled_haploid_size_file <- paste0("input_histo/outfile/", input$outfile, ".histo_scaled_haploid_size.csv")

    if (input$draw_plot && file.exists(haploid_size_file)) {
      read.csv(haploid_size_file, header = TRUE, sep = ',', row.names = NULL)
    } else if (input$draw_plot && file.exists(scaled_haploid_size_file)) {
      read.csv(scaled_haploid_size_file, header = TRUE, sep = ',', row.names = NULL)
    } else {
      return(NULL)
    }
    
  })  

  observeEvent(input$seq_name,{
    #shinyjs::showElement(id= "double_click")
    #shinyjs::showElement(id= "panel_varna")
    shinyjs::showElement(id= "panel_forna")
    seq_name_list <- seq_name_list()
    index = which(seq_name_list$name %in% input$seq_name)
    
    #updateActionButton()
    #link = paste0("window.open('http://nibiru.tbi.univie.ac.at/forna/forna.html?id=url/",seq_name_list$name[index],"&sequence=",seq_name_list$seq[index],"&structure=",seq_name_list$structure[index],"')")
    # getPage<-function(seq_name_list,index) {
    #   return(tags$iframe(src = paste0("http://nibiru.tbi.univie.ac.at/forna/forna.html?id=url/",seq_name_list$name[index],"&sequence=",seq_name_list$seq[index],"&structure=",seq_name_list$structure[index])
    #                      , style="width:100%;",  frameborder="0"
    #                      ,id="iframe"
    #                      , height = "500px"))
    # }
    # output$inc<-renderUI({
    #   getPage(seq_name_list,index)
    # })
    #onclick("Visualize",runjs(link))
    output$seq_table <- renderTable({
      data.frame('feature'=c('species','name',  'pred', 'probability'),
                 'value'=c(input$species,seq_name_list$name[index], seq_name_list$seq[index], seq_name_list$structure[index]),
                # 'value' = c(index,seq_name_list$seq[1],input$seq_name),
                 stringsAsFactors = F)
      
    },caption="Your selected result:",caption.placement = getOption("xtable.caption.placement", "top"))

    
    #onclick("Visualize",runjs("window.open('http://www.baidu.com')"))
    #
  })
  
  output$table <- DT::renderDataTable(DT::datatable(
	    #out_db()[seq_name_list$name[index],]
	    #out_db(),
	    out_haploid_size(),
	    options = list(
                          searching = FALSE,  # Disable searching
                          paging = FALSE       # Disable paging
                      ),
	    caption = tags$caption(
                style = 'font-weight: bold; font-size: 18px;', 
                'Table 1: Size estimation results.'
            ),
	    escape = FALSE
	    #Table1: This is the haploid size prediction results.
	))
  out_ct <- reactive({
    ct_file_base <- paste0("v1.94.est.", input$outfile, ".histo.genome.size.estimated.k", input$sizek, "to", input$sizek, ".fitted_hetfit_count")
    hetfit_count_file <- file.path("input_histo", "outfile", paste0(ct_file_base, ".txt"))
    scaled_hetfit_count_file <- file.path("input_histo", "outfile", paste0(ct_file_base, "_scaled.txt"))

    if (input$draw_plot && file.exists(hetfit_count_file)) {
      read.table(hetfit_count_file, header = FALSE)
    } else if (input$draw_plot && file.exists(scaled_hetfit_count_file)) {
      read.table(scaled_hetfit_count_file, header = FALSE)
    } else {
      return(NULL)
    }

  })
  # observeEvent(input$ResultDown,{
  #   session$sendCustomMessage(type = 'testmessage',message = ('Your output file will be deleted after you save it!'))
  # })
  
    output$dVisualize <- downloadHandler(
    #seq_name_list <- seq_name_list()
    #index = which(seq_name_list$name %in% input$seq_name)
    #filename = function() { paste0("/home/shinyserver/UFold/results/save_varna_fig/", seq_name_list$name[index], "_radiatenew.png") },
    filename = function() {
    paste0("input_histo/outfile/",input$outfile,".histo_hap_genome_size_est.pdf")
  },
    content = function(file) {
    #files <- paste0("input_histo/", "outfile/", "potato_test", ".histo_hap_genome_size_est.pdf")
    file.copy(file.path("input_histo", "outfile",paste0(input$outfile, ".histo_hap_genome_size_est.pdf")), file)
    #zip(file, files)
  },
    #contentType = "image/png"
    contentType = "application/pdf"
    #contentType = "text/txt"
    )
  

  # output$ResultDown <- downloadHandler(
  #   filename = function(){
  #     paste("input_histo/", "outfile/", "v1.94.est.",paste0(input$outfile,'.histo'),".genome.size.estimated.k",input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt", sep="")
  #   },
  #   content = function(file){
  #     if(is.null(input$file_input)){
  #     if(input$extTable == 'csv'){
  #       write.table(out_db(), file, sep = ' ', col.names = F, row.names = F, quote = F)
  #       }else{
  #       write.table(out_ct(), file, sep = ' ', col.names = F, row.names = F, quote = F)
  #     }}else{
  #       if(input$extTable == 'csv'){
  #         write.table(out_db(), file, sep = ' ', col.names = F, row.names = F, quote = F)
  #       }else{
  #         write.table(out_ct(), file, sep = ' ', col.names = F, row.names = F, quote = F)
  #       }
  #     }
  #   }
  # )

#   output$ResultDown <- downloadHandler(
#   filename = function() {
#     "output_files.zip"
#   },
#   content = function(filename) {
#     files_to_zip <- listFilesToDownload()
    
#     files_to_zip_string <- paste("-j",shQuote(filename),shQuote(files_to_zip), collapse = ",")
#     cat(files_to_zip_string)
#     log_file <- "/var/log/shiny-server/shiny_download_log.txt"
#     sink(log_file, append = TRUE)  # 将输出写入文件
#     cat("Start of log...\n")
#     cat(files_to_zip_string)
#     #command <- sprintf("zip %s %s", shQuote(filename), files_to_zip_string)
#     system2("zip", files_to_zip_string)
#     sink()
#   },
#   contentType = "application/zip"
# )

  output$ResultDown <- downloadHandler(
  filename = function() {
    "output_files.zip"
  },
  content = function(filename) {
    files_to_zip <- listFilesToDownload()

    log_file <- "/var/log/shiny-server/shiny_download_log.txt"
    sink(log_file, append = TRUE)  # 将输出写入文件
    cat("Start of log...\n")

    # 使用 system2() 执行多个压缩命令
    for (file_to_zip in files_to_zip) {
      command <- paste("-j" ,shQuote(filename), shQuote(file_to_zip),sep=' ')
      cat("Executing command:", command, "\n")
      system2("zip", command)
    }
    
    cat("End of log...\n")
    sink()  # 停止将输出写入文件
  },
  contentType = "application/zip"
)


  listFilesToDownload <- function() {
    files <- character(0)
    print("start to zip:...")
    for (i in 1:input$ploidy) {  
      if(i == 1){
        filename_no_rescale <- paste0("/home/shiny/deploy_apps/findGSE/input_histo/", "outfile/", "v1.94.est.",paste0(input$outfile,'.histo'),".genome.size.estimated.k",input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt")
        filename_rescale <- paste0("/home/shiny/deploy_apps/findGSE/input_histo/", "outfile/",input$outfile,".histo_scaled_", i, "_rescale.histo.txt")

        if (file.exists(filename_no_rescale)) {
          #print(paste0('filename_no_rescale',i,'exists...'))
          files <- c(files, filename_no_rescale)
        }
        else if(file.exists(filename_rescale)){
          #print(paste0('filename_rescale',i,'exists...'))
          files <- c(files, filename_rescale)
        }
      }
      else{
        filename_no_rescale <- paste0("/home/shiny/deploy_apps/findGSE/input_histo/", "outfile/", "v1.94.est.",paste0(input$outfile,'.histo_',i),".genome.size.estimated.k",input$sizek, "to", input$sizek, ".fitted_hetfit_count.txt")
        filename_rescale <- paste0("/home/shiny/deploy_apps/findGSE/input_histo/", "outfile/",input$outfile,".histo_scaled_", i, "_rescale.histo.txt")
        if (file.exists(filename_no_rescale)) {
          #print(paste0('filename_no_rescale',i,'exists...'))
          files <- c(files, filename_no_rescale)
        }
        else if(file.exists(filename_rescale)){
          #print(paste0('filename_rescale',i,'exists...'))
          files <- c(files, filename_rescale)
        }
      }
      
    }

    return(files)
  }


  


})
