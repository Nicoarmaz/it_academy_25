DROP DATABASE IF EXISTS transactions;

-- ATENCIÓN: antes de ejecutar este código se deben ejecutar los siguentes archivos .sql para crear el esquema de datos.
 
	-- estructura dades.sql
	-- dades_introduir_sprint2.sql


--  Nivel 1

-- Exercici 1
-- A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

-- FILTRAR TODOS LOS EJERCICIOS CON LA VARIABLE DECLINED
-- TRANSACCIONES != VENTAS

USE transactions;

DESCRIBE company;
SELECT * FROM company;

DESCRIBE transaction;
SELECT * FROM transaction;

-- Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:
 --   Llistat dels països que estan generant vendes.
 SELECT DISTINCT country AS lista_paises
 FROM transaction
 INNER JOIN company ON company.id = transaction.company_id
 WHERE declined = 0;  
    
 --   Des de quants països es generen les vendes.
 SELECT COUNT(DISTINCT country) AS num_paises
 FROM transaction
 INNER JOIN company ON company.id = transaction.company_id
 WHERE declined = 0;
  
  --   Identifica la companyia amb la mitjana més gran de vendes.
SELECT company.id, company_name, ROUND(AVG(amount), 2) AS promedio_ventas 
FROM transaction
INNER JOIN company ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY company.id, company_name
ORDER BY promedio_ventas DESC
LIMIT 1;

-- Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
   --  Mostra totes les transaccions realitzades per empreses d'Alemanya.
 SELECT *
FROM transaction
WHERE EXISTS (
        SELECT id
        FROM company
        WHERE country = 'Germany'
			AND company.id = transaction.company_id);        
    
   -- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT id, company_name
FROM company
WHERE EXISTS (
        SELECT company_id
        FROM transaction
        WHERE amount > (
			SELECT AVG(amount)
			FROM transaction)
			AND company.id = transaction.company_id); 
  
   -- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id, company_name
FROM company
WHERE NOT EXISTS (
  SELECT company_id 
  FROM transaction);
 
    -- Nivell 2

-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) AS fecha, COUNT(id) AS ventas_fecha, SUM(amount) AS ingresos_fecha
FROM transaction
WHERE declined = 0
GROUP BY fecha 
ORDER BY ingresos_fecha DESC
LIMIT 5;

-- Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT country, ROUND(AVG(amount), 2) AS promedio_ventas
FROM transaction
INNER JOIN company ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY promedio_ventas DESC;

-- Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

--   Mostra el llistat aplicant JOIN i subconsultes.
SELECT *
FROM transaction
INNER JOIN company ON company.id = transaction.company_id
WHERE country = (
	SELECT country 
	FROM company
	WHERE company_name = "Non Institute");
    
--  Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction AS t
WHERE EXISTS (SELECT c.id
			  FROM company AS c
			  WHERE c.id = t.company_id 
				AND country = (SELECT c2.country
						  FROM company AS c2
					      WHERE c2.company_name = 'Non Institute'
							AND c2.country = c.country));    
  
 -- Nivell 3
-- Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat.

SELECT company.id, company_name, phone, country, amount, DATE(timestamp) AS fecha
FROM transaction
INNER JOIN company ON company.id = transaction.company_id
WHERE amount BETWEEN 350 AND 400
	AND (DATE(timestamp) = "2015-04-29" 
		OR DATE(timestamp) = "2018-07-20" 
		OR DATE(timestamp) = "2024-03-13") -- podría usarse IN 
ORDER BY amount DESC;

-- Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de 
-- transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT company.id, company_name, COUNT(*) AS num_transacciones, 
    CASE 
         WHEN COUNT(*) < 400 THEN 'Menos de 400'
         ELSE '400 o más' 
    END AS identificador_num_ventas   
FROM transaction
INNER JOIN company ON company.id = transaction.company_id
GROUP BY company_id
ORDER BY num_transacciones;