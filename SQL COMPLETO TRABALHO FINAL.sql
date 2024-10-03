CREATE DATABASE IF NOT EXISTS oficina2;
USE oficina2;

CREATE TABLE clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Minit VARCHAR(3),
    Lname VARCHAR(50) NOT NULL,
    CPF CHAR(11) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    clientType ENUM('Pessoa Física', 'Pessoa Jurídica') NOT NULL,
    CONSTRAINT unique_cpf_client UNIQUE (CPF)
);

CREATE TABLE vehicles (
    idVehicle INT AUTO_INCREMENT PRIMARY KEY,
    idClient INT NOT NULL,
    plate VARCHAR(10) NOT NULL,
    model VARCHAR(100) NOT NULL,
    Year INT NOT NULL,
    CONSTRAINT fk_idClient_vehicles FOREIGN KEY (idClient) REFERENCES clients(idClient)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE mechanic (
    idMechanic INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Minit VARCHAR(3),
    Lname VARCHAR(50) NOT NULL,
    CPF CHAR(11) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Expertise VARCHAR(100) NOT NULL,
    CONSTRAINT unique_cpf_mechanic UNIQUE (CPF)
);


CREATE TABLE service_order (
    idService_order INT AUTO_INCREMENT PRIMARY KEY,
    Numero INT NOT NULL,
    issue_date DATE,
    total_value FLOAT,
    service_order_status ENUM('Aberta', 'Em Andamento', 'Concluída', 'Cancelada') NOT NULL,
    conclusion_date DATE,
    idVehicle INT NOT NULL,
    idMechanic INT,
    CONSTRAINT fk_idVehicle_service_order FOREIGN KEY (idVehicle) REFERENCES vehicles(idVehicle)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_idMechanic_service_order FOREIGN KEY (idMechanic) REFERENCES mechanic(idMechanic)
        ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE part (
    idPart INT AUTO_INCREMENT PRIMARY KEY,
    about VARCHAR(255) NOT NULL,
    value FLOAT NOT NULL,
    idService_order INT NOT NULL,
    CONSTRAINT fk_idService_order_part FOREIGN KEY (idService_order) REFERENCES service_order(idService_order)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE labor_reference (
    idLabor_reference INT AUTO_INCREMENT PRIMARY KEY,
    about_service VARCHAR(255) NOT NULL,
    labor_value FLOAT NOT NULL
);


CREATE TABLE service (
    idService INT AUTO_INCREMENT PRIMARY KEY,
    about VARCHAR(200) NOT NULL,
    service_value FLOAT NOT NULL,
    idService_order INT NOT NULL,
    idLabor_reference INT NOT NULL,
    CONSTRAINT fk_idService_order_service FOREIGN KEY (idService_order) REFERENCES service_order(idService_order)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_idLabor_reference_service FOREIGN KEY (idLabor_reference) REFERENCES labor_reference(idLabor_reference)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


INSERT INTO clients (Fname, Minit, Lname, CPF, Address, clientType)
VALUES 
    ('João', 'P', 'Silva', '12345678901', 'Rua A, 100', 'Pessoa Física'),
    ('Maria', 'L', 'Oliveira', '98765432100', 'Rua B, 200', 'Pessoa Jurídica'),
    ('José', 'M', 'Santos', '32165498702', 'Rua C, 300', 'Pessoa Física');

INSERT INTO vehicles (idClient, plate, model, Year)
VALUES 
    (1, 'ABC1234', 'Honda Civic', 2020),
    (2, 'XYZ5678', 'Toyota Corolla', 2019),
    (3, 'DEF7890', 'Chevrolet Onix', 2021);

INSERT INTO mechanic (Fname, Minit, Lname, CPF, Address, Expertise)
VALUES 
    ('Carlos', 'B', 'Souza', '45678912345', 'Rua D, 400', 'Motor'),
    ('Ana', 'M', 'Costa', '78912345678', 'Rua E, 500', 'Suspensão'),
    ('Pedro', 'F', 'Almeida', '15975325846', 'Rua F, 600', 'Elétrica');

INSERT INTO service_order (Numero, issue_date, total_value, service_order_status, conclusion_date, idVehicle, idMechanic)
VALUES 
    (1001, '2023-09-01', 1500.00, 'Concluída', '2023-09-10', 1, 1),
    (1002, '2023-09-05', 2000.00, 'Aberta', NULL, 2, 2),
    (1003, '2023-09-10', 1800.00, 'Em Andamento', NULL, 3, 3);


INSERT INTO part (about, value, idService_order)
VALUES 
    ('Filtro de ar', 50.00, 1),
    ('Óleo de motor', 120.00, 1),
    ('Correia dentada', 300.00, 2);

INSERT INTO labor_reference (about_service, labor_value)
VALUES 
    ('Troca de óleo', 150.00),
    ('Revisão completa', 500.00),
    ('Troca de correia dentada', 200.00);

INSERT INTO service (about, service_value, idService_order, idLabor_reference)
VALUES 
    ('Troca de óleo', 270.00, 1, 1),
    ('Revisão completa', 600.00, 2, 2),
    ('Troca de correia dentada', 500.00, 3, 3);



SELECT * FROM clients;
select * from vehicles;
select * from part;
select * from mechanic;
select * from service_order;
select * from labor_reference;
select * from service;


SELECT * FROM service_order WHERE service_order_status = 'Aberta';


SELECT so.Numero AS 'Número do Serviço', SUM(p.value) + SUM(s.service_value) AS 'Custo'
FROM service_order so
JOIN part p ON so.idService_order = p.idService_order
JOIN service s ON so.idService_order = s.idService_order
GROUP BY so.Numero;

SELECT * FROM mechanic ORDER BY Fname ASC;


SELECT so.Numero AS 'Número do Serviço', SUM(p.value) + SUM(s.service_value) AS 'Custo'
FROM service_order so
JOIN part p ON so.idService_order = p.idService_order
JOIN service s ON so.idService_order = s.idService_order
GROUP BY so.Numero
HAVING SUM(p.value) + SUM(s.service_value) >= 900;


SELECT 
    so.Numero AS 'Número do Serviço',
    c.Fname AS 'Nome do Cliente',
    c.Lname AS 'Sobrenome do Cliente',
    m.Fname AS 'Nome do Mecânico',
    m.Expertise AS 'Especialidade do Mecânico',
    so.service_order_status AS 'Status da Ordem'
	FROM service_order so
	JOIN vehicles v ON so.idVehicle = v.idVehicle
	JOIN clients c ON v.idClient = c.idClient
	JOIN mechanic m ON so.idMechanic = m.idMechanic;