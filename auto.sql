-- Randomizar todo con un trigger según se insertan usuarios

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

-- # Randomizador

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_direccion $$
CREATE PROCEDURE insertar_direccion(IN cantidad INT)
BEGIN
    DECLARE _codigo_postal VARCHAR(5);
    DECLARE _calle VARCHAR(50);
    DECLARE _numero INT;
    DECLARE contador INT;
    -- # Tabla auxiliar de calles
    CREATE TABLE calle (
        nombre VARCHAR(50)
    );
    INSERT INTO calle VALUES('C/Los Nidos');
    INSERT INTO calle VALUES('C/Reyes Católicos');
    INSERT INTO calle VALUES('C/Del Medio');
    INSERT INTO calle VALUES('C/Del Sol');
    INSERT INTO calle VALUES('C/Almirante');
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _codigo_postal = (SELECT codigo_postal_random());
        SET _calle = (SELECT nombre FROM calle ORDER BY RAND() LIMIT 1);
        SET _numero = (SELECT RAND() * (50) + 1);
        INSERT INTO direccion(codigo_postal_municipio,calle,numero) VALUES(_codigo_postal,_calle,_numero);
        SET contador = contador + 1;
    END WHILE;
    DROP TABLE calle;
END
$$



-- Usuario 

-- # Randomizador

DELIMITER $$
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
    -- Tablas axuiliares nombre y apellido
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
    WHILE (contador <= cantidad) DO
        SET _id_direccion = (SELECT id FROM direccion ORDER BY RAND() LIMIT 1);
        SET _dni = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * (10) + 1)),1)));
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

-- # Tabla auxiliar Categoria

-- # Dar DNI no repetidos

DELIMITER $$
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


-- # Randomizador 

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_cliente $$
CREATE PROCEDURE insertar_cliente(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _categoria VARCHAR(20);
    DECLARE _residente BOOLEAN;
    DECLARE contador INT;
    CREATE TABLE categoria (
        nombre VARCHAR(20)
    );
    INSERT INTO categoria VALUES('Premium');
    INSERT INTO categoria VALUES('Standard');
    INSERT INTO categoria VALUES('Diamond');
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_cl());
        SET _categoria = (SELECT nombre FROM categoria ORDER BY RAND() LIMIT 1);
        SET _residente = (SELECT FLOOR(RAND()*10)%2);
        INSERT INTO cliente VALUES(_dni,_categoria,_residente);
        SET contador = contador + 1;
    END WHILE;
    DROP TABLE categoria;
END
$$

-- Administrador 

-- # Dar DNI no repetidos

DELIMITER $$
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


-- # Randomizador 

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_administrador $$
CREATE PROCEDURE insertar_administrador(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _permiso VARCHAR(20);
    DECLARE contador INT;
    -- # Tabla auxiliar permisos
    CREATE TABLE permiso (
        nombre VARCHAR(20)
    );
    INSERT INTO permiso VALUES('CRUD');
    INSERT INTO permiso VALUES('CR');
    INSERT INTO permiso VALUES('CRU');
    INSERT INTO permiso VALUES('UD');
    INSERT INTO permiso VALUES('RUD');
    INSERT INTO permiso VALUES('C');
    INSERT INTO permiso VALUES('R');
    INSERT INTO permiso VALUES('U');
    INSERT INTO permiso VALUES('D');
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_ador());
        SET _permiso = (SELECT nombre FROM permiso ORDER BY RAND() LIMIT 1);
        INSERT INTO administrador VALUES(_dni,_permiso);
        SET contador = contador + 1;
    END WHILE;
    DROP TABLE permiso;
END
$$

-- Personal

-- # Dar DNI no repetidos

DELIMITER $$
DROP FUNCTION IF EXISTS dni_no_rep_per $$
CREATE FUNCTION dni_no_rep_per() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM usuario) AND (SELECT _dni in (SELECT dni FROM personal)) DO
        SET _dni = (SELECT dni FROM usuario LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

-- # Randomizador

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_personal $$
CREATE PROCEDURE insertar_personal(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _nuss VARCHAR(12);
    DECLARE _tipo_contrato ENUM('indefinido','practica','temporal');
    DECLARE _salario DECIMAL(8,2);
    DECLARE letras VARCHAR(27);
    DECLARE contador INT;
    -- # Tabla axuxiliar de contratos
    CREATE TABLE tipo_contrato (
        nombre VARCHAR(20)
    );
    INSERT INTO tipo_contrato VALUES('indefinido');
    INSERT INTO tipo_contrato VALUES('practica');
    INSERT INTO tipo_contrato VALUES('temporal');
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_per());
        SET _nuss = CONCAT((SELECT FLOOR(RAND()*(10000000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * (10) + 1)),1)));
        SET _tipo_contrato = (SELECT nombre FROM tipo_contrato ORDER BY RAND() LIMIT 1);
        SET _salario = (SELECT ROUND((SELECT RAND() * (1000000)),2));
        INSERT INTO personal VALUES(_dni,_nuss,_tipo_contrato,_salario);
        SET contador = contador + 1;
    END WHILE;
    DROP TABLE tipo_contrato;
END
$$

-- Administrativo

-- # Dar DNI no repetidos

DELIMITER $$
DROP FUNCTION IF EXISTS dni_no_rep_advo $$
CREATE FUNCTION dni_no_rep_advo() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM personal LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM personal) AND (SELECT _dni in (SELECT dni FROM administrativo)) DO
        SET _dni = (SELECT dni FROM personal LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_administrativo $$
CREATE PROCEDURE insertar_administrativo(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _seccion VARCHAR(20);
    DECLARE contador INT;
    -- # Tabla auxiliar Sección
    CREATE TABLE seccion (
        nombre VARCHAR(20)
    );
    INSERT INTO seccion VALUES('A');
    INSERT INTO seccion VALUES('B');
    INSERT INTO seccion VALUES('C');
    INSERT INTO seccion VALUES('D');
    INSERT INTO seccion VALUES('E');
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_advo());
        SET _seccion = (SELECT nombre FROM seccion ORDER BY RAND() LIMIT 1);
        INSERT INTO administrativo VALUES(_dni,_seccion);
        SET contador = contador + 1;
    END WHILE;
    DROP TABLE seccion;
END
$$

-- Veterinario

-- # Dar DNI no repetidos

DELIMITER $$
DROP FUNCTION IF EXISTS dni_no_rep_vet $$
CREATE FUNCTION dni_no_rep_vet() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM personal LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM personal) AND (SELECT _dni in (SELECT dni FROM veterinario)) DO
        SET _dni = (SELECT dni FROM personal LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

-- # Tabla auxiliar Especialidad

-- Randomizador

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_veterinario $$
CREATE PROCEDURE insertar_veterinario(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _licencia VARCHAR(9);
    DECLARE _especialidad VARCHAR(20);
    DECLARE contador INT;
    DECLARE letras VARCHAR(27);
    CREATE TABLE especialidad (
        nombre VARCHAR(20)
    );
    INSERT INTO especialidad VALUES('cardiologia');
    INSERT INTO especialidad VALUES('oncologia');
    INSERT INTO especialidad VALUES('dermatologia');
    INSERT INTO especialidad VALUES('oftalmologia');
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_vet());
        SET _licencia = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * (10) + 1)),1)));
        SET _especialidad = (SELECT nombre FROM especialidad ORDER BY RAND() LIMIT 1);
        INSERT INTO veterinario VALUES(_dni,_licencia,_especialidad);
        SET contador = contador + 1;
    END WHILE ;
    DROP TABLE especialidad;
END 
$$

-- Auxiliar

-- # Dar DNI no repetidos

DELIMITER $$
DROP FUNCTION IF EXISTS dni_no_rep_aux $$
CREATE FUNCTION dni_no_rep_aux() RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE contador INT;
    SET contador = 0;
    SET _dni = (SELECT dni FROM personal LIMIT contador,1);
    SET contador = contador + 1;
    WHILE contador <= (SELECT count(*) FROM personal) AND (SELECT _dni in (SELECT dni FROM auxiliar)) DO
        SET _dni = (SELECT dni FROM personal LIMIT contador,1);
        SET contador = contador + 1;
    END WHILE;
    RETURN _dni;
END
$$

-- Randomizador

DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_auxiliar $$
CREATE PROCEDURE insertar_auxiliar(IN cantidad INT)
BEGIN
    DECLARE _dni VARCHAR(9);
    DECLARE _especialidad VARCHAR(20);
    DECLARE contador INT;
    CREATE TABLE especialidad (
        nombre VARCHAR(20)
    );
    INSERT INTO especialidad VALUES('cardiologia');
    INSERT INTO especialidad VALUES('oncologia');
    INSERT INTO especialidad VALUES('dermatologia');
    INSERT INTO especialidad VALUES('oftalmologia');
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _dni = (SELECT dni_no_rep_aux());
        SET _especialidad = (SELECT nombre FROM especialidad ORDER BY RAND() LIMIT 1);
        INSERT INTO auxiliar VALUES(_dni,_especialidad);
        SET contador = contador + 1;
    END WHILE ;
    DROP TABLE especialidad;
END 
$$

-- Mascota

-- Randomizador

DELIMITER $$
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
-- # Tabla auxiliar especie
    CREATE TABLE especie (
        nombre VARCHAR(20)
    );
    INSERT INTO especie VALUES('Perro');
    INSERT INTO especie VALUES('Gato');
    INSERT INTO especie VALUES('Conejo');
    INSERT INTO especie VALUES('Pajaro');
    INSERT INTO especie VALUES('Tortuga');
    INSERT INTO especie VALUES('Lagartos');
    SET letras = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';
    SET contador = 0;
    WHILE (contador <= cantidad) DO
        SET _id = CONCAT((SELECT FLOOR(RAND()*(10000000))),(SELECT SUBSTR(letras,(SELECT FLOOR(RAND() * (10) + 1)),1)));
        SET _id_cliente = (SELECT dni FROM cliente ORDER BY RAND() LIMIT 1);
        SET _edad = (SELECT FLOOR(RAND() * (20) + 1));
        SET _especie = (SELECT nombre FROM especie ORDER BY RAND() LIMIT 1);
        IF (SELECT FLOOR(RAND() * 10)) > 5 THEN
            SET _sexo = 'M';
        ELSE
            SET _sexo = 'H';
        END IF;
        INSERT INTO mascota VALUES(_id,_id_cliente,_especie,_edad,_sexo);
        SET contador = contador + 1;
    END WHILE ;
    DROP TABLE especie;
END 
$$

-- Cita

DELIMITER $$
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

DELIMITER $$
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
    SET aux_registrados = (SELECT count(*) auxiliar);
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

DELIMITER $$
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

DELIMITER ;
