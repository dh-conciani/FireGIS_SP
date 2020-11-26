navbarPage(theme = shinytheme("sandstone"),
  title = "FireGIS", position= "fixed-top",
  tabPanel("Plataforma",  icon = icon("map-marked"),
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
                 top = 90, left = "20", right = "auto", bottom = "auto",
                 width = 350, height = "auto",
                 tags$h4(tags$b(tags$span(style="color:white", "Menu FireGIS 🔥"))),
                 tags$hr(),
  
  ## Select spatial filter
  selectInput(inputId = "spatial_filter",
              label = tags$span(style="color:white", "Filtro espacial"),
              choices = c("", "Município", "Unidade de Conservação"),
              multiple = FALSE, selected = ""),
  
  ## Select city
  conditionalPanel("input.spatial_filter == 'Município'",
                   use_bs_popover(),
                   selectInput(inputId = "municipio",
                                label = tags$span(style="color:white", "Município"),
                                choices = c (""),
                                multiple = FALSE, selected = "") %>%
                     shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                                              bs_embed_popover(title     =  "Município:", 
                                                               content   =  "Limites municipais fornecidos pelo IBGE (Instituto Brasileiro de Geografia e Estatistica)",
                                                               placement = "left",
                                                               trigger   = "hover",
                                                               options   = list(container = "body")))),
                     
  
  ## Select protected area
  conditionalPanel("input.spatial_filter == 'Unidade de Conservação'",
  selectInput(inputId = "category",
              label = tags$span(style="color:white", "Categoria"),
              choices = c (""),
              multiple = FALSE, selected = "") %>%
    shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "Categoria:", 
                                              content   =  "Baseado nas classes do Sistema Nacional de Unidades de Conservação (SNUC - Lei Federal 9985 /2000)",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body"))),
  
  conditionalPanel("input.category != ''",
  selectInput(inputId = "uc",
              label = tags$span(style="color:white", "Unidade de Conservação"),
              choices = c (""),
              multiple = FALSE, selected = "") %>%
    shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "UC:", 
                                              content   =  "Limites fornecidos pela SIMA/SP (Secretaria de Infraestrutura e Meio Ambiente do Estado de Sao Paulo) e MMA/BR (Ministerio do Meio Ambiente do Brasil)",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body"))),
  
  conditionalPanel("input.uc != ''",
                   div(style="display:inline-block",
                   prettyCheckbox (inputId = "add_buffer",
                                   label = tags$span(style="color:Gold", "Adicionar zona de amortecimento"),
                                   value = FALSE,
                                   icon = icon ("check"),
                                   animation = "smooth",
                                   status = "success",
                                   shape = "curve"),
                   style="float:right")),
  
  conditionalPanel("input.add_buffer == true",
                   sliderInput(inputId = "buffer_size",
                               label = tags$span(style="color:white", "Raio da zona de amortecimento (km)"),
                               min = 1,
                               max = 20,
                               value = 5)))),
  
  ## Selecionar filtro temporal
  conditionalPanel("input.municipio != '' || input.uc != ''", 
  selectInput(inputId = "temporal_filter",
              label = tags$span(style="color:white", "Produto"),
              choices = c("", seq(1985,2018))) %>%
        shinyInput_label_embed(shiny_iconlink(name = "question-circle") %>%
                             bs_embed_popover(title     =  "Área queimada", 
                                              content   =  "Produtos em formato ano (ex: 1985 - 2018) referem-se às áreas queimadas anuais. COUNT refere-se ao produto que compila todos os anos da série e mostra a quantidade de vezes que um mesmo pixel foi detectado como área queimada. LASF_FIRE refere-se ao último ano da série em que um pixel foi detectado como área queimada.",
                                              placement = "left",
                                              trigger   = "hover",
                                              options   = list(container = "body"))),
  conditionalPanel("input.spatial_filter == 'Unidade de Conservação'", 
                   actionButton(inputId= "login_gestor", label= "Acesso Editor", class= "btn-warning", size="mini")))
  ),
  
  ## create statistical box
  conditionalPanel("input.temporal_filter != ''",
                   absolutePanel(
                    id= "statistical_box",
                    fixed= FALSE,
                    draggable = FALSE,
                    top = "auto", left= "auto", right = 30, bottom = 90,
                    width = 350, height = 280,
                    tabsetPanel(type="tabs", id="statistical_tabs",
                              tabPanel(tags$span(style="color:black", "Sazonalidade"), 
                    plotOutput("hist", height = 220)),
                    tabPanel(tags$span(style="color:black", "Área"),
                             htmlOutput("area", height = 220))))
                   ),
                  
  ),
  tabPanel("Documentação", icon=icon("book"),
           htmlOutput("documentacao")),
  
    tabPanel("Contato", icon=icon("mail-bulk"),
             htmlOutput("contato"))
)

