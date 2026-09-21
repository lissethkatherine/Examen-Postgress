# 🎬 Netflix Database — PostgreSQL

## 📌 Descripción del proyecto

Este proyecto consiste en el diseño y construcción de una **base de datos relacional en PostgreSQL** a partir del dataset `netflix_titles.csv`, que contiene información sobre películas y series disponibles en Netflix.

El archivo original contiene aproximadamente **8.807 registros** y presenta información como títulos, directores, actores, países, géneros, fechas, duración, clasificación y descripción.

El objetivo principal del proyecto es transformar un archivo CSV con información parcialmente desnormalizada en una **base de datos relacional organizada, normalizada y con relaciones mediante claves primarias y foráneas**.

---

## 🎯 Objetivos

### Objetivo general

Diseñar e implementar una base de datos relacional en PostgreSQL utilizando como fuente de información el dataset de Netflix.

### Objetivos específicos

- Analizar la estructura del archivo CSV.
- Identificar los datos que pueden convertirse en entidades.
- Diseñar un modelo lógico de base de datos.
- Definir claves primarias y foráneas.
- Establecer las cardinalidades entre las entidades.
- Normalizar la información para evitar duplicidad de datos.
- Crear las tablas utilizando PostgreSQL.
- Importar los registros provenientes del CSV.
- Separar los campos que contienen múltiples valores.
- Crear relaciones muchos a muchos mediante tablas intermedias.
- Realizar consultas para comprobar que la información fue cargada correctamente.
- Documentar todo el proceso.

---

## 📂 Dataset utilizado

El proyecto utiliza el archivo:

```text
netflix_titles.csv
```

El dataset contiene información relacionada con películas y series.

### Columnas originales

| Columna        | Descripción                        |
| -------------- | ---------------------------------- |
| `show_id`      | Identificador único del contenido  |
| `type`         | Tipo de contenido: Movie o TV Show |
| `title`        | Nombre de la película o serie      |
| `director`     | Director o directores              |
| `cast`         | Actores que participan             |
| `country`      | País o países relacionados         |
| `date_added`   | Fecha en la que fue agregado       |
| `release_year` | Año de lanzamiento                 |
| `rating`       | Clasificación del contenido        |
| `duration`     | Duración                           |
| `listed_in`    | Categorías o géneros               |
| `description`  | Descripción del contenido          |

---

## 🧠 Problema encontrado en el CSV

El archivo original contiene varios campos con **múltiples valores dentro de una misma columna**.

Por ejemplo:

```text
director
"Director A, Director B"
```

o:

```text
country
"United States, Canada"
```

También puede existir:

```text
listed_in
"Comedies, Dramas, International Movies"
```

Mantener esta estructura directamente en una base de datos relacional genera problemas de normalización y dificulta realizar consultas correctamente.

Por esta razón, se decidió transformar la información a un modelo relacional.

---

## 🏗️ Diseño de la base de datos

La información se divide en diferentes entidades.

### Entidades principales

#### `content`

Almacena la información principal de cada película o serie.

Campos principales:

- `show_id` — PK
- `type`
- `title`
- `date_added`
- `release_year`
- `rating`
- `duration`
- `description`

---

#### `director`

Almacena los directores de los contenidos.

Campos:

- `director_id` — PK
- `name` — UNIQUE

---

#### `person`

Almacena los actores y participantes del contenido.

Campos:

- `person_id` — PK
- `name` — UNIQUE

---

#### `country`

Almacena los países relacionados con los contenidos.

Campos:

- `country_id` — PK
- `name` — UNIQUE

---

#### `genre`

Almacena las categorías o géneros.

Campos:

- `genre_id` — PK
- `name` — UNIQUE

---

## 🔗 Tablas de relación

Debido a que un contenido puede estar relacionado con varios directores, actores, países y géneros, se utilizan tablas intermedias.

### `content_director`

Relaciona contenidos con directores.

```text
content 1 ───── N content_director N ───── 1 director
```

Cardinalidad:

```text
Content N : M Director
```

---

### `content_cast`

Relaciona contenidos con actores.

```text
content 1 ───── N content_cast N ───── 1 person
```

Cardinalidad:

```text
Content N : M Person
```

---

### `content_country`

Relaciona contenidos con países.

```text
content 1 ───── N content_country N ───── 1 country
```

Cardinalidad:

```text
Content N : M Country
```

---

### `content_genre`

Relaciona contenidos con géneros.

```text
content 1 ───── N content_genre N ───── 1 genre
```

Cardinalidad:

```text
Content N : M Genre
```

---

## 📊 Modelo lógico

La estructura general de la base de datos es:

```text
                         ┌──────────────┐
                         │   director   │
                         └──────┬───────┘
                                │
                                │
                         ┌──────▼─────────┐
                         │content_director│
                         └──────┬─────────┘
                                │
                                │
┌──────────────┐         ┌──────▼───────┐         ┌──────────────┐
│    genre     │◄────────│   content    │────────►│   country    │
└──────────────┘         └──────┬───────┘         └──────────────┘
                                │
                                │
                         ┌──────▼───────┐
                         │ content_cast │
                         └──────┬───────┘
                                │
                                ▼
                         ┌──────────────┐
                         │    person    │
                         └──────────────┘
```

---

## 🧹 Normalización

El diseño busca evitar la repetición innecesaria de información.

En el CSV original, por ejemplo, un mismo actor puede aparecer cientos de veces:

```text
Actor A
Actor A
Actor A
Actor A
```

En el modelo normalizado, el actor se almacena una sola vez:

```text
person
---------
person_id
name
```

Y sus relaciones con los contenidos se almacenan en:

```text
content_cast
--------------
show_id
person_id
```

Esto permite reducir redundancia y facilita el mantenimiento de la información.

---

## 🗃️ Staging / tabla temporal de importación

Para conservar la estructura original del CSV antes de normalizarla, se plantea utilizar una tabla de staging:

```text
staging.netflix_titles_raw
```

Esta tabla recibe inicialmente los datos exactamente como vienen en el CSV.

El flujo de transformación es:

```text
CSV
 │
 ▼
staging.netflix_titles_raw
 │
 ├──────────────► content
 │
 ├──────────────► director
 │                    │
 │                    ▼
 │             content_director
 │
 ├──────────────► person
 │                    │
 │                    ▼
 │               content_cast
 │
 ├──────────────► country
 │                    │
 │                    ▼
 │              content_country
 │
 └──────────────► genre
                      │
                      ▼
                 content_genre
```

Este proceso permite separar la **carga de datos** de la **normalización**.

---

## 🐘 PostgreSQL

El proyecto utiliza **PostgreSQL** como sistema gestor de base de datos.

La estructura SQL se divide en diferentes archivos para mantener el proyecto organizado.

### 📁 Estructura del proyecto

```text
netflix-database/
│
├── README.md
│
├── data/
│   └── netflix_titles.csv
│
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_import_data.sql
│   └── 04_queries.sql
│
└── docs/
    └── modelo-logico.md
```

---

## 📄 Archivos SQL

### `01_create_database.sql`

Contiene la creación de la base de datos utilizada para el proyecto.

---

### `02_create_tables.sql`

Contiene la estructura de las tablas:

- `content`
- `director`
- `person`
- `country`
- `genre`
- `content_director`
- `content_cast`
- `content_country`
- `content_genre`

También define:

- Primary Keys
- Foreign Keys
- Restricciones `UNIQUE`
- Restricciones `NOT NULL`
- Tipos de datos

---

### `03_import_data.sql`

Contiene el proceso de importación y transformación de los datos provenientes del CSV.

Primero se carga la información en la tabla de staging y posteriormente se distribuye hacia las tablas normalizadas.

---

### `04_queries.sql`

Contiene consultas SQL para comprobar el funcionamiento de la base de datos.

Algunos ejemplos de consultas:

- Listar todas las películas.
- Listar todas las series.
- Buscar contenido por año.
- Consultar películas por género.
- Consultar contenido por país.
- Consultar películas de un determinado director.
- Consultar actores que participan en determinados contenidos.
- Contar películas y series.
- Obtener los géneros con mayor cantidad de contenidos.

---

## 🔑 Claves primarias y foráneas

Las tablas principales utilizan identificadores únicos.

Ejemplo:

```text
content
--------
show_id PK
```

Mientras que las tablas de relación utilizan claves foráneas:

```text
content_cast
------------
show_id FK
person_id FK
```

Además, las tablas intermedias utilizan normalmente una clave primaria compuesta:

```text
PRIMARY KEY (show_id, person_id)
```

Esto evita registrar dos veces la misma relación.

---

## 🔄 Flujo completo del proyecto

El proceso realizado se puede resumir de la siguiente manera:

```text
1. Obtener dataset CSV
          ↓
2. Analizar columnas
          ↓
3. Identificar datos repetidos
          ↓
4. Identificar campos multivaluados
          ↓
5. Diseñar modelo lógico
          ↓
6. Definir PK y FK
          ↓
7. Crear tablas en PostgreSQL
          ↓
8. Cargar CSV en staging
          ↓
9. Normalizar información
          ↓
10. Crear relaciones
          ↓
11. Ejecutar consultas
          ↓
12. Verificar registros
          ↓
13. Documentar proyecto
```

---

## 🧪 Validación

Después de realizar la importación se deben comprobar aspectos como:

- Cantidad de contenidos cargados.
- Cantidad de directores.
- Cantidad de actores.
- Cantidad de países.
- Cantidad de géneros.
- Existencia de relaciones.
- Ausencia de duplicados.
- Integridad de las claves foráneas.

Una validación básica puede realizarse con:

```sql
SELECT COUNT(*) FROM content;

SELECT COUNT(*) FROM director;

SELECT COUNT(*) FROM person;

SELECT COUNT(*) FROM country;

SELECT COUNT(*) FROM genre;
```

Y para las relaciones:

```sql
SELECT COUNT(*) FROM content_director;

SELECT COUNT(*) FROM content_cast;

SELECT COUNT(*) FROM content_country;

SELECT COUNT(*) FROM content_genre;
```

---

## 🚀 Tecnologías utilizadas

- **PostgreSQL** — Sistema gestor de base de datos.
- **SQL** — Creación, transformación y consulta de datos.
- **CSV** — Fuente de datos.
- **DBeaver / pgAdmin / psql** — Herramientas para administrar PostgreSQL.
- **Git** — Control de versiones.
- **GitHub** — Almacenamiento y documentación del proyecto.

---

## 📚 Conceptos aplicados

Durante el desarrollo se aplican conceptos de:

- Bases de datos relacionales.
- Modelo lógico.
- Modelo entidad-relación.
- Normalización.
- Primera forma normal (1NF).
- Segunda forma normal (2NF).
- Tercera forma normal (3NF).
- Primary Keys.
- Foreign Keys.
- Cardinalidades.
- Relaciones 1:N.
- Relaciones N:M.
- Tablas intermedias.
- Importación de CSV.
- Staging tables.
- Transformación de datos.
- Consultas SQL.
- Integridad referencial.
- Control de versiones con Git y GitHub.

---

## 👨‍💻 Autor

**Jonatan David Sarmiento Sierra**

Proyecto académico de desarrollo de bases de datos y programación.

---

## 📌 Estado del proyecto

**En desarrollo.**

El proyecto contempla el análisis del dataset, diseño lógico, creación de la estructura PostgreSQL, importación de los datos, normalización y documentación del proceso.