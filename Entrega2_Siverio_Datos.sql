-- Entrega2_Siverio_Datos.sql

-- INSERTAR PACIENTES
INSERT INTO Pacientes (Nombre, Apellido, Cedula, Telefono, Direccion, Fecha_Nacimiento)
VALUES 
('Carlos', 'Soto', '123456789', '3200000000', 'Calle 1 #23-45', '1990-04-10'),
('Laura', 'Ramírez', '987654321', '3101112233', 'Carrera 8 #12-34', '1985-06-20');

-- INSERTAR DOCTORES
INSERT INTO Doctores (Nombre, Apellido, Cedula_Profesional, Especialidad)
VALUES 
('Andrés', 'Pérez', 'OD123456', 'Ortodoncia'),
('María', 'Gómez', 'OD654321', 'Endodoncia');

-- INSERTAR TRATAMIENTOS
INSERT INTO Tratamientos (Nombre, Descripcion, Costo)
VALUES 
('Limpieza', 'Limpieza dental básica', 50000),
('Carilla', 'Aplicación de carilla estética', 150000);

-- INSERTAR CITAS
INSERT INTO Citas (ID_Paciente, ID_Doctor, ID_Tratamiento, Fecha, Hora, Motivo)
VALUES 
(1, 1, 1, '2025-07-15', '10:00:00', 'Revisión general'),
(2, 2, 2, '2025-07-16', '14:30:00', 'Estética dental');

-- =========================
-- VISTAS
-- =========================

CREATE VIEW Vista_Pacientes_Citas AS
SELECT p.ID_Paciente, p.Nombre, p.Apellido, c.ID_Cita, c.Fecha, c.Hora
FROM Pacientes p
JOIN Citas c ON p.ID_Paciente = c.ID_Paciente;

CREATE VIEW Vista_Doctor_Tratamientos AS
SELECT d.ID_Doctor, d.Nombre AS NombreDoctor, d.Apellido AS ApellidoDoctor, t.Nombre AS Tratamiento, c.ID_Cita
FROM Doctores d
JOIN Citas c ON d.ID_Doctor = c.ID_Doctor
JOIN Tratamientos t ON c.ID_Tratamiento = t.ID_Tratamiento;

CREATE VIEW Vista_Citas_Proximas AS
SELECT c.ID_Cita, c.Fecha, c.Hora, p.Nombre AS Paciente, d.Nombre AS Doctor
FROM Citas c
JOIN Pacientes p ON c.ID_Paciente = p.ID_Paciente
JOIN Doctores d ON c.ID_Doctor = d.ID_Doctor
WHERE c.Fecha >= CURDATE();

CREATE VIEW Vista_Tratamientos_Mas_Caros AS
SELECT *
FROM Tratamientos
WHERE Costo > (SELECT AVG(Costo) FROM Tratamientos);

CREATE VIEW Vista_Resumen_Citas AS
SELECT d.ID_Doctor, d.Nombre, d.Apellido, COUNT(c.ID_Cita) AS TotalCitas
FROM Doctores d
LEFT JOIN Citas c ON d.ID_Doctor = c.ID_Doctor
GROUP BY d.ID_Doctor, d.Nombre, d.Apellido;

-- =========================
-- FUNCIONES
-- =========================

DELIMITER $$

CREATE FUNCTION fn_CalcularEdad(fecha_nac DATE) RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE());
END $$

CREATE FUNCTION fn_CostoTotalPaciente(paciente_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT IFNULL(SUM(t.Costo),0) INTO total
    FROM Citas c
    JOIN Tratamientos t ON c.ID_Tratamiento = t.ID_Tratamiento
    WHERE c.ID_Paciente = paciente_id;
    RETURN total;
END $$

DELIMITER ;

-- =========================
-- STORED PROCEDURES
-- =========================

DELIMITER $$

CREATE PROCEDURE sp_AgregarCita(
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_id_paciente INT,
    IN p_id_doctor INT,
    IN p_id_tratamiento INT
)
BEGIN
    INSERT INTO Citas (Fecha, Hora, ID_Paciente, ID_Doctor, ID_Tratamiento)
    VALUES (p_fecha, p_hora, p_id_paciente, p_id_doctor, p_id_tratamiento);
END $$

CREATE PROCEDURE sp_ActualizarTelefonoPaciente(
    IN p_id_paciente INT,
    IN p_nuevo_telefono VARCHAR(20)
)
BEGIN
    UPDATE Pacientes
    SET Telefono = p_nuevo_telefono
    WHERE ID_Paciente = p_id_paciente;
END $$

DELIMITER ;

-- =========================
-- TRIGGERS
-- =========================

DELIMITER $$

CREATE TRIGGER trg_AntesInsertarCita
BEFORE INSERT ON Citas
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Pacientes WHERE ID_Paciente = NEW.ID_Paciente) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no existe';
    END IF;
    IF (SELECT COUNT(*) FROM Doctores WHERE ID_Doctor = NEW.ID_Doctor) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El doctor no existe';
    END IF;
END $$

CREATE TRIGGER trg_DespuesEliminarPaciente
AFTER DELETE ON Pacientes
FOR EACH ROW
BEGIN
    DELETE FROM Citas WHERE ID_Paciente = OLD.ID_Paciente;
END $$

DELIMITER ;
