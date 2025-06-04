### 🧪 Introdução à análise de dados em vigilância em saúde - R

Repositório criado para organizar os estudos e práticas do curso de **Análise de dados na vigilância em saúde**, com foco na análise de dados epidemiológicos utilizando a linguagem R. 
Aqui compartilho os exercícios, scripts e aprendizados obtidos durante a realização do curso.

---

### 📘 Sobre o Curso

O curso tem como objetivo introduzir o uso da linguagem R na análise de dados em saúde pública. Ele é estruturado em 5 módulos.

- **Módulo 1**: Introdução à análise de dados *(não possui arquivos)*
- **Módulo 2**: Introdução à análise de dados com R
- **Módulo 3**: Gerenciamento de dados na vigilância em saúde
- **Módulo 4**: Análises básicas de dados para vigilância em saúde - Parte I
- **Módulo 5**: Análises básicas de dados para vigilância em saúde - Parte II

---

### 📁 Estrutura e organização

Os conteúdos estão organizados por **módulos**, e dentro de cada um estão os **scripts** produzidos nas aulas e **arquivos fictícios** disponibilizados para prática.
Entre as principais atividades e análises, estão:
- Importação e leitura de dados: manipulação de arquivos CSV (read.csv2), DBF (foreign::read.dbf()), e planilhas Excel (readxl::read_excel())
- Tratamento e limpeza de dados: seleção, filtragem e transformação de variáveis, tratamento de valores ausentes, criação de variáveis derivadas
- Exploração e análise descritiva: tabelas de frequência, estatística básica
- Funções para tratamento de dados e organização de bases
  
---

## 🧰 Tecnologias e pacotes utilizados

- **Base R**:
  - `read.csv2()` – leitura de arquivos CSV com separador `;`
  - `subset()` – filtragem de dados
  - `merge()` – junção de tabelas
  - `table()` – criação de tabelas de frequência
  - `prop.table()` – cálculo de proporções
  - `round()` – arredondamento de valores
  - `aggregate()` – sumarização por grupos
  - `length()`, `nrow()`, `unique()`, `duplicated()`, `which()`, `colnames()`, `names()` – inspeção e estruturação de dados
  - `ifelse()` – aplicação de lógica condicional
  - Operadores lógicos: `==`, `!=`, `>`, `<`, `%in%`

- **Pacote `foreign`**:
  - `read.dbf()` – leitura de arquivos DBF (dados do SINAN)

- **Pacote `readxl`**:
  - `read_excel()` – leitura de arquivos XLSX (dados do SIVEP-Gripe)
