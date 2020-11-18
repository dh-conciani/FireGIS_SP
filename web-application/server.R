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
    HTML("<center><b>Bem-vindo</center></b>"),
    HTML('<center><img src="https://i.ibb.co/Lx83jRd/logo-1.png" 
                 width="350" height="175"></center>'),
    tags$hr(),
    HTML("<b>Produto:</b> Área queimada anual - Dia de detecção por pixel (1-365)<br>"),
    HTML("<b>Baseado em</b>: Classificação de cenas Landsat (TM/ ETM+/ OLI)</br>"),
    HTML("<b>Período</b>: 1985 até 2018<br>"),
    HTML("<b>Resolução espacial:</b> 30x30 metros por pixel<br>"),
    HTML("<b>Resolução temporal:</b> 16 dias<br>"),
    tags$hr(),
    HTML("Este produto apresenta erros de omissão e comissão. Caso identifique algum deles você pode nos reportar usando o sistema 'informar erro'. Atualizações para permitir correções colaborativas estão em curso e devem ser implementadas no futuro. <br>"),
    HTML("<br>Para maiores informações, acesse: [Conciani et al., in prep]"),
    easyClose = FALSE,
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
      string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN.tif")
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
        string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN.tif")
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
        string_name <- paste0(raster_path,wrs,"_",year,"_JDBAMIN.tif")
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
    return(ggplot(as.data.frame(r[!r==0]), aes (x= r[!r==0])) +
      geom_histogram(colour="black", fill="green4", bins= 12, alpha=0.7) +
      scale_x_continuous(breaks = c(30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 365),
                         labels = c("J","F","M","A","M","J","J","A","S","O","N","D")) +
      xlab("mês") + ylab("n de pixel queimado") + ggtitle ("Sazonalidade do fogo") +
      theme_classic())
  }
  output$hist <- renderPlot ({
    if (is.null(input$temporal_filter) || input$temporal_filter == "")
      return (NULL)
    calc_hist()
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