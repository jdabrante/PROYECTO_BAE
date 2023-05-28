-- Municipio

INSERT INTO municipio VALUES('38400','Puerto de la Cruz');
INSERT INTO municipio VALUES('38000','La Cuesta');
INSERT INTO municipio VALUES('38120','San Andres');
INSERT INTO municipio VALUES('38314','La Orotava');

DELIMITER $$
DROP FUNCTION IF EXISTS codigo_postal_random $$
CREATE FUNCTION codigo_postal_random() RETURNS VARCHAR(5)
DETERMINISTIC
BEGIN
    RETURN (SELECT codigo_postal FROM municipio ORDER BY RAND() LIMIT 1);
END
$$

-- Dirección

DROP PROCEDURE IF EXISTS insertar_direccion $$
CREATE PROCEDURE insertar_direccion(IN cantidad INT)
BEGIN
    DECLARE _codigo_postal VARCHAR(5);
    DECLARE _calle VARCHAR(50);
    DECLARE _numero INT;
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET contador = 0;
    WHILE (contador < cantidad) DO
        SET _codigo_postal = (SELECT codigo_postal_random());
        SET i = FLOOR(RAND()*5);
        CASE i
            WHEN 0 THEN SET _calle = 'C/Los Nidos';
            WHEN 1 THEN SET _calle = 'C/Reyes Católicos';
            WHEN 2 THEN SET _calle = 'C/Del Medio';
            WHEN 3 THEN SET _calle = 'C/Del Sol';
            WHEN 4 THEN SET _calle = 'C/Almirante';
        END CASE;
        SET _numero = (SELECT RAND() * (50) + 1);
        INSERT INTO direccion(codigo_postal_municipio,calle,numero) VALUES(_codigo_postal,_calle,_numero);
        SET contador = contador + 1;
    END WHILE;
END
$$

-- Usuario 

DROP PROCEDURE IF EXISTS insertar_usuario $$
CREATE PROCEDURE insertar_usuario(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _nombre VARCHAR(20);
    DECLARE _apellido1 VARCHAR(20);
    DECLARE _apellido2 VARCHAR(20);
    DECLARE _telefono VARCHAR(20);
    DECLARE contador INT;
    DECLARE letras VARCHAR(27);
    DECLARE _id_direccion INT;
    CREATE TABLE nombre_apellido (
        nombre VARCHAR(20),
        apellido VARCHAR(20)
    );
    INSERT INTO nombre_apellido VALUES('Dimas','Abrante');
    INSERT INTO nombre_apellido VALUES('Juan','Gonzalez');
    INSERT INTO nombre_apellido VALUES('Javier','Hernandez');
    INSERT INTO nombre_apellido VALUES('Noelia','Carrillo');
    INSERT INTO nombre_apellido VALUES('Nuhazet','Torres');
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador < cantidad) DO
        SET _id_direccion = (SELECT id FROM direccion ORDER BY RAND() LIMIT 1);
        SET _dni = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * 27)),1)));
        SET _dni = LPAD(_dni, 9, 0);
        SET _nombre = (SELECT nombre FROM nombre_apellido ORDER BY RAND() LIMIT 1);
        SET _apellido1 = (SELECT apellido FROM nombre_apellido ORDER BY RAND() LIMIT 1);
        SET _apellido2 = (SELECT apellido FROM nombre_apellido ORDER BY RAND() LIMIT 1);
        SET _telefono = CONCAT("+",(SELECT FLOOR(RAND()*(2000) + 1)),(SELECT FLOOR(RAND() * (100000000) + 100000000)));
        INSERT INTO usuario VALUES(_dni,_nombre,_apellido1,_apellido2,_telefono,_id_direccion);
        SET contador = contador + 1;
    END WHILE ;
    DROP TABLE nombre_apellido;
END 
$$

-- Cliente

-- Dar DNI no repetidos

DROP FUNCTION IF EXISTS dni_no_rep_cl $$
CREATE FUNCTION dni_no_rep_cl() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM usuario) AND (SELECT _dni in (SELECT dni FROM cliente)) DO
        SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

DROP PROCEDURE IF EXISTS insertar_cliente $$
CREATE PROCEDURE insertar_cliente(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _categoria VARCHAR(20);
    DECLARE _residente BOOLEAN;
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_cl());
        SET i = FLOOR(RAND()*3);
        CASE i
            WHEN 0 THEN  SET _categoria = 'Premium';
            WHEN 1 THEN  SET _categoria = 'Standard';
            WHEN 2 THEN  SET _categoria = 'Diamond';
        END CASE;
        SET _residente = (SELECT FLOOR(RAND()*10)%2);
        INSERT INTO cliente VALUES(_dni, _categoria,_residente);
        SET contador = contador + 1;
    END WHILE;
END
$$

-- Administrador 

-- Dar DNI no repetidos

DROP FUNCTION IF EXISTS dni_no_rep_ador $$
CREATE FUNCTION dni_no_rep_ador() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM usuario) AND (SELECT _dni in (SELECT dni FROM administrador)) DO
        SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

DROP PROCEDURE IF EXISTS insertar_administrador $$
CREATE PROCEDURE insertar_administrador(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _permiso VARCHAR(20);
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_ador());
        SET i = FLOOR(RAND()*9);
        CASE i
            WHEN 0 THEN SET _permiso = 'CRUD';
            WHEN 1 THEN SET _permiso = 'CR';
            WHEN 2 THEN SET _permiso = 'CRU';
            WHEN 3 THEN SET _permiso = 'UD';
            WHEN 4 THEN SET _permiso = 'RUD';
            WHEN 5 THEN SET _permiso = 'C';
            WHEN 6 THEN SET _permiso = 'R';
            WHEN 7 THEN SET _permiso = 'U';
            WHEN 8 THEN SET _permiso = 'D';
        END CASE;
        INSERT INTO administrador VALUES(_dni,_permiso);
        SET contador = contador + 1;
    END WHILE;
END
$$

-- Personal

-- Dar DNI no repetidos

DROP FUNCTION IF EXISTS dni_no_rep_per $$
CREATE FUNCTION dni_no_rep_per() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9); 
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM usuario LIMIT contador, 1);
    WHILE (contador <= (SELECT COUNT(*) FROM usuario) AND (SELECT _dni in (SELECT dni FROM personal))) 
    DO
        SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

DROP PROCEDURE IF EXISTS insertar_personal $$
CREATE PROCEDURE insertar_personal(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _nuss VARCHAR(12);
    DECLARE _tipo_contrato ENUM('indefinido','practica','temporal');
    DECLARE _salario DECIMAL(8,2);
    DECLARE letras VARCHAR(27);
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_per());
        SET _nuss = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * 27)),1)));
        SET _nuss = LPAD(_nuss, 9, 0);
        SET i = FLOOR(RAND()*3);
        CASE i
            WHEN 0 THEN SET _tipo_contrato = 'indefinido';
            WHEN 1 THEN SET _tipo_contrato = 'practica';
            WHEN 2 THEN SET _tipo_contrato = 'temporal';
        END CASE;
        SET _salario = (SELECT ROUND((SELECT RAND() * (1000000)),2));
        INSERT INTO personal VALUES(_dni,_nuss,_tipo_contrato,_salario);
        SET contador = contador + 1;
    END WHILE;
END
$$

-- Administrativo

DROP PROCEDURE IF EXISTS insertar_administrativo $$
CREATE PROCEDURE insertar_administrativo(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _seccion VARCHAR(20);
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET contador = 0;
    WHILE (contador < cantidad) 
    DO
        SET _dni = (SELECT dni FROM personal ORDER BY RAND() LIMIT 1);
        IF (NOT EXISTS(SELECT * FROM dni_usados WHERE dni = _dni)) THEN
            SET i = FLOOR(RAND()*5);
            CASE i
                WHEN 0 THEN SET _seccion = 'A';
                WHEN 1 THEN SET _seccion = 'B';
                WHEN 2 THEN SET _seccion = 'C';
                WHEN 3 THEN SET _seccion = 'D';
                WHEN 4 THEN SET _seccion = 'E';
            END CASE;
            INSERT INTO administrativo VALUES(_dni, _seccion);
            SET contador = contador + 1;
        END IF;
    END WHILE;
END
$$

-- Veterinario

DROP PROCEDURE IF EXISTS insertar_veterinario $$
CREATE PROCEDURE insertar_veterinario(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _licencia VARCHAR(9);
    DECLARE _especialidad VARCHAR(20);
    DECLARE contador INT;
    DECLARE letras VARCHAR(27);
    DECLARE i TINYINT;
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador < cantidad) 
    DO
        SET _dni = (SELECT dni FROM personal ORDER BY RAND() LIMIT 1);
        IF (NOT EXISTS(SELECT * FROM dni_usados WHERE dni = _dni)) THEN
            SET _licencia = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * 27)),1)));
            SET _licencia = LPAD(_licencia, 9, 0);
            SET i = FLOOR(RAND()*4);
            CASE i
                WHEN 0 THEN SET _especialidad = 'cardiologia';
                WHEN 1 THEN SET _especialidad = 'oncologia';
                WHEN 2 THEN SET _especialidad = 'dermatologia';
                WHEN 3 THEN SET _especialidad = 'oftalmologia';
            END CASE;
            INSERT INTO veterinario VALUES(_dni,_licencia,_especialidad);
            SET contador = contador + 1;
        END IF;
    END WHILE;
END 
$$

-- Auxiliar

DROP PROCEDURE IF EXISTS insertar_auxiliar $$
CREATE PROCEDURE insertar_auxiliar(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _especialidad VARCHAR(20);
    DECLARE contador INT;
    DECLARE i TINYINT;
    SET contador = 0;
    WHILE (contador < cantidad) 
    DO
        SET _dni = (SELECT dni FROM personal ORDER BY RAND() LIMIT 1);
        IF (NOT EXISTS(SELECT * FROM dni_usados WHERE dni = _dni)) THEN
            SET i = FLOOR(RAND()*4);
            CASE i
                WHEN 0 THEN SET _especialidad = 'cardiologia';
                WHEN 1 THEN SET _especialidad = 'oncologia';
                WHEN 2 THEN SET _especialidad = 'dermatologia';
                WHEN 3 THEN SET _especialidad = 'oftalmologia';
            END CASE;
            INSERT INTO auxiliar VALUES(_dni,_especialidad);
            SET contador = contador + 1;
        END IF;
    END WHILE ;
END 
$$

-- Mascota

DROP PROCEDURE IF EXISTS insertar_mascota $$
CREATE PROCEDURE insertar_mascota(IN cantidad INT)
BEGIN
    DECLARE _id VARCHAR(9);
    DECLARE _id_cliente VARCHAR(9);
    DECLARE _especie VARCHAR(20);
    DECLARE _edad SMALLINT;
    DECLARE _sexo ENUM('M','H');
    DECLARE contador INT;
    DECLARE letras VARCHAR(27);
    DECLARE i TINYINT;
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _id = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * 27)),1)));
        SET _id = LPAD(_id, 9, 0);
        SET _id_cliente = (SELECT dni FROM cliente ORDER BY RAND() LIMIT 1);
        SET _edad = (SELECT FLOOR(RAND() * (20) + 1));
        SET i = FLOOR(RAND()*6);
        CASE i
            WHEN 0 THEN SET _especie = 'Perro';
            WHEN 1 THEN SET _especie = 'Gato';
            WHEN 2 THEN SET _especie = 'Conejo';
            WHEN 3 THEN SET _especie = 'Pajaro';
            WHEN 4 THEN SET _especie = 'Tortuga';
            WHEN 5 THEN SET _especie = 'Lagarto';
        END CASE;
        IF (SELECT FLOOR(RAND() * 10)) > 5 THEN
            SET _sexo = 'M';
        ELSE
            SET _sexo = 'H';
        END IF;
        INSERT INTO mascota VALUES(_id, _id_cliente, _especie,_edad, _sexo);
        SET contador = contador + 1;
    END WHILE ;

END 
$$

-- Cita

DROP PROCEDURE IF EXISTS crear_cita $$
CREATE PROCEDURE crear_cita(IN cantidad INT)
BEGIN
    DECLARE _id_mascota VARCHAR(9);
    DECLARE _id_veterinario VARCHAR(9);
    DECLARE _fecha DATE;
    DECLARE _hora TIME;
    DECLARE _urgencia BOOLEAN;
    DECLARE contador INT;
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _id_mascota = (SELECT id FROM mascota ORDER BY RAND() LIMIT 1);
        SET _id_veterinario = (SELECT dni FROM veterinario ORDER BY RAND() LIMIT 1);
        SET _fecha = (SELECT CURRENT_DATE);
        SET _hora = (SELECT CURRENT_TIME);
        IF (SELECT FLOOR(RAND() * 10)) > 5 THEN
            SET _urgencia = '1';
        ELSE
            SET _urgencia = '0';
        END IF;
        INSERT INTO cita(fecha,hora,urgencia,id_mascota,id_veterinario) VALUES(_fecha,_hora,_urgencia,_id_mascota,_id_veterinario);
        SET contador = contador + 1;
    END WHILE;
END 
$$

-- Cita_Auxiliar

DROP TRIGGER IF EXISTS generar_cita_auxiliar $$
CREATE TRIGGER generar_cita_auxiliar
AFTER INSERT ON cita
FOR EACH ROW
BEGIN
    DECLARE _id_auxiliar VARCHAR(9);
    DECLARE cantidad_aux TINYINT;
    DECLARE contador TINYINT;
    DECLARE aux_registrados SMALLINT;
    SET cantidad_aux = (SELECT FLOOR(RAND()*3));
    SET aux_registrados = (SELECT count(*) FROM auxiliar);
    IF (cantidad_aux > aux_registrados) THEN 
        SET cantidad_aux = aux_registrados;
    END IF;
    SET contador = 0;
    WHILE (contador < cantidad_aux) DO
        SET _id_auxiliar = (SELECT dni FROM auxiliar ORDER BY RAND() LIMIT 1);
        IF NOT EXISTS(SELECT * FROM cita_auxiliar WHERE id_cita = NEW.id AND id_auxiliar = _id_auxiliar) THEN
            INSERT INTO cita_auxiliar VALUES(NEW.id, _id_auxiliar);
            SET contador = contador + 1;
        END IF;
    END WHILE;
END
$$

-- Historial

DROP TRIGGER IF EXISTS generar_historial $$
CREATE TRIGGER generar_historial
AFTER INSERT ON cita 
FOR EACH ROW
BEGIN
    IF (NEW.id % 2 = 0) THEN
        INSERT INTO historial(id, resolucion) VALUES(NEW.id, 'cancelada');
    ELSEIF (NEW.id % 3 = 0) THEN 
        INSERT INTO historial VALUES(NEW.id, 'atendida', 'lorem ipsum', 'lorem ipsum');
    END IF;
END
$$

-- ALTER TABLE mascota DROP INDEX idx_especie
-- $$
CREATE INDEX idx_especie ON mascota(especie)
$$
-- ALTER TABLE cita DROP INDEX idx_urgencia
-- $$
CREATE INDEX idx_urgencia ON cita(urgencia)
$$

CREATE FULLTEXT INDEX idx_descripcion ON historial(descripcion)
$$

DROP VIEW IF EXISTS historial_mascota
$$
CREATE VIEW historial_mascota AS
(SELECT c.*, h.resolucion, h.anotacion, h.descripcion 
FROM cita AS c JOIN historial AS h ON c.id = h.id
WHERE h.resolucion = 'atendida')
$$

DROP VIEW IF EXISTS veterinario_info
$$
CREATE VIEW veterinario_info AS
(SELECT u.*, p.nuss, p.tipo_contrato, p.salario, v.licencia, v.especialidad 
FROM usuario AS u JOIN personal AS p ON u.dni = p.dni JOIN veterinario AS v ON u.dni = v.dni)
$$

DROP VIEW IF EXISTS auxiliar_info
$$
CREATE VIEW auxiliar_info AS
(SELECT u.*, p.nuss, p.tipo_contrato, p.salario, a.especialidad 
FROM usuario AS u JOIN personal AS p ON u.dni = p.dni JOIN auxiliar AS a ON u.dni = a.dni)
$$

DROP VIEW IF EXISTS dni_usados
$$
CREATE VIEW dni_usados AS
(SELECT dni
FROM auxiliar 
UNION SELECT dni FROM veterinario
UNION SELECT dni FROM administrativo)
$$

DELIMITER ;
