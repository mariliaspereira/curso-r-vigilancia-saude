# Instalar e carregar pacotes
pacotes <- c("foreign", "readxl", "readr", "janitor", "skimr", "stringr", "stringi", "lubridate","tidyverse")
pacotes |> walk(~{
  if (!require(.x,character.only = TRUE)) install.packages(.x)
  library(.x, character.only = TRUE)
})
          
# Importar NINDINET e usar as.is = TRUE para transformar os dados em caracteres. Visualizar.
base <- read.dbf(file = "NINDINET.dbf", as.is = TRUE)
glimpse(base)

# Criar base menor com colunas específicas
base_menor <- base |> 
  select(DT_NOTIFIC, DT_NASC, CS_SEXO, CS_RACA, ID_MN_RESI, ID_AGRAVO)

# Excluir data de nascimento da base_menor
base_menor |> 
select(-DT_NASC) |>
head()
 
# Criar base_menor_2, selecionar variáveis, usar "mutate()" para criar coluna
# as.numeric() para transformar em tipo numérico
base_menor_2 <- base |>
  select(NU_NOTIFIC, ID_AGRAVO, DT_NOTIFIC, DT_DIGITA) |>
  mutate(TEMPO_DIGITA = as.numeric(DT_DIGITA - DT_NOTIFIC))

base_menor_2 |> head()


# Importar banco cid10. Checar as variáveis.
cid10_categorias <- read_csv2("CID-10-CATEGORIAS.CSV")
colnames(cid10_categorias)

# Editar nomes de variáveis
cid10_categorias_nova <- clean_names(cid10_categorias)
colnames(cid10_categorias_nova)

# Filtros específicos
base_menor_2 |>
  filter(ID_AGRAVO == "B19", TEMPO_DIGITA > 7) |>
  head()

base_menor_2 |>
  filter(ID_AGRAVO == "B19" | ID_AGRAVO == "A279" | ID_AGRAVO == "B54") |>
  head(20)

# Agrupar notificações pelos agravos. Contar a frequência.
base_menor_2 |>
  group_by(ID_AGRAVO) |>
  count(ID_AGRAVO)

# Agrupar. Summarise para criar novas colunas de síntese de valor total e de média. 
base_menor_2 |>
  group_by(ID_AGRAVO) |>
  summarise(
    total_agravos = n(),
    media_digita = mean(TEMPO_DIGITA)) |>
  
# Ordem descrescente da média de tempo de digitação
  arrange(desc(media_digita))

# Raça/cor: novas colunas - preenchidos, total de obs, em branco, completude 
base |>
  summarise(
    total_completo = sum(!is.na(CS_RACA)),
    total_registros = n(),
    total_missing_raca = sum(is.na(CS_RACA)),
    taxa_completude = (total_completo / total_registros) * 100
  )

base |> count(CS_RACA)

# Agrupar ignorados e em branco (9 e NA)
base |>
  mutate(CS_RACA = replace_na(CS_RACA, replace = 9)) |>

count(CS_RACA)


# Cobertura vacinal - hepatite B
dados <- read_csv(file="cobertura_hepatiteb_rosas_2016_2020_A.csv")

# Transpor do formato largo para longo, definir colunas a transformar e nome da variável
# Corrigir o prefixo "ano" que ficou antes dos algarismos
dados_longos <- dados |>
  pivot_longer(
    cols = c("Ano 2016", "Ano 2017", "Ano 2018", "Ano 2019", "Ano 2020"),
    names_to = "Ano",
    values_to = "Cobertura Vacinal contra Hepatite B",      #variável nova
    names_prefix = "Ano "
  )

dados_longos

# Transformar dados de formato longo em formato largo
dados_largos <- dados_longos |>
  pivot_wider(
    names_from = "Ano",
    values_from = "Cobertura Vacinal contra Hepatite B"
  )

dados_largos


# Dados de eventos adversos pós-vacinais
eapv_2021 <- read_xlsx("notificacao_eapv_2021m.xlsx")

eapv_2021 |>
  select(imunobiologico_vacina, dose, data_da_aplicacao) |>

head()

# Dividir coluna imunobiologico, definir nomes das novas colunas, definir o separador
eapv_2021 |>
  separate(imunobiologico_vacina,
    into = c("vac_event_1", "vac_event_2", "vaci_event_3"),
    sep = "\\|"
)


# Categorização - sexo e raça/cor

base_menor |>
  mutate(
    sexo_cat = case_when(
      CS_SEXO == "M" ~ "Masculino",
      CS_SEXO == "F" ~ "Feminino",
      CS_SEXO == "I" | is.na(CS_SEXO) ~"Ignorado",
      TRUE ~ NA_character_         #se nenhum dos critérios anteriores forem atendidos, será NA
    )
  ) |>

head()

base_menor |>
  mutate(
    raca_cor_cat = case_when(
      CS_RACA == "1" ~ "Branca",
      CS_RACA == "2" ~ "Preta",
      CS_RACA == "3" ~ "Amarela",
      CS_RACA == "4" ~ "Parda",
      CS_RACA == "5" ~ "Indígena",
      CS_RACA == "9" | is.na(CS_RACA) ~ "Ignorado",
      TRUE ~ NA_character_
    )
  ) |>

  head()


# Idade e faixa etária - 2 colunas novas
# "if_else()" verifica se o código da idade é "4" (registro em anos)
# se verdadeiro, "str_sub()" extrai os dois últimos dígitos, se falso o valor será 0
base |>
  mutate(
    idade_anos = if_else(str_sub(NU_IDADE_N, 1, 1) == "4", 
                         as.numeric(str_sub(NU_IDADE_N, 2, 4)), 0),
    
    # A segunda coluna classifica a idade_anos em 4 categorias, definindo cortes
    fx_etaria = cut(idade_anos,
      breaks = c(0, 10, 20, 60, Inf),
      labels = c("0-9 anos", "10-19 anos", "20-59 anos", "60 anos e+"),
      right = FALSE
    )
  ) |>
  
  # Selecionar as variáveis que queremos utilizar.
  select(NU_NOTIFIC, ID_AGRAVO, NU_IDADE_N, idade_anos, fx_etaria) |>

  head()

# Junção com tabela de municípios

tabela_municipios <- read_excel("tabela_municipios.xlsx",
                                sheet = 1,
                                skip = 0)

# Verificar tipos de variável e transformar em integer
class(base_menor$ID_MN_RESI)
class(tabela_municipios$ID_MUNICIPIO)

tabela_municipios$ID_MUNICIPIO <- as.integer(tabela_municipios$ID_MUNICIPIO)

# Unir tabela "base_menor" com a "tabela_municipios"
left_join(
  x = base_menor,
  y = tabela_municipios,
  by = c("ID_MN_RESI" = "ID_MUNICIPIO")
) |>

head()  

# stringr e stringi - tratamento de texto

CID10 <- read_csv2("CID-10-CATEGORIAS.CSV",
                   locale = locale(encoding = "latin1"))

# Novo objeto com as seleções feitas, selecionar as linhas de interesse
nomes_cid <- CID10 |>
  slice(1:15) |> 
  
  # Transformar "DESCRICAO" em `character` 
  pull(DESCRICAO)

# Contar caracteres. Extrair caracteres entre a 1ª e a 11ª posição da linha
str_length(nomes_cid)
str_sub(nomes_cid, start = 1, end = 11) 

# Indicar a posição final da primeira palavra de cada texto
str_sub(nomes_cid, 
        start = 1, 
        end = c(6,6,6,10,6,6,8,6,9,8,11,11,11,11,11))

# Ordenar o objeto "nomes_cid" para o formato ascendente (A-Z)
str_sort(nomes_cid)

# Transformar todos as letras em minúsculas
str_to_lower(nomes_cid)

# Diferentes grafias
nomes <- c("infecções", "infeccões", "infecçoes", "infeccoes")
stri_trans_general(nomes, id = "Latin-ASCII")

# Extrair linhas onde a palavra "Tuberculose" aparece
str_subset(nomes_cid, pattern = "Tuberculose")

# Extrair linhas onde a palavra "Tuberculose" aparece, independente de maiúscula ou minúscula
str_subset(nomes_cid, pattern = fixed("tuberculose", ignore_case = TRUE))

CID10 |> 
  
  # Função "filter()" com a função "str_stars()"
  filter(str_starts(
      
      # Selecionando a variável para encontrar palavras no início da frase.
      # Ignorar se maiuscula ou minúscula
      string = DESCRICAO,
      pattern = fixed("outras", ignore_case = TRUE)
    )
  ) |> 
  
  # Selecionar as variáveis para uso
  select(CAT, DESCRICAO)

# Substituições
agravo <- "Tuberculose respiratória, com confirmação bacteriológica e histológica"
str_replace(agravo, pattern = "com", replacement = "sem")
str_replace_all(agravo, pattern = "ó", replacement = "o")

# Transformações de string em data
data_1 <- as_date("2022-05-19")
data_1
class(data_1)

as_date("19/05/2022")         #sem especificar (pode dar erro)
as_date("19/05/2022", format = "%d/%m/%Y")  #especificando o formato
as_date("01031998", format = "%d%m%Y")      #formato do SIM

# Importando base .dbf e selecionando colunas e linhas de interesse
dt_notific <- read.dbf(file = 'NINDINET.dbf') |>
  select(DT_NOTIFIC, DT_SIN_PRI, DT_NASC) |>
  slice(1:10)

dt_notific

# Somando e subtraindo datas
dt_notific$DT_NOTIFIC + 60
dt_notific$DT_NOTIFIC - 60

# Criar novo objeto e coluna com prazo de encerramento
dt_notific_2 <- dt_notific |>
  select(DT_NOTIFIC) |>
  mutate(prazo_encerramento = DT_NOTIFIC + 60)

dt_notific_2

# Diferença entre datas (em formato de tempo e inteiro)
dif_tempo <- dt_notific |>
  select(DT_NOTIFIC, DT_SIN_PRI) |>
  mutate(DIFERENCA = DT_NOTIFIC - DT_SIN_PRI)

dif_tempo_2 <- dt_notific |>
  select(DT_NOTIFIC, DT_SIN_PRI) |>
  mutate(Diferenca = as.integer(DT_NOTIFIC - DT_SIN_PRI))

dif_tempo
dif_tempo_2

# Cálculo de idade em dias

idade <- dt_notific |>
  select(DT_NASC, DT_SIN_PRI) |>
  mutate(IDADE_DIAS = as.integer(DT_SIN_PRI - DT_NASC))

idade

# Alterando para anos
idade <- dt_notific |>
  select(DT_NASC, DT_SIN_PRI) |>
  mutate(
    IDADE_DIAS = as.integer(DT_SIN_PRI - DT_NASC),
    IDADE_ANOS = floor(IDADE_DIAS / 365.25)
  )

idade

# Transformar as datas de notificação em semana epidemiológica
epiweek(dt_notific$DT_NOTIFIC)

# Decompor a data em componentes e incluir a semana epi
dt_notific_2 <- dt_notific |>
  mutate(
    ano = year(DT_NOTIFIC),  
    mes = month(DT_NOTIFIC), 
    dia = day(DT_NOTIFIC),
    semana_num = wday(DT_NOTIFIC),      #retorna o número do dia da semana
    semana_nome = wday(DT_NOTIFIC, label = TRUE),      #nome abreviado do dia da semana
    semana_nome_completo = wday(DT_NOTIFIC, label = TRUE, abbr = FALSE),
    semana_epidemiologica = epiweek(DT_NOTIFIC)
  )

dt_notific_2

# Número do dia da semana
dt_notific3 <- dt_notific |>
  select(DT_NOTIFIC) |>
  mutate(dia_semana = wday(DT_NOTIFIC))

dt_notific3

# Diferença até o final da semana (sábado)
dt_notific_4 <- dt_notific |>
  select(DT_NOTIFIC) |>
  mutate(dia_semana = wday(DT_NOTIFIC),   
         dif_dia_semana = 7 - dia_semana)

dt_notific_4

# Data de sábado da mesma semana epidemiológica
dt_notific_5 <- dt_notific |>
  select(DT_NOTIFIC) |>
  mutate(
    dia_semana = wday(DT_NOTIFIC),
    dif_dia_semana = 7 - dia_semana,
    DT_semana_epi = DT_NOTIFIC + dif_dia_semana  #encontra o sábado daquela semana
  )

dt_notific_5

# Cálculo direto da data de sábado da semana epidemiológica
dt_notific_6 <- dt_notific |>
  select(DT_NOTIFIC) |>
  mutate(DT_semana_epi = DT_NOTIFIC + 7 - wday(DT_NOTIFIC))

dt_notific_6

# Criar uma sequência de dias a partir de 01/01/2022
as.Date("2022-01-01") + 0:7
seq.Date(from = as.Date("2022-01-01"), to = as.Date("2022-02-01"), by = "day")

