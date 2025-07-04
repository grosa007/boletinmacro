# GR_INDICADORES_LATAM_V
library(RODBC)
library(keyring)
library(dplyr)
library(gt)
library(stringr) # Para formatear la columna de inflación

# Acceso a Oracle
pwd <- keyring::key_get("riesgo", "estudios")
dsn <- "Oracle_riesgo"
uid <- "estudios"
con <- odbcDriverConnect(paste0("DSN=", dsn, ";UID=", uid, ";PWD=", pwd))

# Consulta a la base de datos
query <- "SELECT COUNTRY, GROW, INFLATION, INF_PERCENTIL, UNEMPLOYMENT, RATES, YIELD, CURRENCY FROM GR_INDICADORES_LATAM_V"
DATOS_LATAM <- sqlQuery(con, query)

# Cerrar la conexión a la base de datos
odbcClose(con)

# Preparación y formato de los datos para la tabla
TABLA_LATAM <- DATOS_LATAM %>%
  mutate(
    # Crear la columna combinada de Inflación (Valor y percentil)
    Inflacion_Formato = paste0(format(INFLATION, nsmall = 1), " (", format(INF_PERCENTIL, nsmall = 1), ")"),
    # Formatear el crecimiento económico como porcentaje con un decimal
    GROW = paste0(format(GROW, nsmall = 1)),
    # Formatear el rendimiento del bono a 10 años con un decimal
    YIELD = paste0(format(YIELD, nsmall = 1)),
    # Formatear la depreciación frente al dólar con un decimal
    CURRENCY = paste0(format(CURRENCY, nsmall = 1))
  ) %>%
  select(
    `País` = COUNTRY,
    `TPM` = RATES,
    `Inflación` = Inflacion_Formato,
    `Desempleo` = UNEMPLOYMENT,
    `Crec. Econ. \n(Var. Int.)` = GROW, # Salto de línea para el título
    `Bond 10yr Yield` = YIELD,
    `Deprec. vs. dólar` = CURRENCY
  ) %>%
  gt() %>%
  tab_header(
    title = md("**Indicadores Económicos Seleccionados: LATAM**"),
    subtitle = "Último dato disponible"
  ) %>%
  # Ajustar el formato numérico para las columnas donde no combinamos texto
  fmt_number(
    columns = c(`TPM`, `Desempleo`, `Bond 10yr Yield`, `Deprec. vs. dólar`),
    decimals = 1 # Un decimal para todos los números
  ) %>%
  # Alinear el texto de las columnas numéricas a la derecha
  cols_align(
    align = "right",
    columns = c(`TPM`, `Inflación`, `Desempleo`, `Crec. Econ. \n(Var. Int.)`, `Bond 10yr Yield`, `Deprec. vs. dólar`)
  ) %>%
  # Alinear el texto de la columna País a la izquierda
  cols_align(
    align = "left",
    columns = `País`
  ) %>%
  # Estilos para el encabezado de las columnas
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  ) %>% 
  tab_options(
    table.font.size = px(9),
    heading.title.font.size = px(9),
    heading.subtitle.font.size = px(9),
    column_labels.font.size = px(9)
  )
