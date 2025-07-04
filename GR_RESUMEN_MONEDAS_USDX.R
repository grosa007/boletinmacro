# GR_RESUMEN_MONEDAS_USDX
library(RODBC)
library(keyring)
library(dplyr)
library(gt)

# Acceso a Oracle
pwd <- keyring::key_get("riesgo","estudios")
# key_set("riesgo", "estudios")
dsn <- "Oracle_riesgo"
uid <- "estudios"
con <- odbcDriverConnect(paste0("DSN=", dsn, ";UID=", uid, ";PWD=", pwd))

query <- "SELECT * FROM GR_RESUMEN_MONEDAS_USDX"

datos_tabla <- sqlQuery(con, query)

fecha_maxima <- datos_tabla$FECHA[1]
tabla_final <- datos_tabla %>% select(VARIABLE, VALOR_18_SEP_VARIATION,ANUAL_VARIATION,PERCENTIL) %>%
  gt() %>%
  tab_header(
    title = md("**Resumen de Monedas en Relación al USDX**"),
     subtitle =  (format(fecha_maxima, "%B de %Y"))
  ) %>%
  # Formato de números: porcentajes y percentiles
  fmt_number(
    columns = c('VALOR_18_SEP_VARIATION', 'ANUAL_VARIATION'),
    decimals = 1, # Un decimal
    suffix = "%"  # Añadir el símbolo de porcentaje
  ) %>%
  fmt_number(
    columns = 'PERCENTIL',
    decimals = 0 # Sin decimales para el percentil
  ) %>%
  cols_label(
    VARIABLE = md("**Variable**"), 
    VALOR_18_SEP_VARIATION = md("**Var. al 18-Sep-2024 (%)**"), 
    ANUAL_VARIATION = md("**Var. Interanual (%)**"),
    PERCENTIL = md("**Perc de Var. Inter. Total**")
  ) %>% 
  tab_options(
    table.font.size = px(9),
    heading.title.font.size = px(9),
    heading.subtitle.font.size = px(9),
    column_labels.font.size = px(9)
  )


odbcClose(con)