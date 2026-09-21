CREATE TABLE ratings (
  rating_id INT PRIMARY KEY, 
  rating VARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE titles (
  show_id VARCHAR(10) PRIMARY KEY, 
  type VARCHAR(10) NOT NULL, 
  title VARCHAR(255) NOT NULL,
  date_added DATE NULL, 
  release_year INT NOT NULL, 
  rating_id INT NULL REFERENCES ratings(rating_id),
  duration_value INT NOT NULL, 
  duration_unit VARCHAR(10) NOT NULL, 
  description TEXT
);

CREATE TABLE directors (
  director_id INT PRIMARY KEY, 
  name VARCHAR(255) NOT NULL
);

CREATE TABLE title_directors (
  show_id VARCHAR(10) REFERENCES titles(show_id), 
  director_id INT REFERENCES directors(director_id), 
  PRIMARY KEY (show_id, director_id)
);

CREATE TABLE actors (
  actor_id INT PRIMARY KEY, 
  name VARCHAR(255) NOT NULL
);

CREATE TABLE title_cast (
  show_id VARCHAR(10) REFERENCES titles(show_id), 
  actor_id INT REFERENCES actors(actor_id), 
  PRIMARY KEY (show_id, actor_id)
);

CREATE TABLE countries (
  country_id INT PRIMARY KEY, 
  name VARCHAR(255) NOT NULL
);

CREATE TABLE title_countries (
  show_id VARCHAR(10) REFERENCES titles(show_id), 
  country_id INT REFERENCES countries(country_id), 
  PRIMARY KEY (show_id, country_id)
);

CREATE TABLE genres (
  genre_id INT PRIMARY KEY, 
  name VARCHAR(255) NOT NULL
);

CREATE TABLE title_genres (
  show_id VARCHAR(10) REFERENCES titles(show_id), 
  genre_id INT REFERENCES genres(genre_id), 
  PRIMARY KEY (show_id, genre_id)
);