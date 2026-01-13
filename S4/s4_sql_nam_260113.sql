CREATE DATABASE transacciones_usuarios;
USE transacciones_usuarios;

CREATE TABLE users (
	id INT NOT NULL PRIMARY KEY,
	name VARCHAR (20),
	surname VARCHAR (50),
	phone VARCHAR (50),
	email VARCHAR (100),
	birth_date VARCHAR (50), 
	country VARCHAR (20),
	city VARCHAR (50),
	postal_code VARCHAR (20), 
	address VARCHAR (100)
);

CREATE TABLE companies (
	company_id VARCHAR (20) NOT NULL PRIMARY KEY,
	company_name VARCHAR (50),
	phone VARCHAR (50),
	email VARCHAR (50),
	country VARCHAR (20),
	website VARCHAR (50)
);

CREATE TABLE credit_cards (
	id VARCHAR (50) NOT NULL PRIMARY KEY,
    user_id SMALLINT,
    iban VARCHAR (50),
    pan VARCHAR (50),
    pin BIGINT,
    cvv SMALLINT,
    track1 VARCHAR (100),
    track2 VARCHAR (100),
    expiring_date VARCHAR (10)
);

CREATE TABLE products (
	id VARCHAR (100) NOT NULL PRIMARY KEY,
    product_name VARCHAR (50),
    price VARCHAR(20),
    colour VARCHAR (20),
    weight DECIMAL (10,1),
    warehouse_id VARCHAR (10)
    );
    
CREATE TABLE transactions (
	id VARCHAR (50) NOT NULL PRIMARY KEY,
    card_id VARCHAR (10), 
    business_id VARCHAR (20), 
    timestamp TIMESTAMP,
    amount DECIMAL (10,2),
    declined BOOLEAN,
    product_id VARCHAR (100), 
    user_id INT, 
    lat FLOAT,
    longitude FLOAT,
		FOREIGN KEY (user_id) REFERENCES users (id),
		FOREIGN KEY (business_id) REFERENCES companies (company_id),
        FOREIGN KEY (card_id) REFERENCES credit_cards (id)
    ); 
    
-- iMPORTAR LOS DATOS DESDE LOS ARCHIVOS CSV:
-- Despues de realizar los cambios en el archivo my.ini se deben aplicar los siguientes comandos para permitir la importación de archivos locales

SET GLOBAL local_infile = 1; -- Permitir la importación de archivos locales
SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- Confirmar si el cambio se realizó correctamente

-- TABLA USUARIOS (american_users)
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TABLA USUARIOS (european_users)
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TABLA COMPANIES
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- TABLA CREDIT_CARD
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET SQL_SAFE_UPDATES = 0;
	
UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
ALTER TABLE credit_cards MODIFY expiring_date DATE;

-- TABLA PRODUCTS
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
	
UPDATE products
SET price = REPLACE(price, '$', '');
ALTER TABLE products MODIFY price DECIMAL(10,2);

-- TABLA TRANSACTIONS
LOAD DATA LOCAL INFILE 'G:/Mi unidad/_dataanalytics_2025/S4_SQL/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET SQL_SAFE_UPDATES = 1; -- Retornar al modo seguro

-- Nivel 1: ejercicio 1

SELECT t.user_id, COUNT(DISTINCT(t.id)) AS cuenta_transacciones
FROM transactions t
WHERE t.user_id IN (
	SELECT id
    FROM users u
    )
GROUP BY t.user_id
HAVING cuenta_transacciones > 80
ORDER BY t.user_id DESC;

-- Nivel 1: ejercicio 2

SELECT cc.iban, ROUND(AVG(t.amount),2) AS promedio_monto, c.company_name
FROM transactions t
INNER JOIN credit_cards cc ON t.card_id = cc.id
INNER JOIN companies c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY ROUND(promedio_monto,2) DESC;

-- Nivel 2: ejercicio 1

CREATE TABLE estado_tarjeta AS
SELECT
card_id,
    CASE 
        WHEN cuenta_rechazos = 3 THEN 'Inactiva'
        ELSE 'Activa' 
    END AS card_estado
FROM (
    SELECT 
        card_id, 
        SUM(CASE WHEN declined = '1' THEN 1 ELSE 0 END) AS cuenta_rechazos
    FROM (
        SELECT 
            card_id, 
            declined, 
            ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS num_fila
        FROM transactions
    ) AS t_orden
    WHERE num_fila <= 3
    GROUP BY card_id
) AS t_resumen;

SELECT COUNT(*) AS tarjetas_activas
FROM estado_tarjeta
WHERE card_estado = 'Activa';

-- Nivell 3 - Exercici 1: 

CREATE TABLE products_nueva (
  transaction_id VARCHAR (50) NOT NULL,
  products_nueva_id VARCHAR (100) NOT NULL,
  PRIMARY KEY (transaction_id, products_nueva_id),
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (products_nueva_id) REFERENCES products(id)
  );
  
INSERT INTO products_nueva (transaction_id, products_nueva_id)
SELECT 
  t.id AS transaction_id,
  TRIM(aux.product_id) AS products_nueva_id
FROM transactions t
JOIN JSON_TABLE(
  CONCAT('["', REPLACE(t.product_id, ',', '","'), '"]'),
  '$[*]' COLUMNS (product_id VARCHAR(100) PATH '$')
) AS aux
JOIN products p ON p.id = TRIM(aux.product_id);

SELECT 
	pn.products_nueva_id,
	p.product_name,
	COUNT(*) AS numero_ventas
FROM products_nueva pn
INNER JOIN products p ON pn.products_nueva_id = p.id
INNER JOIN transactions t ON pn.transaction_id = t.id
WHERE t.declined = 0
GROUP BY pn.products_nueva_id, p.product_name
ORDER BY numero_ventas DESC;
