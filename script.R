# Verificar se o pacote está instalado. Se não, prossegue com a instalação
if(!require(readr)) install.packages("readr")

#Carregando o pacote readr
library(readr)

dados <- read.csv2(file = "e_sus_notifica.csv")

if(!require(foreign)) install.packages("foreign")
library(foreign)

dados_sinan <- read.dbf(file = "NINDINET.dbf", as.is = TRUE)

head(dados_sinan)

library(readxl)

dados_sivep <- read_excel("sivep_gripe.xlsx", sheet = "SIVEPGRIPE", skip = 0)
head(dados_sivep)


#Recodificar a coluna CLASSI_FIN usando a função factor e salvar em nova coluna CS_CLASSI_FIN_N

dados_sivep$CS_CLASSI_FIN <- factor(
  x = dados_sivep$CLASSI_FIN, 
  levels = c("1","2","3","4","5"),
  labels = c(
    "SRAG por influenza",
    "SRAG por outro vírus respiratório",
    "SRAG por outro agente etiológico",
    "SRAG não especificado",
    "SRAG por COVID-19"
  )
)

dados_sivep$CS_ESCOL_N <- factor(
  x = dados_sivep$CS_ESCOL_N,
  levels = c("0","1","2","3","4","5","9"),
  labels = c(
    "Sem escolaridade",
    "Fundamental 1º ciclo",
    "Fundamental 2º ciclo",
    "Médio",
    "Superior",
    "Não se aplica",
    "Ignorado"
  ),
  ordered = TRUE
)
