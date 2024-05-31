-- 1) ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT s.customer_id AS Cliente, SUM(m.price) AS Gasto_€
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY Cliente
ORDER BY Gasto_€ DESC;
#Cliente A: 76€
#Cliente B: 74€
#Cliente C: 36€

-- 2) ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT customer_id AS Cliente, COUNT(DISTINCT order_date) AS CantidadDias 
FROM sales
GROUP BY Cliente;
#Cliente A: 4 veces
#Clienet B: 6 veces
#Clienet C: 2 veces

-- 3) ¿Cuál fue el primer artículo del menú comprado por cada cliente?
SELECT s.customer_id AS Cliente, me.product_name AS Producto
FROM sales s
JOIN menu me
ON s.product_id = me.product_id
WHERE s.customer_id = "A" AND s.order_date = (
												SELECT MIN(order_date) AS PrimeraCompra
												FROM sales s
												WHERE s.customer_id = "A"
											  )
UNION
SELECT s.customer_id AS Cliente, me.product_name AS Producto
FROM sales s
JOIN menu me
ON s.product_id = me.product_id
WHERE s.customer_id = "B" AND s.order_date = (
												SELECT MIN(order_date) AS PrimeraCompra
												FROM sales s
												WHERE s.customer_id = "B"
											  )
UNION
SELECT s.customer_id AS Cliente, me.product_name AS Producto
FROM sales s
JOIN menu me
ON s.product_id = me.product_id
WHERE s.customer_id = "C" AND s.order_date = (
												SELECT MIN(order_date) AS PrimeraCompra
												FROM sales s
												WHERE s.customer_id = "C"
											  );
#Cliente A: Curry & Sushi
#Cliente B: Curry
#Cliente C: Ramen

#Respuesta válida teniendo en cuenta que todos los clientes compraron el primer producto el mismo día:
SELECT s.customer_id AS Cliente, me.product_name AS Producto
FROM sales s  
JOIN menu me
ON (s.product_id = me.product_id)
WHERE order_date =  (
					SELECT MIN(order_date) 
                    FROM sales
                    )
GROUP BY Cliente, Producto
ORDER BY Cliente;

-- 4) ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
SELECT me.product_name AS Producto, COUNT(s.product_id) AS Comprados
FROM sales s
JOIN menu me
ON s.product_id = me.product_id
GROUP BY Producto
ORDER BY Comprados DESC
LIMIT 1;
#Artículo n°3: "Ramen". Comprado 8 Veces

SELECT s.customer_id AS Cliente, COUNT(me.product_name) AS Comprados
FROM sales s
JOIN menu me
ON s.product_id = me.product_id
WHERE me.product_name = "ramen"
GROUP BY Cliente;
#Cliente A: Compró 3 Ramen
#Cliente A: Compró 2 Ramen
#Cliente A: Compró 3 Ramen

-- 5) ¿Qué artículo fue el más popular para cada cliente?
SELECT * 
FROM (
    SELECT s.customer_id AS Cliente, m.product_name AS Producto, COUNT(s.product_id) AS Comprado
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.customer_id = 'A'
    GROUP BY Cliente, Producto
    ORDER BY Comprado DESC
    LIMIT 1
) AS ClienteB

UNION

SELECT * 
FROM (
    SELECT s.customer_id AS Cliente, m.product_name AS Producto, COUNT(s.product_id) AS Comprado
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.customer_id = 'B'
    GROUP BY Cliente, Producto
    ORDER BY Comprado DESC
    LIMIT 1
) AS ClienteB
UNION

SELECT * 
FROM (
    SELECT s.customer_id AS Cliente, m.product_name AS Producto, COUNT(s.product_id) AS Comprado
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.customer_id = 'C'
    GROUP BY Cliente, Producto
    ORDER BY Comprado DESC
    LIMIT 1
) AS ClienteC;

#Cliente A - Ramen - 3 Comprados
#Cliente B - Sushi - 2 Comprados
#Cliente C - Ramen - 3 Comprados

-- 6) ¿Qué artículo compró primero el cliente después de convertirse en miembro?
SELECT *
FROM (
	SELECT s.customer_id AS Cliente, me.product_name AS Producto, s.order_date AS FechaCompra, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'A' AND s.order_date >= (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'A'
												   )
	ORDER BY FechaMiembro ASC
	LIMIT 1
    ) AS ClienteA
    
UNION

SELECT *
FROM (
	SELECT s.customer_id AS Cliente, me.product_name AS Producto, s.order_date AS FechaCompra, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'B' AND s.order_date >= (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'B'
												   )
	ORDER BY FechaMiembro ASC
	LIMIT 1
    ) AS ClienteB;

#Cliente A: Curry - FechaCompra: 2021-01-07 - FechaMiembo: 2021-01-07
#Cliente B: Sushi - FechaCompra: 2021-01-11 - FechaMiembo: 2021-01-09
#Cliente C NO es miembro.

-- 7) ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
SELECT *
FROM (
	SELECT s.customer_id AS Cliente, me.product_name AS Producto, s.order_date AS FechaCompra, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'A' AND s.order_date < (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'A'
												   )
	ORDER BY FechaMiembro ASC
	LIMIT 1
    ) AS ClienteA
    
UNION

SELECT *
FROM (
	SELECT s.customer_id AS Cliente, me.product_name AS Producto, s.order_date AS FechaCompra, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'B' AND s.order_date < (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'B'
												   )
	ORDER BY FechaMiembro ASC
	LIMIT 1
    ) AS ClienteB;

#Cliente A: Sushi - FechaCompra: 2021-01-01 - FechaMiembo: 2021-01-07
#Cliente B: Sushi - FechaCompra: 2021-01-04 - FechaMiembo: 2021-01-09
#Cliente C NO es miembro.

-- 8) ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?

SELECT *
FROM (
	SELECT s.customer_id AS Cliente, COUNT(s.product_id) AS CantidadArtículos, SUM(me.price) AS CantidadGastada_$, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'A' AND s.order_date < (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'A'
												   )
	GROUP BY Cliente, FechaMiembro
    ) AS ClienteA
    
UNION

SELECT *
FROM (
	SELECT s.customer_id AS Cliente, COUNT(s.product_id) AS CantidadArtículos, SUM(me.price) AS CantidadGastada_$, m.join_date AS FechaMiembro
	FROM sales s
	JOIN members m
	ON s.customer_id = m.customer_id
	JOIN menu me
	ON s.product_id = me.product_id
	WHERE s.customer_id = 'B' AND s.order_date < (
													SELECT m.join_date AS FechaMiembro
													FROM members m
													WHERE m.customer_id = 'B'
												   )
	GROUP BY Cliente, FechaMiembro
    ) AS ClienteB;

#Cliente A: 2 Artículos - Cantidad Gastada = $25 - FechaMiembo: 2021-01-07
#Cliente B: 3 Artículos - Cantidad Gastada = $40 - FechaMiembo: 2021-01-09
#Cliente C NO es miembro

-- 9) Si cada $ 1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿cuántos puntos tendría cada cliente?
-- Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes iguales o posteriores a la fecha
-- en la que se convierten en miembros. 
WITH ClienteA AS (
    SELECT s.customer_id, m.product_name, m.price
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members me ON s.customer_id = me.customer_id
    WHERE s.customer_id = 'A' 
      AND order_date >= (
          SELECT MIN(join_date)
          FROM members
      )
),
ClienteB AS (
    SELECT s.customer_id, m.product_name, m.price
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    JOIN members me ON s.customer_id = me.customer_id
    WHERE s.customer_id = 'B' 
      AND order_date >= (
          SELECT MIN(join_date)
          FROM members
      )
)
SELECT customer_id AS Cliente,
    SUM(
        CASE 
            WHEN product_name = 'sushi' THEN price * 2 
            ELSE price * 10
        END
    ) AS Puntos
FROM ClienteA
GROUP BY customer_id

UNION

SELECT customer_id AS Cliente,
    SUM(
        CASE 
            WHEN product_name = 'sushi' THEN price * 2 * 10
            ELSE price * 10
        END
    ) AS Puntos
FROM ClienteB
GROUP BY customer_id;

#Cliente A: 510 Puntos
#Cliente B: 440 Puntos
          
-- 10) En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi.
-- ¿Cuántos puntos tienen los clientes A y B a fines de enero?
-- Suposición: Solo los clientes que son miembros reciben puntos al comprar artículos, los puntos los reciben en las ordenes iguales o posteriores a la fecha
-- en la que se convierten en miembros. Solo las ordenes de la primer semana en la que se convierten en miembros suman 20 puntos para todos los articulos. 

#In Progress