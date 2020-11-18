bootstrapPage(
  title = NULL,
  ## Definir CSS e Java script dos componentes
  useShinyjs(),
           
  div(class="outer", tags$head(includeCSS("styles.css"))),
  ## Estilo do popup de help
   tags$style(HTML('.popover-title {color:blue; font-weight:bold}}
                    .popover-content {color:blue; font-weight:italic}
                    .main-sidebar {z-index:auto;}')),
  
  ## Definir o CSS do mapa interativo e plotar em tela cheia 
  div(class= 'outer',
      tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
      leafletOutput("map", width="100%", height="100%")),
  
  ## Insert foot
  absolutePanel(
    id = "foot", 
    fixed = FALSE,
    draggable = FALSE, 
    top = "auto", left = 0, right = "auto", bottom = 0,
    width = "100%", height = "auto",
    
    HTML('<center> <b>Apoio: &nbsp; &nbsp; </b> <img src="https://logodownload.org/wp-content/uploads/2015/02/unesp-logo-5.png" width="100" height="33">
                  &nbsp;&nbsp; <img src="https://www.logolynx.com/images/logolynx/39/39689184e2762613f0d38d3695c5d003.jpeg" width="100" height="25">
                  &nbsp;&nbsp; <img src="https://1.bp.blogspot.com/-BDHEoAg7wNQ/XY9ZEIICkeI/AAAAAAACXmc/buKFKKFUFmsOhg6SYgwuItfW6xo7gsgQgCLcBGAsYHQ/w600-h315-p-k-no-nu/uema-logotipo-indagacao-site.jpg" width="120" height="55">
                  &nbsp;&nbsp; <img src="https://logodownload.org/wp-content/uploads/2016/10/cnpq-logo.png" width="85" height="37"> 
         </center>')),
  
  ## Criar menu
  absolutePanel(
                 id = "main_menu", 
                 fixed = FALSE,
                 draggable = FALSE, 
                 top = 10, left = "20", right = "auto", bottom = "auto",
                 width = 350, height = "auto",
                 tags$h4(tags$b("FireGIS Visualizer 🔥")),
                 tags$hr(),
  
  ## Select spatial filter
  selectInput(inputId = "spatial_filter",
              label = "Filtro espacial",
              choices = c("", "Município", "Unidade de Conservação"),
              multiple = FALSE, selected = ""),
  
  ## Select city
  conditionalPanel("input.spatial_filter == 'Município'",
                   use_bs_popover(),
                   selectInput(inputId = "municipio",
                                label = "Município",
                                choices = c (""),
                                multiple = FALSE, selected = "") %>%
                     shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                                              bs_embed_popover(title     =  "Info:", 
                                                               content   =  "Limites municipais fornecidos pelo IBGE (Instituto Brasileiro de Geografia e Estatistica)",
                                                               placement = "left",
                                                               trigger   = "hover",
                                                               options   = list(container = "body")))),
                     
  
  ## Select protected area
  conditionalPanel("input.spatial_filter == 'Unidade de Conservação'",
  selectInput(inputId = "category",
              label = "Categoria",
              choices = c (""),
              multiple = FALSE, selected = "") %>%
    shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "Info:", 
                                              content   =  "Baseado nas classes do Sistema Nacional de Unidades de Conservação (SNUC - Lei Federal 9985 /2000)",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body"))),
  
  conditionalPanel("input.category != ''",
  selectInput(inputId = "uc",
              label = "Unidade de Conservação",
              choices = c (""),
              multiple = FALSE, selected = "") %>%
    shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "Info:", 
                                              content   =  "Protected area borders provided by SIMA/SP (Secretaria de Infraestrutura e Meio Ambiente do Estado de Sao Paulo) and MMA/BR (Ministerio do Meio Ambiente do Brasil)",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body"))),
  
  conditionalPanel("input.uc != ''",
                   div(style="display:inline-block",
                   prettyCheckbox (inputId = "add_buffer",
                                   label = tags$span(style="color:green", "Adicionar zona de amortecimento"),
                                   value = FALSE,
                                   icon = icon ("check"),
                                   animation = "smooth",
                                   status = "success",
                                   shape = "curve"),
                   style="float:right")),
  
  conditionalPanel("input.add_buffer == true",
                   sliderInput(inputId = "buffer_size",
                               label = "Raio da zona de amortecimento (km)",
                               min = 1,
                               max = 20,
                               value = 10)))),
  
  ## Selecionar filtro temporal
  conditionalPanel("input.municipio != '' || input.uc != ''", 
  selectInput(inputId = "temporal_filter",
              label = "Área queimada - Ano",
              choices = c("", seq(1985,2018))) %>%
        shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "Info:", 
                                              content   =  "O valor de cada pixel representa o dia juliana (1-365) em que uma queima foi detectada",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body")))),
  
  ## create histogram
  conditionalPanel("input.temporal_filter != ''", 
                   tags$hr(), 
  plotOutput("hist", height = 220),
  
  ## create report tool option
  helpText("Nota: Ajude-nos a melhorar a qualidade deste produto :)"),
  prettyCheckbox (inputId = "active_report_tool",
                  label = tags$b(tags$span(style="color:red", "Informar erro")),
                  value = FALSE,
                  icon = icon ("check"),
                  animation = "smooth",
                  status = "danger",
                  shape = "curve"))
  ),
  
  ## create report panel
  conditionalPanel("input.active_report_tool == true",
                   absolutePanel(
                     id = "report_tool", 
                     fixed = FALSE,
                     draggable = FALSE, 
                     top = 10, left = 410, right = "auto", bottom = "auto",
                     width = 250, height = "auto",
                     tags$h4(tags$b("Informar erro")),
                     tags$hr(),
                     actionButton(inputId = "report_comission",
                                  label = "Erro de comissão",
                                  class = "btn-danger"),
                     helpText("Quando uma área aparece como queimada no mapa mas não queimou na realidade"),
                     tags$hr(),
                     
                     actionButton(inputId = "report_omission",
                                 label = "Erro de omissão",
                                 class = "btn-warning"),
                     helpText("Quando uma área queimou na realidade mas não aparece no mapa")
                     ))
  
  
)

