#2. Create the relational schema in MySQL/SQLServer and insert a few records into the tables to test
#   your queries below. You will have to hand in the CREATE TABLE statements.


DROP SCHEMA IF EXISTS Assignment_1;
CREATE SCHEMA IF NOT EXISTS Assignment_1 DEFAULT CHARSET utf8mb4;
USE Assignment_1;


DROP TABLE IF EXISTS CALLS;
DROP TABLE IF EXISTS CONTRACT;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS PLAN;
DROP TABLE IF EXISTS CITY;


CREATE TABLE CITY (
City_id INT PRIMARY KEY AUTO_INCREMENT,
City_Name VARCHAR(100) NOT NULL UNIQUE,
Population INT NOT NULL CHECK (Population > 0),
AVG_income DECIMAL(12,2) NOT NULL CHECK (AVG_income >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE CUSTOMER (
Customer_id INT PRIMARY KEY AUTO_INCREMENT,
First_name VARCHAR(50) NOT NULL,
Last_name VARCHAR(50) NOT NULL,
Date_of_birth DATE NOT NULL,
Gender ENUM('Male','Female') NOT NULL,
City_id INT NOT NULL,
CONSTRAINT Fk_Customer_City
FOREIGN KEY (City_id) REFERENCES CITY(City_id)
ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE PLAN (
Plan_id INT PRIMARY KEY AUTO_INCREMENT,
Plan_Name VARCHAR(100) NOT NULL UNIQUE,
Minutes INT NOT NULL DEFAULT 0 CHECK (Minutes >= 0),
SMS INT NOT NULL DEFAULT 0 CHECK (SMS >= 0),
MB INT NOT NULL DEFAULT 0 CHECK (MB >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE CONTRACT (
Contract_id INT PRIMARY KEY AUTO_INCREMENT,
Phone_number VARCHAR(20) NOT NULL UNIQUE,
Start_date DATE NOT NULL,
End_date DATE NOT NULL,
Contract_Description VARCHAR(255),
Customer_id INT NOT NULL,
Plan_id INT NOT NULL,
CONSTRAINT chk_contract_dates CHECK (End_date >= Start_date),
CONSTRAINT Fk_Contract_Customer
FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id)
ON UPDATE CASCADE ON DELETE RESTRICT,
CONSTRAINT Fk_Contract_Plan
FOREIGN KEY (Plan_id) REFERENCES PLAN(Plan_id)
ON UPDATE CASCADE ON DELETE RESTRICT,
INDEX idx_contract_end_date (End_date),
INDEX idx_contract_plan (Plan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE CALLS (
Call_id BIGINT PRIMARY KEY AUTO_INCREMENT,
Contract_id INT NOT NULL,
Phone_Datetime DATETIME NOT NULL,
Called_phone VARCHAR(20) NOT NULL,
Duration INT NOT NULL CHECK (Duration > 0), 
CONSTRAINT Fk_Call_Contract
FOREIGN KEY (Contract_id) REFERENCES CONTRACT(Contract_id)
ON UPDATE CASCADE ON DELETE CASCADE,
INDEX idx_call_contract_datetime (Contract_id, Phone_Datetime),
INDEX idx_call_called_and_dt (Called_phone, Phone_Datetime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

# We create 2 triggers in order to be sure that: CONTRACT.Start_date ≤ CALLS.Phone_Datetime ≤ CONSTRACT.End_date
DELIMITER //
CREATE TRIGGER trg_calls_1
BEFORE INSERT ON CALLS
FOR EACH ROW
BEGIN
  DECLARE v_start DATE; DECLARE v_end DATE;
  SELECT Start_date, End_date INTO v_start, v_end
  FROM CONTRACT WHERE Contract_id = NEW.Contract_id;

  IF NEW.Phone_Datetime < v_start THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Call before contract Start_date';
  END IF;

  IF NEW.Phone_Datetime >= v_end + INTERVAL 1 DAY THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Call after contract End_date';
  END IF;
END//

CREATE TRIGGER trg_calls_2
BEFORE UPDATE ON CALLS
FOR EACH ROW
BEGIN
  DECLARE v_start DATE; DECLARE v_end DATE;
  SELECT Start_date, End_date INTO v_start, v_end
  FROM CONTRACT WHERE Contract_id = NEW.Contract_id;

  IF NEW.Phone_Datetime < v_start THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Call before contract Start_date';
  END IF;

  IF NEW.Phone_Datetime >= v_end + INTERVAL 1 DAY THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Call after contract End_date';
  END IF;
END//
DELIMITER ;

 #Insert a few records into the tables

INSERT INTO CITY (City_Name, Population, AVG_income) VALUES
('Athens',3000015,16000.00),
('Thessaloniki',1200000,14500.00),
('Patras',16446,12000.00);


INSERT INTO PLAN (Plan_Name, Minutes, SMS, MB) VALUES
('Red2',300,300,6000),
('Student',400,400,20000),
('Red1',150,150,3000),
('Freedom',1000,1000,50000);


INSERT INTO CUSTOMER (First_name, Last_name, Date_of_birth, Gender, City_id) VALUES
('Nikos','Papadopoulos','1988-03-12','Male',1),
('Maria','Ioannou','1992-07-25','Female',2),
('Giorgos','Konstantinou','1985-11-05','Male',2),
('Eleni','Christou','1990-02-18','Female',1),
('Dimitrios','Oikonomou','1995-09-30','Male',1),
('Katerina','Georgiou','1987-01-14','Female',2),
('Panagiotis','Nikolaou','1993-04-22','Male',3);


INSERT INTO CONTRACT (Phone_number, Start_date, End_date, Contract_Description, Customer_id, Plan_id) VALUES
('6940000001','2020-01-01','2025-11-20','Main line',1,1),
('6940000002','2019-05-15','2026-05-14','Student package',2,2),
('6940000003','2019-09-01','2025-12-10','Student package',3,2),
('6940000004','2020-02-10','2026-02-09','Main line',4,4),
('6940000005','2021-07-20','2025-12-25','Main line',5,4),
('6940000006','2020-11-11','2027-11-10','Main line',6,3),
('6940000007','2019-03-05','2026-03-04','Main line',7,1),
('6940000008','2020-12-01','2026-11-30','Student package',1,2),
('6940000009','2021-08-18','2026-08-17','Student package',2,2),
('6940000010','2020-06-22','2026-06-21','Main line',3,4);


INSERT INTO CALLS (Contract_id, Phone_Datetime, Called_phone, Duration) VALUES
(1,'2022-02-03 19:05:00','6940000009',4500),
(1,'2022-02-04 19:05:00','6940000009',5500),
(1,'2022-02-05 19:05:00','6940000009',1500),
(1,'2022-02-06 19:05:00','6940000009',11550),
(1,'2022-02-10 19:05:00','6940000009',11650),
(2,'2022-06-15 09:50:00','6940000005',25),
(3,'2022-01-12 14:10:00','2101234567',190),
(3,'2022-08-12 14:10:00','2101234567',190),
(1,'2022-02-03 09:05:00','6940000009',440),
(5,'2022-03-21 10:15:00','6940000001',310),
(5,'2022-09-21 10:15:00','6940000001',310),
(6,'2022-04-09 22:45:00','6940000005',60),
(7,'2022-07-30 11:00:00','2105558888',90),
(9,'2022-10-10 16:20:00','6940000005',450),
(9,'2022-12-25 09:05:00','6940000003',45),
(10,'2021-05-18 13:40:00','2109990000',175),
(5,'2021-07-20 14:10:00','2101234567',140), 
(2,'2021-02-03 19:05:00','6940000009',490),
(6,'2021-03-21 10:15:00','6940000001',360),
(7,'2021-04-09 22:45:00','6940000005',10),
(8,'2021-07-30 11:00:00','2105558888',100),
(9,'2021-10-10 16:20:00','6940000005',470),
(9,'2021-08-18 16:20:00','6940000003',170),
(9,'2021-12-25 09:05:00','6940000003',15),
(10,'2021-05-18 13:40:00','2109990000',75);
