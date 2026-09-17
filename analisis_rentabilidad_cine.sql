-- =====================================================================
-- ANÁLISIS DE RENTABILIDAD - ESTUDIO DE CINE
-- Motor: MySQL 8.x
-- Herramienta: MySQL Workbench
-- =====================================================================
--
-- CONTEXTO DEL NEGOCIO
-- Un estudio de cine necesita decidir en qué géneros y con qué directores
-- conviene invertir en futuras producciones. Para ello se analiza un
-- dataset de 15 películas con datos de presupuesto, ingresos, calificación,
-- género, director y año de estreno.
--
-- PREGUNTAS DE NEGOCIO QUE RESUELVE ESTE ANÁLISIS
--   1. ¿Qué géneros mantienen una calificación promedio superior a 6?
--   2. ¿Qué director genera más ingresos y además supera el promedio
--      general de calificación?
--   3. ¿El género "preferido" de cada director es realmente el más
--      rentable en términos de retorno de inversión (ROI)?
--
-- TÉCNICAS APLICADAS
--   - Funciones de agregación (SUM, AVG, COUNT)
--   - GROUP BY con una y múltiples columnas
--   - HAVING para filtrar sobre grupos ya calculados
--   - Subconsultas escalares en el HAVING
--   - ORDER BY + LIMIT para selección del valor máximo
--   - Cálculo de métricas derivadas (ROI)
-- =====================================================================


-- =====================================================================
-- 1. CREACIÓN DEL DATASET
-- =====================================================================
-- Nota: dataset construido con fines de práctica y demostración técnica.
-- No corresponde a datos de producción reales.

CREATE DATABASE proyecto_peliculas;
USE proyecto_peliculas;

CREATE TABLE peliculas (
    id INT PRIMARY KEY,
    titulo VARCHAR(100),
    genero VARCHAR(30),
    anio INT,
    director VARCHAR(50),
    presupuesto DECIMAL(12,2),
    ingresos DECIMAL(12,2),
    calificacion DECIMAL(3,1)
);

INSERT INTO peliculas VALUES
(1,  'El Último Vuelo',       'Drama',           2019, 'Marta Colina',     8000000,   22000000,  7.2),
(2,  'Fuego Cruzado',         'Acción',          2021, 'Ricardo Núñez',    45000000,  180000000, 6.8),
(3,  'Noches sin Luna',       'Terror',          2020, 'Marta Colina',     3000000,   27000000,  6.5),
(4,  'Código Rojo',           'Acción',          2022, 'Ricardo Núñez',    60000000,  210000000, 7.0),
(5,  'Un Verano Cualquiera',  'Comedia',         2018, 'Elena Vargas',     5000000,   12000000,  6.0),
(6,  'La Sombra del Silencio','Drama',           2021, 'Julián Restrepo',  7000000,   9000000,   7.8),
(7,  'Risas en el Caos',      'Comedia',         2022, 'Elena Vargas',     6000000,   25000000,  6.3),
(8,  'El Enigma de Marte',    'Ciencia Ficción', 2020, 'Ricardo Núñez',    90000000,  320000000, 7.5),
(9,  'Corazón de Hierro',     'Acción',          2019, 'Julián Restrepo',  40000000,  60000000,  5.9),
(10, 'Susurros del Bosque',   'Terror',          2018, 'Marta Colina',     2500000,   8000000,   5.5),
(11, 'Segunda Oportunidad',   'Drama',           2023, 'Elena Vargas',     9000000,   15000000,  8.1),
(12, 'Galaxia Perdida',       'Ciencia Ficción', 2023, 'Ricardo Núñez',    100000000, 95000000,  6.1),
(13, 'La Última Broma',       'Comedia',         2020, 'Julián Restrepo',  4000000,   3000000,   4.8),
(14, 'Sombras del Pasado',    'Terror',          2022, 'Marta Colina',     3500000,   31000000,  7.0),
(15, 'El Vuelo del Águila',   'Drama',           2017, 'Julián Restrepo',  6500000,   20000000,  7.4);


-- =====================================================================
-- 2. PREGUNTA 1 — CALIDAD POR GÉNERO
-- =====================================================================
-- ¿Qué géneros mantienen una calificación promedio superior a 6?
--
-- Se agrupa por género y se filtra con HAVING (no con WHERE), porque la
-- condición se evalúa sobre un valor agregado que solo existe DESPUÉS
-- de agrupar.

SELECT
    genero,
    AVG(calificacion) AS calificacion_promedio
FROM peliculas
GROUP BY genero
HAVING AVG(calificacion) > 6;

-- RESULTADO
--   Drama            7.63
--   Ciencia Ficción  6.80
--   Acción           6.57
--   Terror           6.33
--   (Comedia queda fuera del umbral)


-- =====================================================================
-- 3. PREGUNTA 2 — DIRECTOR DE MAYOR INGRESO CON CALIDAD SOBRE EL PROMEDIO
-- =====================================================================
-- ¿Qué director genera más ingresos totales Y además tiene una
-- calificación promedio superior al promedio general de la tabla?
--
-- El promedio general se resuelve con una subconsulta escalar en lugar de
-- un valor fijo, para que la consulta siga siendo válida si el dataset crece.
--
-- Orden de procesamiento: primero HAVING descarta a los directores bajo el
-- promedio de calificación; solo entre los que sobreviven se ordena por
-- ingresos y se toma el primero.

SELECT
    director,
    SUM(ingresos)      AS ingresos_totales,
    AVG(calificacion)  AS calificacion_promedio
FROM peliculas
GROUP BY director
HAVING AVG(calificacion) > (SELECT AVG(calificacion) FROM peliculas)
ORDER BY SUM(ingresos) DESC
LIMIT 1;

-- RESULTADO
--   Ricardo Núñez | 805.000.000 | 6.85
--   (promedio general de calificación: 6.66)


-- =====================================================================
-- 4. PREGUNTA 3 — ¿EL GÉNERO PREFERIDO ES EL MÁS RENTABLE?
-- =====================================================================

-- 4.1 Primera aproximación: ¿en qué género concentra más películas
--     cada director?

SELECT
    director,
    genero,
    COUNT(*) AS cantidad_peliculas
FROM peliculas
GROUP BY director, genero;

-- HALLAZGO INTERMEDIO
-- Ricardo Núñez queda empatado con 2 películas en Acción y 2 en
-- Ciencia Ficción. El criterio "cantidad de películas" no alcanza para
-- definir un género preferido en todos los casos.


-- 4.2 Criterio redefinido: se define "género preferido" como aquel en el
--     que el director generó MÁS INGRESOS TOTALES, priorizando este
--     criterio sobre la cantidad de películas en caso de empate.
--     Esta definición se documenta de forma explícita porque cambia el
--     resultado del análisis.

SELECT
    director,
    genero,
    SUM(ingresos) AS ingresos_por_genero
FROM peliculas
GROUP BY director, genero;

-- GÉNERO PREFERIDO POR INGRESOS
--   Marta Colina     -> Terror           (66.000.000)
--   Ricardo Núñez    -> Ciencia Ficción  (415.000.000)
--   Elena Vargas     -> Comedia          (37.000.000)
--   Julián Restrepo  -> Acción           (60.000.000)


-- 4.3 Métrica de rentabilidad: ROI por combinación director-género.
--     ROI = ingresos totales / presupuesto total.
--     Un valor mayor a 1 indica que la inversión se recuperó con ganancia.

SELECT
    director,
    genero,
    SUM(ingresos)    AS ingresos_totales,
    SUM(presupuesto) AS presupuesto_total,
    SUM(ingresos) / SUM(presupuesto) AS roi
FROM peliculas
GROUP BY director, genero
ORDER BY roi DESC;

-- RESULTADO (ordenado por ROI)
--   Marta Colina    | Terror          | 7.33
--   Ricardo Núñez   | Acción          | 3.71
--   Elena Vargas    | Comedia         | 3.36
--   Marta Colina    | Drama           | 2.75
--   Ricardo Núñez   | Ciencia Ficción | 2.18
--   Julián Restrepo | Drama           | 2.15
--   Elena Vargas    | Drama           | 1.67
--   Julián Restrepo | Acción          | 1.50
--   Julián Restrepo | Comedia         | 0.75


-- =====================================================================
-- 5. CONCLUSIONES DEL ANÁLISIS
-- =====================================================================
--
-- 1. INGRESOS TOTALES Y RENTABILIDAD NO SON LA MISMA MÉTRICA, y en este
--    dataset apuntan en direcciones distintas para 2 de los 4 directores.
--
--    - Ricardo Núñez genera más ingresos en Ciencia Ficción (415M, ROI 2.18),
--      pero es casi el doble de eficiente en Acción (390M, ROI 3.71).
--    - Julián Restrepo tiene su mayor ingreso en Acción (ROI 1.50), mientras
--      que su Drama, con menos ingresos, rinde mejor (ROI 2.15).
--
-- 2. EL ÚNICO CASO DONDE AMBOS CRITERIOS COINCIDEN es Marta Colina en
--    Terror: es a la vez su género de mayor ingreso y el de mayor ROI de
--    todo el dataset (7.33), sostenido por presupuestos bajos.
--
-- 3. HAY UNA COMBINACIÓN CON PÉRDIDA: Julián Restrepo en Comedia, con
--    ROI de 0.75 (recuperó solo el 75% de lo invertido).
--
-- 4. RECOMENDACIÓN: una decisión de inversión basada únicamente en
--    ingresos totales llevaría a sobreinvertir en producciones de
--    presupuesto alto con retorno proporcional bajo. Se recomienda
--    evaluar ambas métricas en conjunto antes de asignar presupuesto.
--
-- =====================================================================
