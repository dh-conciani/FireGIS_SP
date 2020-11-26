function(input, output, session) {
  
  ## load leaflet
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE, attributionControl=FALSE)) %>%
      addMapPane("esri_sat", zIndex = 1) %>%
      addMapPane("google_sat", zIndex = 1) %>% 
      addMapPane("osm", zIndex = 1) %>% 
      addMapPane("esri_ref", zIndex = 430) %>% 
      ### Adiciona a camada WMS 
      addWMSTiles(
        ### ESRI Satellite Imagery 
        "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
        layers = NULL,
        options = WMSTileOptions(format = "image/png", transparent = TRUE, pane="esri_sat"),
        attribution = "Tiles Esri",
        group = "ESRI Imagery"
      ) %>%
      addWMSTiles(
        ### Google Imagery
        "https://mts1.google.com/vt/lyrs=s&hl=en&src=app&x={x}&y={y}&z={z}&s=G",
        layers = NULL,
        options = WMSTileOptions(format = "image/png", transparent = TRUE, pane="google_sat"),
        attribution = "Google Imagery",
        group = "Google Imagery"
      ) %>%
      addWMSTiles(
        ### Open Street Maps
        "http://tile.openstreetmap.org/{z}/{x}/{y}.png",
        layers = NULL,
        options = WMSTileOptions(format = "image/png", transparent = TRUE, pane="osm"),
        attribution = "Open Street Map",
        group = "Open Street Map"
      ) %>%
      addWMSTiles(
        ### ESRI References - países, estados, cidades, pontos de referência, rios, etc...
        "http://server.arcgisonline.com/arcgis/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}",
        layers = NULL,
        options = WMSTileOptions(format = "image/png", transparent = TRUE, pane="esri_ref"),
        attribution = "Esri Reference",
        group = "ESRI References"
      ) %>% 
      addLayersControl(baseGroups = c("Google Imagery", "ESRI Imagery", "Open Street Map"),
                       overlayGroups = c("ESRI References", "Path/Row tile"),
                       options = layersControlOptions(collapsed = TRUE),
                       position = "topright") %>%
      setView (lng = -49, lat = -22.5, zoom= 7) %>%
      htmlwidgets::onRender("function(el, x) {
      L.control.zoom({ position: 'topright' }).addTo(this)
    }") # %>%
    #  htmlwidgets::onRender("function(el, x) {
    #  L.control.attribution({ position: 'bottomright' }).addTo(this)
  
      })
  
  ## show welcome dialog
  ###### 
  showModal(modalDialog(
    title = NULL,
    HTML("<center><b>Bem-vindo à plataforma</center></b>"),
    HTML('<center><img src="https://i.ibb.co/X58rpzq/logo-1.png" 
                 width="350" height="175"></center>'),
    HTML("<center>O FireGIS é uma plataforma interativa para acesso, visualização e análise de áreas queimadas no Cerrado paulista</center>"),
    tags$hr(),
    HTML("<b>Ficha técnica:</b><br>"),
    HTML("<b>Origem:</b> Classificação pixel-pixel de 4153 cenas Landsat (TM, ETM+, OLI)<br>"),
    HTML("<b>Resolução espacial:</b> 30x30 metros/pixel<br>"),
    HTML("<b>Resolução temporal:</b> 16 dias<br>"),
    HTML("<b>Período:</b>1985 - 2018<br>"),
    HTML("<b>Acurácia média:</b> 79%</b><br>"),
    HTML("<b>Erro médio:</b> Omissão= 16% | Comissão = 9%<br>"),
    tags$hr(),
    HTML("<b>Produtos disponíveis:</b><br>"),
    HTML("I.   Área queimada anual - Dia juliano de detecção por pixel (1-365)<br><br>"),
    HTML("<b>Produtos em implementação:</b><br>"),
    HTML("II.  Contagem de queimas - Número de anos em que um mesmo pixel foi detectado como área queimada (0-34)<br>"),
    HTML("III. Última queima - Último ano que uma queima foi detectada em cada pixel (1985-2018)<br><br>"),
    easyClose = FALSE,
    size= "l",
    footer = modalButton("Acessar")
  ))
  ######
  
  ## create a empty reactive polygon to receive spatil filters
  ## user spatial filter reactive
  value_polygon <- reactiveValues(sp_filter = SpatialPolygons(list()), data= data.frame (NULL, stringsAsFactors = F))
  ## fireland extent 
  value_polygon2 <- reactiveValues(sp_extent = SpatialPolygons(list()), data= data.frame (NULL, stringsAsFactors = F))
  ## buffer from protected areas
  value_polygon3 <- reactiveValues(sp_filter = SpatialPolygons(list()), data= data.frame (NULL, stringsAsFactors = F))
  
  ## reactive value for buffer menu
  v <- reactiveValues(valueButton = 0)
  reset_v <- function () {v$valueButton = 0}
  increase_v <- function () {v$valueButton = v$valueButton + 1}
  
  ## function to load product extent
  load_wrs <- function () {
    wrs_pol <- readOGR(dsn = vector_path, layer = "wrs_path_row")
    return (wrs_pol)
  }
  wrs_label <- function () {
    vec <- load_wrs()
    return (vec$path_row) 
  }
    
    ## function to compute buffer zones
    compute_buffer <- function () {
      value_polygon3$sp_filter <- buffer (value_polygon$sp_filter, width = input$buffer_size / 100)
    }
  
  
  ## load fireland product considering spatial filter
  load_product <- function () {
    if (input$temporal_filter == "")
      return ("pass")
    if (input$temporal_filter == 2012)
      return (NULL)
    if (input$spatial_filter == "Município") {
      vec <- value_polygon$sp_filter 
      wrs <- vec$PR
      year <- input$temporal_filter
      string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN_5HA.tif")
      print (string_name)
      r_product <- raster (string_name)
      vec_transf <- spTransform(vec, proj4string(r_product))
      croped_product <- crop (r_product, vec_transf, snap= 'out')
      croped_product <- mask (croped_product, vec_transf)
      return (croped_product)
    }
    
    if (input$spatial_filter == "Unidade de Conservação") {
      if (input$add_buffer == TRUE) {
        vec <- value_polygon3$sp_filter 
        vec_ref <- value_polygon$sp_filter
        wrs <- vec_ref$PR
        year <- input$temporal_filter
        string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN_5HA.tif")
        print (string_name)
        r_product <- raster (string_name)
        vec_transf <- spTransform(vec, proj4string(r_product))
        croped_product <- crop (r_product, vec_transf, snap= 'out')
        croped_product <- mask (croped_product, vec_transf)
        return (croped_product)
      }
      
      if (input$add_buffer == FALSE) {
        vec <- value_polygon$sp_filter 
        wrs <- vec$PR
        year <- input$temporal_filter
        string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN_5HA.tif")
        print (string_name)
        r_product <- raster (string_name)
        vec_transf <- spTransform(vec, proj4string(r_product))
        croped_product <- crop (r_product, vec_transf, snap= 'out')
        croped_product <- mask (croped_product, vec_transf)
        return (croped_product)
      }
    }
  }
  
  # calc histogram based on spatial/temporal filter
  calc_hist <- function () {
    r <- load_product()
    spatial <- spTransform(value_polygon$sp_filter, proj4string(r))
    r_buffer <- mask (r, spatial, inverse= TRUE)
    r_uc <- mask(r, spatial)

    if (input$spatial_filter == "Município")
    return(ggplot(as.data.frame(r[!r==0]), aes (x= r[!r==0])) +
      geom_histogram(colour="black", fill="green4", bins= 12, alpha=0.7) +
      scale_x_continuous(breaks = c(30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365),
                         labels = c("J","F","M","A","M","J","J","A","S","O","N","D")) +
      xlab("mês") + ylab("n de pixel queimado") + ggtitle ("Sazonalidade das queimas") +
      theme_classic())
    
    if (input$spatial_filter == "Unidade de Conservação") {
      if (input$add_buffer == FALSE) 
        return(ggplot(as.data.frame(r[!r==0]), aes (x= r[!r==0])) +
                 geom_histogram(colour="black", fill="green4", bins= 12, alpha=0.7) +
                 scale_x_continuous(breaks = c(30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365),
                                    labels = c("J","F","M","A","M","J","J","A","S","O","N","D")) +
                 xlab("mês") + ylab("n de pixel queimado") + ggtitle ("Sazonalidade das queimas") +
                 theme_classic())
      
      if (input$add_buffer == TRUE) {
        print ("buffer ativado")
        df_uc <- as.data.frame(r_uc[!r_uc==0])
        df_buffer <- as.data.frame(r_buffer[!r_buffer==0])
        
        ## insert data into empty objectrs when it occurs
        if (nrow(df_uc) == 0){
          df_uc[1, ] <- NA
          df_uc[1] <- NA
        }
        if (nrow(df_buffer) == 0){
          df_buffer[1, ] <- NA
          df_buffer[1] <- NA
        }
        
        colnames(df_uc)[1] <- "value"; df_uc$lab <- "UC"
        colnames(df_buffer)[1] <- "value"; df_buffer$lab <- "Buffer"
        df <- rbind(df_uc, df_buffer)
       
        return(ggplot(df, aes (x= value, fill= lab)) +
                 geom_histogram(bins= 12, alpha=0.7, position="stack") +
                 scale_fill_manual(values=c("red","blue")) + 
                 scale_x_continuous(breaks = c(30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365),
                                    labels = c("J","F","M","A","M","J","J","A","S","O","N","D")) +
                 xlab("mês") + ylab("n de pixel queimado") + ggtitle ("Sazonalidade das queimas") +
                 labs(fill = "Legenda") +
                 theme_classic())
      }
    }
  }

    
  output$hist <- renderPlot ({
    if (is.null(input$temporal_filter) || input$temporal_filter == "")
      return (NULL)
    calc_hist()
  })
  
  ## calc total burned area based on spatial/temporal filter
  calc_total_area <- function () {
    r <- load_product()
    values <- getValues (r)
    values <- na.omit(values)
    return (length(values))
  }
  calc_uc_area <- function () {
    r <- load_product()
    spatial <- spTransform(value_polygon$sp_filter, proj4string(r))
    r_uc <- mask(r, spatial)
    values <- getValues(r_uc)
    values <- na.omit (values)
    return (length(values))
  }
  calc_buffer_area <- function () {
    r <- load_product()
    spatial <- spTransform(value_polygon$sp_filter, proj4string(r))
    r_buffer <- mask (r, spatial, inverse= TRUE)
    values <- getValues(r_buffer)
    values <- na.omit (values)
    return (length(values))
  }
  
  output$area <- renderText({
    if (is.null(input$temporal_filter) || input$temporal_filter == "")
      return (NULL)
    if (input$spatial_filter == "Unidade de Conservação")
      return(paste0("<br><b>Área queimada na UC</b>= ", calc_uc_area()*900/10000, " hectares<br><br>
                     <b>Área queimada no Buffer</b>= ", calc_buffer_area()*900/10000, "  hectares<br><br>
                    <b>Área queimada total= </b>", calc_total_area()*900/10000, " hectares<br></b><br>"))
    
    if (input$spatial_filter == "Município")
      return (paste0("<br><b>Área queimada no município</b>= ", calc_total_area()*900/10000, " hectares <br>"))
  })
  
  ## render documentacao HTML
  output$documentacao <- renderText({
    # return(paste0("<br><br><br><br><b><h3>Resumo técnico:</h3></b>
    #               <h4>Um classificador de áreas queimadas baseado em aprendizagem de máquina (Random Forest) foi treinado e ajustado a partir de uma biblioteca espectral de referência. Este classificador foi empregado na reconstrução do histórico de áreas queimadas através da classificação de 4153 cenas Landsat (TM, ETM+, OLI) entre 1985 e 2018. Etapas de pós-processamento foram aplicadas para mitigar tendências de erro em áreas urbanas, mineração, praias e áreas de alto declive. Apenas queimas maiores que 1 hectare foram compiladas no produto final.<br><br>
    #               O produto foi validado considerando um mapeamento independente para Franco da Rocha, Tanabi, Rancharia e São Carlos. Uma acurácia média de 79% foi observada, sendo maior em Rancharia (88%) e menor em Franco da Rocha (71%). Erros foram balanceados para priorizar a subestimação (16%) em relação a superestimação (9%). Ainda que espacialmente restritas, grandes superestimações foram detectadas em áreas de várzea sobre stress-hídrico, plantações de hortaliças e indústria pesada (petróleo e aço).<br></h4>"))
    return(paste0("<br><br><br><br><b><h3>Pre-print:</h3></b><h4>1. Conciani et al., in prep. Developing a machine learning based algorithm for regional time-series burned area mapping: The highly anthropized Cerrado challenge<br>",
                  actionButton(inputId= "download_p1", label= "PDF", class= "btn-primary", icon=icon("file-pdf"), size="mini"), "<br><br>
                  2. Conciani et al., in press. Human-Climate interactions shape fire regimes in the Cerrado of São Paulo State, Brazil. <i>Journal For Nature Conservation</i><br>",
                  actionButton(inputId= "download_p2", label= "PDF", class= "btn-primary", icon=icon("file-pdf"), size="mini")))
  
  })
  
  ## render contact form
  output$contato <- renderText({
    # return(paste0("<br><br><br><br><b><h3>Resumo técnico:</h3></b>
    #               <h4>Um classificador de áreas queimadas baseado em aprendizagem de máquina (Random Forest) foi treinado e ajustado a partir de uma biblioteca espectral de referência. Este classificador foi empregado na reconstrução do histórico de áreas queimadas através da classificação de 4153 cenas Landsat (TM, ETM+, OLI) entre 1985 e 2018. Etapas de pós-processamento foram aplicadas para mitigar tendências de erro em áreas urbanas, mineração, praias e áreas de alto declive. Apenas queimas maiores que 1 hectare foram compiladas no produto final.<br><br>
    #               O produto foi validado considerando um mapeamento independente para Franco da Rocha, Tanabi, Rancharia e São Carlos. Uma acurácia média de 79% foi observada, sendo maior em Rancharia (88%) e menor em Franco da Rocha (71%). Erros foram balanceados para priorizar a subestimação (16%) em relação a superestimação (9%). Ainda que espacialmente restritas, grandes superestimações foram detectadas em áreas de várzea sobre stress-hídrico, plantações de hortaliças e indústria pesada (petróleo e aço).<br></h4>"))
    return(paste0("<br><br><br><br><b><h4>Dhemerson Conciani</b><br>
                  +55 (19) 9 9911-8603 <br>
                  <a href= 'mailto:dhemerson.conciani@unesp.br'>dhemerson.conciani@unesp.br</a><br>
                  Departamento de Biodiversidade - UNESP"))
    
  })
  
  ## load cities list
  mun_list = reactive ({
    if (input$spatial_filter == "Município") {
      mun <- read.table (paste0(varlis_path, "municipios.txt"), sep="\t",  encoding = "latin1")
      return (mun$V1)
    }
  })
  observe ({
    updateSelectInput(session, "municipio",
                      choices = c("", mun_list()))
  }) # update city variable
  
  ## load categories
  cat_list = reactive ({
    if (input$spatial_filter == "Unidade de Conservação") {
      cat <- read.table (paste0(varlis_path, "unidades_conservacao.txt"), sep="\t", header=TRUE, encoding = "latin1")
      return (sort(cat$CATEGORIA))
    }
  })
  observe ({
    updateSelectInput(session, "category",
                      choices = c("", cat_list()))
  })
  
  ## load protected area list
  uc_list = reactive ({
    if (input$spatial_filter == "Unidade de Conservação") {
      if (input$category != "") {
      uc <- read.table (paste0(varlis_path, "unidades_conservacao.txt"), sep="\t", header=TRUE,  encoding = "latin1")
      uc <- subset(uc, CATEGORIA == input$category) 
      return (sort(uc$UNIDADE))
      }
    }
  })
  observe({
  updateSelectInput(session, "uc",
                    choices = c("", uc_list()))
  }) # update protected area variable
  
  ## open manager menu
  observeEvent(input$login_gestor, {
    showModal(modalDialog(
      title = "Módulo de edição - Em desenvolvimento",
      textInput(inputId= "usuario", label= "Usuário", value = "gestor@instituicao.br", width= 200),
      passwordInput(inputId= "senha", label= "Senha", value = "testedeesenha", width= 200),
      actionButton(inputId = "login", label= "Entrar", class = "btn-primary", size= "mini"),
      footer = modalButton("Voltar")
    ))
  })
  
  ## download pre-prints (p1)
  observeEvent(input$download_p1, {
    showModal(modalDialog(
      title = "Download do Pre-print",
      tags$h4("Disponível em breve"),
      footer = modalButton("Voltar")
    ))
  })
  ## download pre-prints (p2)
  observeEvent(input$download_p2, {
    showModal(modalDialog(
        title = "Download do Pre-print",
        tags$h4("Disponível em breve"),
        footer = modalButton("Voltar")
    ))
  })
  
  ## load polygon that matches to spatial filter
  ## if filter as city:
  observeEvent(input$municipio, {
    if (input$spatial_filter == "" || input$spatial_filter == "Unidade de Conservação" || input$spatial_filter == "Draw Polygon")
      return (NULL)
    if (nchar(input$municipio) == 0)
      return (NULL)
    vec <- st_read (dsn = vector_path, layer = "municipios_wrs")
    print (input$municipio)
    vec <- subset (vec, NM_MUN == input$municipio)
    vec <- as(vec, "Spatial")
    value_polygon$sp_filter <- vec
  })
  ## if filter as protected area:
  observeEvent(input$uc, {
    if (input$spatial_filter == "" || input$spatial_filter == "Município" || input$spatial_filter == "Draw Polygon" ||
        input$uc == "")
      return (NULL)
    print ("carregar uc")
    print (input$uc)
    vec <- st_read (dsn = vector_path, layer = "unidades_conservacao")
    print (input$uc)
    vec <- subset (vec, UNIDADE == input$uc)
    vec <- st_zm (vec)
    vec <- as(vec, "Spatial")
    value_polygon$sp_filter <- vec
  })
  
  
  ##update leaflet with fireland extent
  observe({
  value_polygon2$sp_extent <- load_wrs()
  leafletProxy("map") %>% 
    addMapPane("polygons", zIndex = 420) %>%
    addPolygons(data= value_polygon2$sp_extent, layerId = row.names(value_polygon2$sp_extent),
                #### edit polygon render parameters
                weight= 2, 
                col = "yellow",
                fillColor = "white", 
                fillOpacity = 0, 
                opacity=1, 
                group = "Path/Row tile",
                options = pathOptions(pane="polygons"),
                #### edit hover effects
                highlightOptions = highlightOptions(color = "red", weight = 3,
                                                    bringToFront = TRUE),
                label = wrs_label()) %>%
    fitBounds (lng1= extent(bbox(value_polygon2$sp_extent))@xmin, lat1=  extent(bbox(value_polygon2$sp_extent))@ymin, 
               lng2=  extent(bbox(value_polygon2$sp_extent))@xmax, lat2=  extent(bbox(value_polygon2$sp_extent))@ymax)
    })
  
  ## update leaflet with user's spatial filter
  observe({
    if (input$spatial_filter == "Município") { 
      print ("filter city enabled")
      print ("city names as:")
      print (input$municipio)
     if (nchar(input$municipio) == 0)
        return (NULL)
        print ("insert poplygon enabled to city")
     leafletProxy("map") %>% 
        clearGroup("Spatial") %>%
        hideGroup("Path/Row tile") %>%
        hideGroup("ESRI References") %>%
        addMapPane("polygons", zIndex = 420) %>%
        addPolygons(data= value_polygon$sp_filter, layerId = row.names(value_polygon$sp_filter),
                    #### edit polygon render parameters
                    weight= 2, 
                    col = "white",
                    fillColor = "white", 
                    fillOpacity = 0, 
                    opacity=1, 
                    group = "Spatial",
                    options = pathOptions(pane="polygons")) %>%
        fitBounds (lng1= extent(bbox(value_polygon$sp_filter))@xmin, lat1=  extent(bbox(value_polygon$sp_filter))@ymin, 
                   lng2=  extent(bbox(value_polygon$sp_filter))@xmax, lat2=  extent(bbox(value_polygon$sp_filter))@ymax)
    }
    
    
    
    if (input$spatial_filter == "Unidade de Conservação") { 
      print ("filter protected area enabled")
      print ("protected area as:")
      print (input$uc)
      if (nchar(input$uc) == 0)
        return (NULL)
      print ("insert poplygon enabled to protected area")
      
      if (input$add_buffer == TRUE) {
        print ("insert buffer size")
        print (input$buffer_size)
        compute_buffer()
        leafletProxy("map") %>% 
          clearGroup("Spatial") %>%
          hideGroup("Path/Row tile") %>%
          hideGroup("ESRI References") %>%
          addMapPane("polygons", zIndex = 420) %>%
          addPolygons(data= value_polygon$sp_filter, layerId = row.names(value_polygon$sp_filter),
                      #### edit polygon render parameters
                      weight= 2, 
                      col = "white",
                      fillColor = "white", 
                      fillOpacity = 0, 
                      opacity=1, 
                      group = "Spatial",
                      options = pathOptions(pane="polygons")) %>%
          
          addPolygons(data= value_polygon3$sp_filter, layerId = row.names(value_polygon3$sp_filter),
                      #### edit polygon render parameters
                      weight= 2, 
                      col = "red",
                      fillColor = "white", 
                      fillOpacity = 0, 
                      opacity=1, 
                      group = "Spatial",
                      options = pathOptions(pane="polygons")) %>%
          fitBounds (lng1= extent(bbox(value_polygon3$sp_filter))@xmin, lat1=  extent(bbox(value_polygon3$sp_filter))@ymin, 
                     lng2=  extent(bbox(value_polygon3$sp_filter))@xmax, lat2=  extent(bbox(value_polygon3$sp_filter))@ymax)
      }
      
      if (input$add_buffer == FALSE) {
      leafletProxy("map") %>% 
        clearGroup("Spatial") %>%
        hideGroup("Path/Row tile") %>%
        hideGroup("ESRI References") %>%
        addMapPane("polygons", zIndex = 420) %>%
        addPolygons(data= value_polygon$sp_filter, layerId = row.names(value_polygon$sp_filter),
                    #### edit polygon render parameters
                    weight= 2, 
                    col = "white",
                    fillColor = "white", 
                    fillOpacity = 0, 
                    opacity=1, 
                    group = "Spatial",
                    options = pathOptions(pane="polygons")) %>%
        fitBounds (lng1= extent(bbox(value_polygon$sp_filter))@xmin, lat1=  extent(bbox(value_polygon$sp_filter))@ymin, 
                   lng2=  extent(bbox(value_polygon$sp_filter))@xmax, lat2=  extent(bbox(value_polygon$sp_filter))@ymax)
      }
    }
    
  })
  
  ## update leaflet with raster product
  observe ({
    if (input$temporal_filter != "") {
      if (is.null (load_product())) {
        leafletProxy("map") %>% clearImages()
        return(showNotification(type= "error", duration = 10, "2012 em revisão, selecione outro ano"))}
          showModal(modalDialog(HTML("<center>Processando solicitação</center>"), footer = NULL))
          leafletProxy("map") %>%
            clearImages() %>%
            clearControls() %>%
            showGroup("BA Product") %>%
            addRasterImage(load_product(), tileOptions(zIndex = 430), 
                          colors = colorNumeric(c("#ac06a1", "#e31526", "#eb7c22", "#e8ef1a", "#21f055", "#047304"),
                                                 domain = seq(1,365), na.color = "transparent"), opacity = 0.8, group= "BA Product", project= TRUE, method = "ngb") %>%
            
            addLayersControl(baseGroups = c("Google Imagery", "ESRI Imagery", "Open Street Map"),
                             overlayGroups = c("ESRI References", "Path/Row tile", "BA Product"),
                             options = layersControlOptions(collapsed = TRUE),
                             position = "topright") %>%
            
            addLegend (pal = colorNumeric(c("#047304", "#21f055", "#e8ef1a", "#eb7c22", "#e31526", "#ac06a1"), 
                                          seq(1,365), 
                                          na.color = "transparent"),
                       values =  seq(1,365), 
                       title = "Dia juliano", position = "topright",
                       labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE)))
          removeModal()
      }
    })
  
  ## reset values of temporal filter when change spatial 
  observeEvent (input$spatial_filter, {
    shinyjs::reset("temporal_filter")
    shinyjs::reset("active_report_tool")
  })
  observeEvent (input$municipio, {
    shinyjs::reset("temporal_filter")
    shinyjs::reset("category")
    shinyjs::reset("uc")
    shinyjs::reset("active_report_tool")
  })
  observeEvent (input$uc, {
    shinyjs::reset("temporal_filter")
    shinyjs::reset("municipio")
    shinyjs::reset("add_buffer")
    shinyjs::reset("active_report_tool")
    })
  observeEvent (input$category, {
    shinyjs::reset("temporal_filter")
    shinyjs::reset("uc")
    shinyjs::reset("active_report_tool")
  })
  
  
}