-- Nivell 1
-- Exercici 1
USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(100),
	pan VARCHAR(100),
	pin VARCHAR(150),
	cvv VARCHAR(150),
	expiring_date VARCHAR(100));

-- ATENCIÓN: Antes de continuar se debe ejecutar este archivo .sql para introducir datos a la nueva tabla:
    -- datos_introducir_sprint3_credit.sql

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Exercici 2
 UPDATE credit_card
 SET iban = 'TR323456312213576817699999'
 WHERE id = 'CcU-2938';
 
SELECT *
FROM credit_card
WHERE id = 'CcU-2938';
  
-- Exercici 3
INSERT INTO company (id)
VALUES ('b-9999');

INSERT INTO credit_card (id)
VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', 829.999, -117.999, 111.11,  0);

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- Exercici 4
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;

-- agregar SELECT para mostrar los cambios realizados.

-- Nivell 2
-- Exercici 1
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercici 2
CREATE VIEW vistamarketing_ AS
SELECT c.company_name, c.phone AS contact_phone, c.country AS residence_country, ROUND(AVG(t.amount), 2) AS purchase_average
FROM company c
INNER JOIN transaction t ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.id;

SELECT * FROM vistamarketing_
ORDER BY purchase_average DESC;

-- Exercici 3
SELECT * FROM vistamarketing_
WHERE residence_country = 'Germany'
ORDER BY purchase_average DESC;

-- Nivell 3

-- ATENCIÓN: antes de ejecutar este código se deben ejecutar los siguentes archivos .sql para crear la tabla user:
	-- estructura datos user.sql
    -- datos introducir sprint3 user.sql

-- Cambios en la tabla user / data_user
RENAME TABLE user TO data_user;

ALTER TABLE data_user
	MODIFY id INT,
	CHANGE email personal_email VARCHAR(150);
    
INSERT INTO data_user (id)
	VALUES (9999);

SELECT *
FROM credit_card;
   
-- Cambios en la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_data_user
FOREIGN KEY (user_id) REFERENCES data_user(id);

-- Cambios en la tabla company
ALTER TABLE company 
DROP COLUMN website;

SELECT *
FROM company;

-- Cambios en la tabla credit_card 
ALTER TABLE credit_card
MODIFY id VARCHAR (20) NOT NULL,
MODIFY iban VARCHAR (50),
MODIFY pin VARCHAR (4), 
MODIFY cvv INT,
ADD fecha_actual DATE DEFAULT (CURRENT_DATE);

SELECT *
FROM credit_card;

-- Exercici 2

CREATE VIEW informetecnico AS
SELECT t.id AS transaction_id, timestamp, c.company_name, u.name AS user_name, u.surname AS user_surname, u.personal_email, cc.iban, u.country, u.city
FROM transaction AS t
INNER JOIN data_user AS u
	ON t.user_id = u.id
INNER JOIN credit_card AS cc
	ON t.credit_card_id = cc.id
INNER JOIN company AS c 
ON t.company_id = c.id
ORDER BY t.id DESC;

SELECT * FROM informetecnico;