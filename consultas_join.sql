SELECT
    t.title AS titulo,
    t.release_year AS anio_lanzamiento,
    r.rating AS clasificacion_edad,
    CONCAT(t.duration_value, ' ', t.duration_unit) AS duracion,
    g.name AS genero
FROM titles AS t
INNER JOIN ratings AS r
    ON t.rating_id = r.rating_id
INNER JOIN title_genres AS tg
    ON t.show_id = tg.show_id
INNER JOIN genres AS g
    ON tg.genre_id = g.genre_id
WHERE t.type = 'Movie'
  AND g.name = :categoria_tematica
ORDER BY t.release_year DESC;


SELECT 
    t.title AS Título,
    t.type AS Tipo_Producción,
    c.name AS País_Origen,
    d.name AS Nombre_Participante,
    'Director' AS Rol_Desempeñado,
    t.release_year AS Año_Estreno
FROM titles t
JOIN title_countries tc ON t.show_id = tc.show_id
JOIN countries c ON tc.country_id = c.country_id
JOIN title_directors td ON t.show_id = td.show_id
JOIN directors d ON td.director_id = d.director_id
WHERE c.name = 'United States' -- Parámetro de filtrado por país (ejemplo)

ORDER BY Título ASC, Rol_Desempeñado ASC;


