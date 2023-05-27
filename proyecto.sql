-- Creación de la BD
DROP DATABASE clinica_veterinaria;

CREATE DATABASE clinica_veterinaria;
USE clinica_veterinaria;

-- Creación de tablas

CREATE TABLE municipio (
    codigo_postal VARCHAR(5) PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE direccion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    calle VARCHAR(50),
    numero INT,
    otro VARCHAR(200) DEFAULT NULL,
    codigo_postal_municipio VARCHAR(5),
    FOREIGN KEY (codigo_postal_municipio) REFERENCES municipio(codigo_postal)
);

 -- Hacer trigger para calcular letra del DNI

CREATE TABLE usuario (
    dni VARCHAR(9) PRIMARY KEY,
    nombre VARCHAR(20),
    apellido1 VARCHAR(20),
    apellido2 VARCHAR(20),
    telefono VARCHAR(20),
    id_direccion INT,
    FOREIGN KEY (id_direccion) REFERENCES direccion(id)
);

CREATE TABLE administrador (
    dni VARCHAR(9) PRIMARY KEY,
    permiso VARCHAR(20),
    FOREIGN KEY (dni) REFERENCES usuario(dni)
);

CREATE TABLE cliente (
    dni VARCHAR(9) PRIMARY KEY,
    categoria VARCHAR(20),
    residente BOOLEAN,
    FOREIGN KEY (dni) REFERENCES usuario(dni)
);

CREATE TABLE personal (
    dni VARCHAR(9) PRIMARY KEY,
    nuss VARCHAR(12),
    tipo_contrato ENUM('indefinido','practica','temporal'),
    salario FLOAT(8,2),
    FOREIGN KEY (dni) REFERENCES usuario(dni)
);

-- Cambiar en el ER para poner las ID como DNI de las tablas que heredan de usuario
CREATE TABLE administrativo (
    dni VARCHAR(9) PRIMARY KEY,
    seccion VARCHAR(20),
    FOREIGN KEY (dni) REFERENCES personal(dni)
);


CREATE TABLE veterinario (
    dni VARCHAR(9) PRIMARY KEY,
    licencia VARCHAR(9),
    especialidad VARCHAR(20),
    FOREIGN KEY (dni) REFERENCES personal(dni)
);

CREATE TABLE auxiliar (
    dni VARCHAR(9) PRIMARY KEY,
    especialidad VARCHAR(20),
    FOREIGN KEY (dni) REFERENCES personal(dni)
);

CREATE TABLE mascota (
    id VARCHAR(9) PRIMARY KEY,
    id_cliente VARCHAR(9),
    especie VARCHAR(20),
    edad SMALLINT,
    sexo ENUM('M','H'),
    FOREIGN KEY (id_cliente) REFERENCES cliente(dni)
);

CREATE TABLE cita (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    hora TIME,
    urgencia BOOLEAN,
    id_mascota VARCHAR(9),
    id_veterinario VARCHAR(9),
    FOREIGN KEY (id_mascota) REFERENCES mascota(id),
    FOREIGN KEY (id_veterinario) REFERENCES veterinario(dni)
);

-- Cambiar ER  1:N a 1:1-1:0. Aprovechar para hacer vistar con JOIN
-- Mirar tipo de dato de "resolución"

CREATE TABLE historial (
    id INT PRIMARY KEY,
    resolucion VARCHAR(20) DEFAULT NULL,
    anotacion VARCHAR(200) DEFAULT NULL,
    descripcion VARCHAR(500) DEFAULT NULL,
    FOREIGN KEY (id) REFERENCES cita(id)
); 

CREATE TABLE cita_auxiliar (
    id_cita INT,
    id_auxiliar VARCHAR(9),
    PRIMARY KEY (id_cita, id_auxiliar),
    FOREIGN KEY (id_cita) REFERENCES cita(id),
    FOREIGN KEY (id_auxiliar) REFERENCES auxiliar(dni)
);

SOURCE auto.sql

SOURCE call.sql