# Análisis de Rentabilidad — Estudio de Cine (SQL)

Análisis exploratorio sobre un dataset de películas para evaluar qué géneros y directores ofrecen mejores resultados a un estudio de cine, distinguiendo entre **volumen de ingresos** y **eficiencia de la inversión**.

> Dataset construido con fines de práctica y demostración técnica. No corresponde a datos de producción reales.

---

## Contexto del problema

Un estudio de cine necesita decidir en qué géneros y con qué directores invertir en futuras producciones. La intuición habitual es priorizar a quien más ingresos genera — este análisis pone a prueba esa intuición.

## Preguntas de negocio

1. ¿Qué géneros mantienen una calificación promedio superior a 6?
2. ¿Qué director genera más ingresos y además supera el promedio general de calificación?
3. ¿El género "preferido" de cada director es realmente el más rentable?

## Herramientas

- MySQL 8.x
- MySQL Workbench

## Técnicas aplicadas

- Funciones de agregación: `SUM`, `AVG`, `COUNT`
- `GROUP BY` con una y múltiples columnas
- `HAVING` para filtrar sobre grupos ya calculados
- Subconsultas escalares dentro de `HAVING`
- `ORDER BY` + `LIMIT` para selección del valor máximo
- Cálculo de métricas derivadas (ROI)

---

## Hallazgos principales

**1. Ingresos totales y rentabilidad no son la misma métrica.**
En 2 de los 4 directores analizados, ambos criterios apuntan a géneros distintos.

| Director | Género de mayor ingreso | ROI de ese género | Género de mayor ROI | ROI |
|---|---|---|---|---|
| Ricardo Núñez | Ciencia Ficción (415M) | 2.18 | Acción | 3.71 |
| Julián Restrepo | Acción (60M) | 1.50 | Drama | 2.15 |
| Marta Colina | Terror (66M) | 7.33 | Terror | 7.33 |
| Elena Vargas | Comedia (37M) | 3.36 | Comedia | 3.36 |

**2. El mejor ROI del dataset se sostiene en presupuestos bajos.**
Marta Colina en Terror alcanza un ROI de 7.33 con presupuestos acumulados de apenas 9M — el caso más eficiente del dataset.

**3. Existe una combinación con pérdida.**
Julián Restrepo en Comedia tiene un ROI de 0.75: recuperó solo el 75% de lo invertido.

**4. Recomendación.**
Decidir la asignación de presupuesto mirando únicamente ingresos totales llevaría a sobreinvertir en producciones costosas con retorno proporcional bajo. Ambas métricas deben evaluarse en conjunto.

---

## Nota metodológica

Durante el análisis surgió una ambigüedad: al medir el "género preferido" por cantidad de películas, un director quedó empatado (2 y 2). El criterio se redefinió de forma explícita como **el género con mayores ingresos totales**, priorizándolo sobre la cantidad de películas. Esta decisión cambia el resultado para uno de los directores y por eso queda documentada en el código.

---

## Estructura del repositorio

```
analisis_rentabilidad_cine.sql   Script completo: dataset, consultas y conclusiones
README.md                        Este archivo
```

El script es autocontenido: incluye la creación de la base de datos y la carga del dataset, por lo que puede ejecutarse de principio a fin en cualquier instancia de MySQL.
