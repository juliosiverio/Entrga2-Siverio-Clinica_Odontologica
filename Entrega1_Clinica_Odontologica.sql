-- Entrega1_Clinica_Odontologica.sql

CREATE DATABASE clinica_odontologica;
USE clinica_odontologica;

CREATE TABLE Pacientes (
    ID_Paciente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Cedula VARCHAR(20) UNIQUE,
    Telefono VARCHAR(20),
    Direccion VARCHAR(150),
    Fecha_Nacimiento DATE
);

CREATE TABLE Doctores (
    ID_Doctor INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Cedula_Profesional VARCHAR(30) UNIQUE,
    Especialidad VARCHAR(50)
);

CREATE TABLE Tratamientos (
    ID_Tratamiento INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion TEXT,
    Costo DECIMAL(10,2)
);

CREATE TABLE Citas (
    ID_Cita INT AUTO_INCREMENT PRIMARY KEY,
    ID_Paciente INT,
    ID_Doctor INT,
    ID_Tratamiento INT,
    Fecha DATE,
    Hora TIME,
    Motivo VARCHAR(255),
    FOREIGN KEY (ID_Paciente) REFERENCES Pacientes(ID_Paciente),
    FOREIGN KEY (ID_Doctor) REFERENCES Doctores(ID_Doctor),
    FOREIGN KEY (ID_Tratamiento) REFERENCES Tratamientos(ID_Tratamiento)
);
