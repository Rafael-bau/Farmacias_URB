-- =========================================================================
-- FARMACIAS URB - ESQUEMA COMPLETO (MySQL 8.0.16+)  ·  un solo script
-- Incluye: base + CRUD, proveedores, entradas, salidas, rol Cliente y vistas de inventario/almacén.
-- Se puede ejecutar sobre una base nueva O sobre la base existente (no duplica ni falla).
-- Empresa: TecNova Software Solutions S.A. de C.V.
-- Los datos reales los captura el usuario desde la aplicación. Al final del archivo
-- hay una sección de DATOS DE PRUEBA que puedes omitir en producción.
-- Lectura (listados/búsquedas): la app usa SELECT directo sobre tablas/vistas.
-- Escritura (alta/cambio/baja): la app usa los procedimientos sp_*.
-- =========================================================================

CREATE DATABASE IF NOT EXISTS farmacias_urb
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE farmacias_urb;
SET NAMES utf8mb4;  -- guardar este archivo como UTF-8 para conservar acentos

-- ============================ TABLAS ====================================

CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estatus BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medicamentos (
    id_medicamento INT AUTO_INCREMENT PRIMARY KEY,
    codigo_barras VARCHAR(50) NOT NULL UNIQUE,
    nombre_comercial VARCHAR(100) NOT NULL,
    sustancia_activa VARCHAR(100) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_minimo INT NOT NULL DEFAULT 5,
    id_categoria INT NOT NULL,
    estatus BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_med_precio CHECK (precio_venta > 0),
    CONSTRAINT chk_med_stock_min CHECK (stock_minimo >= 0),
    CONSTRAINT fk_medicamento_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_med_nombre (nombre_comercial),
    INDEX idx_med_sustancia (sustancia_activa)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lotes (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    num_lote VARCHAR(50) NOT NULL,
    fecha_caducidad DATE NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    id_medicamento INT NOT NULL,
    CONSTRAINT chk_lote_stock CHECK (stock_actual >= 0),
    CONSTRAINT uq_lote_medicamento UNIQUE (id_medicamento, num_lote),
    CONSTRAINT fk_lote_medicamento FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_lote_caducidad (fecha_caducidad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL UNIQUE,
    correo VARCHAR(100) NOT NULL UNIQUE,
    puntos_acumulados INT NOT NULL DEFAULT 0,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cliente_puntos CHECK (puntos_acumulados >= 0)
) ENGINE=InnoDB;

-- estatus_venta: las ventas NO se borran, se cancelan (conserva auditoría)
CREATE TABLE IF NOT EXISTS ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    folio_ticket VARCHAR(20) NOT NULL UNIQUE,
    fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL,
    iva DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('EFECTIVO','TARJETA','TRANSFERENCIA') NOT NULL,
    puntos_generados INT NOT NULL DEFAULT 0,
    estatus_venta ENUM('COMPLETADA','CANCELADA') NOT NULL DEFAULT 'COMPLETADA',
    id_usuario INT NOT NULL,
    id_cliente INT NULL,
    CONSTRAINT chk_venta_montos CHECK (subtotal >= 0 AND iva >= 0 AND total = subtotal + iva),
    CONSTRAINT chk_venta_puntos CHECK (puntos_generados >= 0),
    CONSTRAINT fk_venta_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_venta_fecha (fecha_venta)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS detalle_ventas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_lote INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal_linea DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_det_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_det_subtotal CHECK (subtotal_linea = cantidad * precio_unitario),
    CONSTRAINT uq_det_venta_lote UNIQUE (id_venta, id_lote),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_lote FOREIGN KEY (id_lote) REFERENCES lotes(id_lote)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ===== NUEVAS TABLAS (v3): proveedores, entradas y salidas de inventario =====

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(15) NULL,
    correo VARCHAR(100) NULL,
    direccion VARCHAR(200) NULL,
    estatus BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- Entradas: cada recepción de mercancía de un proveedor (genera o aumenta un lote)
CREATE TABLE IF NOT EXISTS entradas (
    id_entrada INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    id_proveedor INT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    CONSTRAINT chk_entrada_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_entrada_costo CHECK (costo_unitario >= 0),
    CONSTRAINT fk_entrada_lote FOREIGN KEY (id_lote) REFERENCES lotes(id_lote)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_entrada_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_entrada_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_entrada_fecha (fecha)
) ENGINE=InnoDB;

-- Salidas que NO son ventas: merma, caducidad, ajustes de inventario
CREATE TABLE IF NOT EXISTS salidas (
    id_salida INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT NOT NULL,
    cantidad INT NOT NULL,
    motivo ENUM('MERMA','CADUCIDAD','AJUSTE','OTRO') NOT NULL,
    observaciones VARCHAR(200) NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL,
    CONSTRAINT chk_salida_cantidad CHECK (cantidad > 0),
    CONSTRAINT fk_salida_lote FOREIGN KEY (id_lote) REFERENCES lotes(id_lote)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_salida_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_salida_fecha (fecha)
) ENGINE=InnoDB;

-- Cuenta de acceso del cliente (portal Cliente): se agrega SOLO si la columna no existe.
-- Así funciona tanto en una base nueva como en una que ya tenía la tabla clientes.
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_ext_agregar_columna$$
CREATE PROCEDURE sp_ext_agregar_columna()
BEGIN
    IF (SELECT COUNT(*) FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'clientes' AND COLUMN_NAME = 'id_usuario') = 0 THEN
        ALTER TABLE clientes ADD COLUMN id_usuario INT NULL UNIQUE;
        ALTER TABLE clientes ADD CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario)
            REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE;
    END IF;
END$$
DELIMITER ;
CALL sp_ext_agregar_columna();
DROP PROCEDURE IF EXISTS sp_ext_agregar_columna;

-- ============================ TRIGGERS ==================================
DELIMITER $$

DROP TRIGGER IF EXISTS trg_detalle_before_insert$$
CREATE TRIGGER trg_detalle_before_insert
BEFORE INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    DECLARE v_cad DATE;
    SELECT stock_actual, fecha_caducidad INTO v_stock, v_cad
      FROM lotes WHERE id_lote = NEW.id_lote FOR UPDATE;
    IF v_cad < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lote caducado: no se puede vender';
    END IF;
    IF v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en el lote';
    END IF;
END$$

DROP TRIGGER IF EXISTS trg_detalle_after_insert$$
CREATE TRIGGER trg_detalle_after_insert
AFTER INSERT ON detalle_ventas
FOR EACH ROW
BEGIN
    UPDATE lotes SET stock_actual = stock_actual - NEW.cantidad
     WHERE id_lote = NEW.id_lote;
END$$

DROP TRIGGER IF EXISTS trg_venta_after_insert$$
CREATE TRIGGER trg_venta_after_insert
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    IF NEW.id_cliente IS NOT NULL AND NEW.puntos_generados > 0 THEN
        UPDATE clientes SET puntos_acumulados = puntos_acumulados + NEW.puntos_generados
         WHERE id_cliente = NEW.id_cliente;
    END IF;
END$$

-- ====================== CRUD: ROLES =====================================
DROP PROCEDURE IF EXISTS sp_rol_crear$$
CREATE PROCEDURE sp_rol_crear(IN p_nombre VARCHAR(30))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un rol con ese nombre';
    INSERT INTO roles(nombre_rol) VALUES (TRIM(p_nombre));
    SELECT LAST_INSERT_ID() AS id_rol;
END$$

DROP PROCEDURE IF EXISTS sp_rol_actualizar$$
CREATE PROCEDURE sp_rol_actualizar(IN p_id INT, IN p_nombre VARCHAR(30))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un rol con ese nombre';
    UPDATE roles SET nombre_rol = TRIM(p_nombre) WHERE id_rol = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_rol_eliminar$$
CREATE PROCEDURE sp_rol_eliminar(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1451 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: hay usuarios con este rol';
    DELETE FROM roles WHERE id_rol = p_id;
END$$

-- ====================== CRUD: USUARIOS ==================================
-- p_hash: la app debe enviar el hash (bcrypt/argon2), NUNCA la contraseña en texto plano.
DROP PROCEDURE IF EXISTS sp_usuario_crear$$
CREATE PROCEDURE sp_usuario_crear(IN p_nombre VARCHAR(100), IN p_correo VARCHAR(100),
                                  IN p_hash VARCHAR(255), IN p_id_rol INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese correo';
    DECLARE EXIT HANDLER FOR 1452 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe';
    INSERT INTO usuarios(nombre, correo, password_hash, id_rol)
    VALUES (TRIM(p_nombre), LOWER(TRIM(p_correo)), p_hash, p_id_rol);
    SELECT LAST_INSERT_ID() AS id_usuario;
END$$

DROP PROCEDURE IF EXISTS sp_usuario_actualizar$$
CREATE PROCEDURE sp_usuario_actualizar(IN p_id INT, IN p_nombre VARCHAR(100),
                                       IN p_correo VARCHAR(100), IN p_id_rol INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con ese correo';
    DECLARE EXIT HANDLER FOR 1452 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe';
    UPDATE usuarios SET nombre = TRIM(p_nombre), correo = LOWER(TRIM(p_correo)), id_rol = p_id_rol
     WHERE id_usuario = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_usuario_cambiar_password$$
CREATE PROCEDURE sp_usuario_cambiar_password(IN p_id INT, IN p_hash VARCHAR(255))
BEGIN
    UPDATE usuarios SET password_hash = p_hash WHERE id_usuario = p_id;
END$$

-- "Eliminar" = baja lógica (el usuario tiene ventas históricas)
DROP PROCEDURE IF EXISTS sp_usuario_estatus$$
CREATE PROCEDURE sp_usuario_estatus(IN p_id INT, IN p_estatus BOOLEAN)
BEGIN
    UPDATE usuarios SET estatus = p_estatus WHERE id_usuario = p_id;
END$$

-- ====================== CRUD: CATEGORÍAS ================================
DROP PROCEDURE IF EXISTS sp_categoria_crear$$
CREATE PROCEDURE sp_categoria_crear(IN p_nombre VARCHAR(50))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una categoría con ese nombre';
    INSERT INTO categorias(nombre_categoria) VALUES (TRIM(p_nombre));
    SELECT LAST_INSERT_ID() AS id_categoria;
END$$

DROP PROCEDURE IF EXISTS sp_categoria_actualizar$$
CREATE PROCEDURE sp_categoria_actualizar(IN p_id INT, IN p_nombre VARCHAR(50))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una categoría con ese nombre';
    UPDATE categorias SET nombre_categoria = TRIM(p_nombre) WHERE id_categoria = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_categoria_eliminar$$
CREATE PROCEDURE sp_categoria_eliminar(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1451 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar: hay medicamentos en esta categoría';
    DELETE FROM categorias WHERE id_categoria = p_id;
END$$

-- ====================== CRUD: MEDICAMENTOS ==============================
DROP PROCEDURE IF EXISTS sp_medicamento_crear$$
CREATE PROCEDURE sp_medicamento_crear(IN p_codigo VARCHAR(50), IN p_nombre VARCHAR(100),
        IN p_sustancia VARCHAR(100), IN p_precio DECIMAL(10,2), IN p_stock_min INT, IN p_id_categoria INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un medicamento con ese código de barras';
    DECLARE EXIT HANDLER FOR 1452 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría indicada no existe';
    DECLARE EXIT HANDLER FOR 3819 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio o stock mínimo inválido';
    INSERT INTO medicamentos(codigo_barras, nombre_comercial, sustancia_activa, precio_venta, stock_minimo, id_categoria)
    VALUES (TRIM(p_codigo), TRIM(p_nombre), TRIM(p_sustancia), p_precio, IFNULL(p_stock_min,5), p_id_categoria);
    SELECT LAST_INSERT_ID() AS id_medicamento;
END$$

DROP PROCEDURE IF EXISTS sp_medicamento_actualizar$$
CREATE PROCEDURE sp_medicamento_actualizar(IN p_id INT, IN p_codigo VARCHAR(50), IN p_nombre VARCHAR(100),
        IN p_sustancia VARCHAR(100), IN p_precio DECIMAL(10,2), IN p_stock_min INT, IN p_id_categoria INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un medicamento con ese código de barras';
    DECLARE EXIT HANDLER FOR 1452 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La categoría indicada no existe';
    DECLARE EXIT HANDLER FOR 3819 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precio o stock mínimo inválido';
    UPDATE medicamentos
       SET codigo_barras = TRIM(p_codigo), nombre_comercial = TRIM(p_nombre),
           sustancia_activa = TRIM(p_sustancia), precio_venta = p_precio,
           stock_minimo = p_stock_min, id_categoria = p_id_categoria
     WHERE id_medicamento = p_id;
END$$

-- Baja lógica: el medicamento ya pudo venderse
DROP PROCEDURE IF EXISTS sp_medicamento_estatus$$
CREATE PROCEDURE sp_medicamento_estatus(IN p_id INT, IN p_estatus BOOLEAN)
BEGIN
    UPDATE medicamentos SET estatus = p_estatus WHERE id_medicamento = p_id;
END$$

-- ====================== CRUD: LOTES =====================================
DROP PROCEDURE IF EXISTS sp_lote_crear$$
CREATE PROCEDURE sp_lote_crear(IN p_id_medicamento INT, IN p_num_lote VARCHAR(50),
                               IN p_caducidad DATE, IN p_stock INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese número de lote ya existe para el medicamento';
    DECLARE EXIT HANDLER FOR 1452 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El medicamento indicado no existe';
    DECLARE EXIT HANDLER FOR 3819 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    INSERT INTO lotes(id_medicamento, num_lote, fecha_caducidad, stock_actual)
    VALUES (p_id_medicamento, TRIM(p_num_lote), p_caducidad, p_stock);
    SELECT LAST_INSERT_ID() AS id_lote;
END$$

-- Permite corregir datos o ajustar stock por conteo físico
DROP PROCEDURE IF EXISTS sp_lote_actualizar$$
CREATE PROCEDURE sp_lote_actualizar(IN p_id INT, IN p_num_lote VARCHAR(50),
                                    IN p_caducidad DATE, IN p_stock INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese número de lote ya existe para el medicamento';
    DECLARE EXIT HANDLER FOR 3819 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    UPDATE lotes SET num_lote = TRIM(p_num_lote), fecha_caducidad = p_caducidad, stock_actual = p_stock
     WHERE id_lote = p_id;
END$$

-- Solo se elimina si nunca se vendió; si ya tiene ventas, ajustar stock a 0
DROP PROCEDURE IF EXISTS sp_lote_eliminar$$
CREATE PROCEDURE sp_lote_eliminar(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR 1451 SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar: el lote tiene ventas. Ajuste su stock a 0';
    DELETE FROM lotes WHERE id_lote = p_id;
END$$

-- ====================== CRUD: CLIENTES ==================================
DROP PROCEDURE IF EXISTS sp_cliente_crear$$
CREATE PROCEDURE sp_cliente_crear(IN p_nombre VARCHAR(100), IN p_telefono VARCHAR(15), IN p_correo VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un cliente con ese teléfono o correo';
    INSERT INTO clientes(nombre, telefono, correo)
    VALUES (TRIM(p_nombre), TRIM(p_telefono), LOWER(TRIM(p_correo)));
    SELECT LAST_INSERT_ID() AS id_cliente;
END$$

DROP PROCEDURE IF EXISTS sp_cliente_actualizar$$
CREATE PROCEDURE sp_cliente_actualizar(IN p_id INT, IN p_nombre VARCHAR(100),
                                       IN p_telefono VARCHAR(15), IN p_correo VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un cliente con ese teléfono o correo';
    UPDATE clientes SET nombre = TRIM(p_nombre), telefono = TRIM(p_telefono), correo = LOWER(TRIM(p_correo))
     WHERE id_cliente = p_id;
END$$

-- Las ventas del cliente se conservan (id_cliente pasa a NULL)
DROP PROCEDURE IF EXISTS sp_cliente_eliminar$$
CREATE PROCEDURE sp_cliente_eliminar(IN p_id INT)
BEGIN
    DELETE FROM clientes WHERE id_cliente = p_id;
END$$

-- ====================== VENTAS (transaccional) ==========================
-- p_items ejemplo: '[{"id_lote":3,"cantidad":2},{"id_lote":8,"cantidad":1}]'
-- p_tasa_iva: 0.00 para medicamentos con tasa 0%, 0.16 si aplica IVA
-- Regla de puntos: 1 punto por cada $10 del total (ajustable aquí)
DROP PROCEDURE IF EXISTS sp_registrar_venta$$
CREATE PROCEDURE sp_registrar_venta(IN p_id_usuario INT, IN p_id_cliente INT,
        IN p_metodo_pago VARCHAR(20), IN p_tasa_iva DECIMAL(4,2), IN p_items JSON)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_iva DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_puntos INT DEFAULT 0;
    DECLARE v_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        DROP TEMPORARY TABLE IF EXISTS tmp_items;
        RESIGNAL;
    END;

    IF p_items IS NULL OR JSON_LENGTH(p_items) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no tiene productos';
    END IF;

    START TRANSACTION;

    -- Tabla temporal: evita leer de `lotes` en el mismo INSERT cuyo trigger la modifica (error 1442)
    DROP TEMPORARY TABLE IF EXISTS tmp_items;
    CREATE TEMPORARY TABLE tmp_items (
        id_lote INT PRIMARY KEY,
        cantidad INT NOT NULL,
        precio DECIMAL(10,2) NOT NULL
    );

    INSERT INTO tmp_items(id_lote, cantidad, precio)
    SELECT j.id_lote, j.cantidad, m.precio_venta
      FROM JSON_TABLE(p_items, '$[*]' COLUMNS (
               id_lote INT PATH '$.id_lote', cantidad INT PATH '$.cantidad')) j
      JOIN lotes l ON l.id_lote = j.id_lote
      JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
     WHERE m.estatus = TRUE;

    IF (SELECT COUNT(*) FROM tmp_items) <> JSON_LENGTH(p_items) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Productos inválidos, inactivos o repetidos en la venta';
    END IF;

    SELECT IFNULL(SUM(cantidad * precio), 0) INTO v_subtotal FROM tmp_items;

    IF v_subtotal <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Productos inválidos o inactivos';
    END IF;

    SET v_iva    = ROUND(v_subtotal * IFNULL(p_tasa_iva, 0), 2);
    SET v_total  = v_subtotal + v_iva;
    IF p_id_cliente IS NOT NULL THEN SET v_puntos = FLOOR(v_total / 10); END IF;

    -- Folio temporal único; se reemplaza por el definitivo con el id generado
    INSERT INTO ventas(folio_ticket, subtotal, iva, total, metodo_pago, puntos_generados, id_usuario, id_cliente)
    VALUES (LEFT(UUID(), 20), v_subtotal, v_iva, v_total, p_metodo_pago, v_puntos, p_id_usuario, p_id_cliente);
    SET v_id = LAST_INSERT_ID();

    UPDATE ventas
       SET folio_ticket = CONCAT('V', DATE_FORMAT(NOW(), '%y%m%d'), LPAD(v_id, 6, '0'))
     WHERE id_venta = v_id;

    -- Los triggers validan stock/caducidad y descuentan inventario
    INSERT INTO detalle_ventas(id_venta, id_lote, cantidad, precio_unitario, subtotal_linea)
    SELECT v_id, id_lote, cantidad, precio, cantidad * precio
      FROM tmp_items;

    DROP TEMPORARY TABLE IF EXISTS tmp_items;
    COMMIT;
    SELECT v_id AS id_venta,
           (SELECT folio_ticket FROM ventas WHERE id_venta = v_id) AS folio_ticket,
           v_total AS total, v_puntos AS puntos_generados;
END$$

-- Cancelación: devuelve stock y revierte puntos; conserva el historial
DROP PROCEDURE IF EXISTS sp_cancelar_venta$$
CREATE PROCEDURE sp_cancelar_venta(IN p_id_venta INT)
BEGIN
    DECLARE v_estatus VARCHAR(20);
    DECLARE v_cliente INT;
    DECLARE v_puntos INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estatus_venta, id_cliente, puntos_generados
      INTO v_estatus, v_cliente, v_puntos
      FROM ventas WHERE id_venta = p_id_venta FOR UPDATE;

    IF v_estatus IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
    ELSEIF v_estatus = 'CANCELADA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta ya estaba cancelada';
    END IF;

    UPDATE lotes l
      JOIN detalle_ventas d ON d.id_lote = l.id_lote
       SET l.stock_actual = l.stock_actual + d.cantidad
     WHERE d.id_venta = p_id_venta;

    IF v_cliente IS NOT NULL THEN
        UPDATE clientes SET puntos_acumulados = GREATEST(0, puntos_acumulados - v_puntos)
         WHERE id_cliente = v_cliente;
    END IF;

    UPDATE ventas SET estatus_venta = 'CANCELADA' WHERE id_venta = p_id_venta;
    COMMIT;
END$$

-- ====================== PROVEEDORES (v3) ================================
DROP PROCEDURE IF EXISTS sp_proveedor_crear$$
CREATE PROCEDURE sp_proveedor_crear(IN p_nombre VARCHAR(100), IN p_telefono VARCHAR(15),
                                    IN p_correo VARCHAR(100), IN p_direccion VARCHAR(200))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un proveedor con ese nombre';
    INSERT INTO proveedores(nombre, telefono, correo, direccion)
    VALUES (TRIM(p_nombre), p_telefono, LOWER(p_correo), p_direccion);
    SELECT LAST_INSERT_ID() AS id_proveedor;
END$$

DROP PROCEDURE IF EXISTS sp_proveedor_actualizar$$
CREATE PROCEDURE sp_proveedor_actualizar(IN p_id INT, IN p_nombre VARCHAR(100), IN p_telefono VARCHAR(15),
                                         IN p_correo VARCHAR(100), IN p_direccion VARCHAR(200))
BEGIN
    DECLARE EXIT HANDLER FOR 1062 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un proveedor con ese nombre';
    UPDATE proveedores
       SET nombre = TRIM(p_nombre), telefono = p_telefono, correo = LOWER(p_correo), direccion = p_direccion
     WHERE id_proveedor = p_id;
END$$

DROP PROCEDURE IF EXISTS sp_proveedor_estatus$$
CREATE PROCEDURE sp_proveedor_estatus(IN p_id INT, IN p_estatus BOOLEAN)
BEGIN
    UPDATE proveedores SET estatus = p_estatus WHERE id_proveedor = p_id;
END$$

-- ====================== ENTRADAS Y SALIDAS (v3) =========================
-- Registra la recepción de mercancía: crea el lote si no existe (o suma stock si ya existe)
DROP PROCEDURE IF EXISTS sp_registrar_entrada$$
CREATE PROCEDURE sp_registrar_entrada(IN p_id_proveedor INT, IN p_id_medicamento INT, IN p_num_lote VARCHAR(50),
        IN p_caducidad DATE, IN p_cantidad INT, IN p_costo DECIMAL(10,2), IN p_id_usuario INT)
BEGIN
    DECLARE v_id_lote INT DEFAULT NULL;
    DECLARE v_cad DATE DEFAULT NULL;

    DECLARE EXIT HANDLER FOR 1452
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor, medicamento o usuario inexistente';
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0';
    END IF;
    IF p_caducidad IS NULL OR p_caducidad <= CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de caducidad debe ser futura';
    END IF;
    IF (SELECT COUNT(*) FROM medicamentos WHERE id_medicamento = p_id_medicamento AND estatus = TRUE) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El medicamento no existe o está dado de baja';
    END IF;
    IF (SELECT COUNT(*) FROM proveedores WHERE id_proveedor = p_id_proveedor AND estatus = TRUE) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor no existe o está dado de baja';
    END IF;

    START TRANSACTION;

    SELECT id_lote, fecha_caducidad INTO v_id_lote, v_cad
      FROM lotes
     WHERE id_medicamento = p_id_medicamento AND num_lote = TRIM(p_num_lote)
       FOR UPDATE;

    IF v_id_lote IS NULL THEN
        INSERT INTO lotes(id_medicamento, num_lote, fecha_caducidad, stock_actual)
        VALUES (p_id_medicamento, TRIM(p_num_lote), p_caducidad, p_cantidad);
        SET v_id_lote = LAST_INSERT_ID();
    ELSE
        IF v_cad <> p_caducidad THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese lote ya existe con otra fecha de caducidad';
        END IF;
        UPDATE lotes SET stock_actual = stock_actual + p_cantidad WHERE id_lote = v_id_lote;
    END IF;

    INSERT INTO entradas(id_lote, id_proveedor, cantidad, costo_unitario, id_usuario)
    VALUES (v_id_lote, p_id_proveedor, p_cantidad, IFNULL(p_costo, 0), p_id_usuario);

    COMMIT;
    SELECT v_id_lote AS id_lote;
END$$

-- Descuenta stock por merma, caducidad o ajuste
DROP PROCEDURE IF EXISTS sp_registrar_salida$$
CREATE PROCEDURE sp_registrar_salida(IN p_id_lote INT, IN p_cantidad INT, IN p_motivo VARCHAR(20),
                                     IN p_observaciones VARCHAR(200), IN p_id_usuario INT)
BEGIN
    DECLARE v_stock INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad debe ser mayor a 0';
    END IF;

    START TRANSACTION;

    SELECT stock_actual INTO v_stock FROM lotes WHERE id_lote = p_id_lote FOR UPDATE;

    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El lote no existe';
    END IF;
    IF v_stock < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en el lote';
    END IF;

    UPDATE lotes SET stock_actual = stock_actual - p_cantidad WHERE id_lote = p_id_lote;
    INSERT INTO salidas(id_lote, cantidad, motivo, observaciones, id_usuario)
    VALUES (p_id_lote, p_cantidad, p_motivo, p_observaciones, p_id_usuario);

    COMMIT;
END$$

-- ====================== CUENTAS DE CLIENTE (v3) =========================
-- Vincula una cuenta de usuario (rol Cliente) con un cliente; p_id_cliente NULL = desvincular
DROP PROCEDURE IF EXISTS sp_cliente_vincular_usuario$$
CREATE PROCEDURE sp_cliente_vincular_usuario(IN p_id_cliente INT, IN p_id_usuario INT)
BEGIN
    IF p_id_cliente IS NOT NULL THEN
        IF (SELECT COUNT(*) FROM clientes
             WHERE id_cliente = p_id_cliente AND id_usuario IS NOT NULL AND id_usuario <> p_id_usuario) > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese cliente ya tiene una cuenta de acceso asignada';
        END IF;
    END IF;
    UPDATE clientes SET id_usuario = NULL WHERE id_usuario = p_id_usuario;
    IF p_id_cliente IS NOT NULL THEN
        UPDATE clientes SET id_usuario = p_id_usuario WHERE id_cliente = p_id_cliente;
    END IF;
END$$

DELIMITER ;

-- ============================ VISTAS ====================================
CREATE OR REPLACE VIEW v_alerta_caducidad AS
SELECT
    m.id_medicamento, m.nombre_comercial, l.id_lote, l.num_lote,
    l.fecha_caducidad, l.stock_actual,
    DATEDIFF(l.fecha_caducidad, CURDATE()) AS dias_restantes,
    CASE WHEN l.fecha_caducidad < CURDATE() THEN 'CADUCADO' ELSE 'POR CADUCAR' END AS estado
FROM lotes l
JOIN medicamentos m ON l.id_medicamento = m.id_medicamento
WHERE l.fecha_caducidad <= DATE_ADD(CURDATE(), INTERVAL 3 MONTH)
  AND l.stock_actual > 0
  AND m.estatus = TRUE;

CREATE OR REPLACE VIEW v_alerta_stock_critico AS
SELECT
    m.id_medicamento, m.nombre_comercial, m.stock_minimo,
    COALESCE(SUM(l.stock_actual), 0) AS stock_total
FROM medicamentos m
LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento AND l.fecha_caducidad >= CURDATE()
WHERE m.estatus = TRUE
GROUP BY m.id_medicamento, m.nombre_comercial, m.stock_minimo
HAVING COALESCE(SUM(l.stock_actual), 0) <= m.stock_minimo;

-- Catálogo para el punto de venta: lotes vendibles ordenados por caducidad (FEFO)
CREATE OR REPLACE VIEW v_lotes_disponibles AS
SELECT l.id_lote, m.id_medicamento, m.codigo_barras, m.nombre_comercial,
       m.precio_venta, l.num_lote, l.fecha_caducidad, l.stock_actual
FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
WHERE m.estatus = TRUE AND l.stock_actual > 0 AND l.fecha_caducidad >= CURDATE()
ORDER BY l.fecha_caducidad ASC;

-- ===== VISTAS NUEVAS (v3) =====

-- Inventario por lote, con estado y color de alerta (pantalla Inventario)
CREATE OR REPLACE VIEW v_inventario_lotes AS
SELECT
    l.id_lote, m.id_medicamento, m.codigo_barras, m.nombre_comercial, l.num_lote,
    l.stock_actual, l.fecha_caducidad,
    DATEDIFF(l.fecha_caducidad, CURDATE()) AS dias_restantes,
    m.stock_minimo,
    COALESCE(t.stock_total, 0) AS stock_total,
    CASE
        WHEN l.fecha_caducidad < CURDATE() THEN 'CADUCADO'
        WHEN l.fecha_caducidad <= DATE_ADD(CURDATE(), INTERVAL 3 MONTH) THEN 'POR CADUCAR'
        WHEN COALESCE(t.stock_total, 0) <= m.stock_minimo THEN 'STOCK BAJO'
        ELSE 'VIGENTE'
    END AS estado
FROM lotes l
JOIN medicamentos m ON m.id_medicamento = l.id_medicamento
LEFT JOIN (SELECT id_medicamento, SUM(stock_actual) AS stock_total
             FROM lotes WHERE fecha_caducidad >= CURDATE()
            GROUP BY id_medicamento) t ON t.id_medicamento = m.id_medicamento
WHERE m.estatus = TRUE AND l.stock_actual > 0;

-- Existencias consolidadas por medicamento (pantallas Almacén e Inicio)
CREATE OR REPLACE VIEW v_almacen AS
SELECT
    m.id_medicamento, m.codigo_barras, m.nombre_comercial, m.sustancia_activa,
    c.nombre_categoria, m.stock_minimo,
    COALESCE(SUM(CASE WHEN l.fecha_caducidad >= CURDATE() THEN l.stock_actual END), 0) AS stock_vigente,
    COALESCE(SUM(CASE WHEN l.fecha_caducidad <  CURDATE() THEN l.stock_actual END), 0) AS stock_caducado,
    COUNT(CASE WHEN l.stock_actual > 0 THEN l.id_lote END) AS lotes_con_stock,
    MIN(CASE WHEN l.stock_actual > 0 AND l.fecha_caducidad >= CURDATE() THEN l.fecha_caducidad END) AS proxima_caducidad,
    CASE
        WHEN COALESCE(SUM(CASE WHEN l.fecha_caducidad >= CURDATE() THEN l.stock_actual END), 0) = 0 THEN 'AGOTADO'
        WHEN COALESCE(SUM(CASE WHEN l.fecha_caducidad >= CURDATE() THEN l.stock_actual END), 0) <= m.stock_minimo THEN 'STOCK BAJO'
        ELSE 'OK'
    END AS estado
FROM medicamentos m
JOIN categorias c ON c.id_categoria = m.id_categoria
LEFT JOIN lotes l ON l.id_medicamento = m.id_medicamento
WHERE m.estatus = TRUE
GROUP BY m.id_medicamento, m.codigo_barras, m.nombre_comercial, m.sustancia_activa, c.nombre_categoria, m.stock_minimo;

-- ============================ DATOS MÍNIMOS =============================
-- Roles necesarios para el sistema.
INSERT IGNORE INTO roles (nombre_rol) VALUES ('Administrador'), ('Cajero'), ('Cliente');

-- ============================ PERMISOS (recomendado) ====================
-- La app no debería tener DELETE/UPDATE directo, solo lectura y ejecución:
-- CREATE USER 'urb_app'@'%' IDENTIFIED BY 'CAMBIAR_CONTRASEÑA';
-- GRANT SELECT, EXECUTE ON farmacias_urb.* TO 'urb_app'@'%';

-- =========================================================================
-- DATOS INICIALES (necesarios): los roles ya se insertaron arriba; aquí va el primer administrador.
-- Con él entras a la aplicación y desde ahí das de alta categorías, medicamentos, proveedores,
-- usuarios y clientes. El inventario empieza VACÍO: lo captura la dueña de la farmacia.
-- El password_hash es un marcador: al arrancar la aplicación Java con
-- app.inicializar.passwords=true se asigna la contraseña Admin123 (cámbiala en Configuración).
-- =========================================================================
INSERT IGNORE INTO usuarios (nombre, correo, password_hash, id_rol)
SELECT 'Administrador', 'admin@farmaciasurb.com', '$2b$12$HASH_DE_PRUEBA_REEMPLAZAR_ADMIN', id_rol
  FROM roles WHERE nombre_rol = 'Administrador';

-- =========================================================================
-- DATOS DE EJEMPLO (OPCIONAL): muy pocos, solo para ver las pantallas y las alertas funcionando.
-- Para empezar con la base limpia, borra desde esta línea hasta el final del archivo.
-- Re-ejecutable: no duplica datos. Fechas relativas a CURDATE(), así las alertas siempre se ven.
-- Contraseñas de ejemplo (las asigna la app al arrancar): cajero1 = Cajero123, cliente1 = Cliente123
-- =========================================================================
INSERT IGNORE INTO usuarios (nombre, correo, password_hash, id_rol)
SELECT 'Pedro Sánchez Cruz', 'cajero1@farmaciasurb.com', '$2b$12$HASH_DE_PRUEBA_REEMPLAZAR_CAJ1', id_rol
  FROM roles WHERE nombre_rol = 'Cajero';
INSERT IGNORE INTO usuarios (nombre, correo, password_hash, id_rol)
SELECT 'Ana Sofía Ramírez', 'cliente1@farmaciasurb.com', '$2b$12$HASH_DE_PRUEBA_REEMPLAZAR_CLI1', id_rol
  FROM roles WHERE nombre_rol = 'Cliente';

INSERT IGNORE INTO categorias (nombre_categoria) VALUES
    ('Analgésicos'), ('Antibióticos'), ('Vitaminas y suplementos');

INSERT IGNORE INTO medicamentos
    (codigo_barras, nombre_comercial, sustancia_activa, precio_venta, stock_minimo, id_categoria) VALUES
('7501000100001', 'Paracetamol 500 mg c/20 tabletas',  'Paracetamol',    62.00, 10, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Analgésicos')),
('7501000100004', 'Amoxicilina 500 mg c/12 cápsulas',  'Amoxicilina',   145.00,  8, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Antibióticos')),
('7501000100010', 'Vitamina C 1 g c/10 efervescentes', 'Ácido ascórbico',135.00, 6, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Vitaminas y suplementos')),
('7501000100015', 'Diclofenaco 100 mg c/10 tabletas',  'Diclofenaco',   118.00,  5, (SELECT id_categoria FROM categorias WHERE nombre_categoria = 'Analgésicos'));
-- Diclofenaco queda SIN lotes a propósito: aparece en la alerta de stock bajo.

INSERT IGNORE INTO lotes (id_medicamento, num_lote, fecha_caducidad, stock_actual) VALUES
((SELECT id_medicamento FROM medicamentos WHERE codigo_barras = '7501000100004'), 'L-AMX-2501', DATE_ADD(CURDATE(), INTERVAL 45 DAY),   12),  -- por caducar
((SELECT id_medicamento FROM medicamentos WHERE codigo_barras = '7501000100010'), 'L-VTC-2501', DATE_ADD(CURDATE(), INTERVAL 13 MONTH),  4);  -- stock bajo

INSERT IGNORE INTO proveedores (nombre, telefono, correo, direccion) VALUES
('Distribuidora Farmacéutica del Centro', '5555100001', 'ventas@difarcentro.com.mx', 'Calzada de Tlalpan 1250, CDMX');

INSERT IGNORE INTO clientes (nombre, telefono, correo) VALUES
('Ana Sofía Ramírez', '5512345603', 'ana.ramirez@ejemplo.com');

-- Cuenta de cliente vinculada, una entrada de mercancía y una venta, usando los procedimientos reales
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_seed_ejemplo$$
CREATE PROCEDURE sp_seed_ejemplo()
BEGIN
    DECLARE v_cli, v_user, v_prov, v_med, v_admin, v_caj, v_lote INT DEFAULT NULL;

    SELECT id_cliente INTO v_cli FROM clientes WHERE telefono = '5512345603';
    SELECT id_usuario INTO v_user FROM usuarios WHERE correo = 'cliente1@farmaciasurb.com';
    IF v_cli IS NOT NULL AND v_user IS NOT NULL THEN
        CALL sp_cliente_vincular_usuario(v_cli, v_user);
    END IF;

    -- Entrada: el lote de Paracetamol llega de un proveedor (queda registrada en Entradas)
    IF (SELECT COUNT(*) FROM entradas) = 0 THEN
        SELECT id_proveedor INTO v_prov FROM proveedores WHERE telefono = '5555100001';
        SELECT id_medicamento INTO v_med FROM medicamentos WHERE codigo_barras = '7501000100001';
        SELECT id_usuario INTO v_admin FROM usuarios WHERE correo = 'admin@farmaciasurb.com';
        IF v_prov IS NOT NULL AND v_med IS NOT NULL AND v_admin IS NOT NULL THEN
            CALL sp_registrar_entrada(v_prov, v_med, 'L-PAR-2501',
                                      DATE_ADD(CURDATE(), INTERVAL 14 MONTH), 60, 40.00, v_admin);
        END IF;
    END IF;

    -- Venta: 2 Paracetamol a la cliente Ana -> total 124.00, 12 puntos
    IF (SELECT COUNT(*) FROM ventas) = 0 THEN
        SELECT id_usuario INTO v_caj FROM usuarios WHERE correo = 'cajero1@farmaciasurb.com';
        SELECT id_lote INTO v_lote FROM lotes WHERE num_lote = 'L-PAR-2501';
        IF v_caj IS NOT NULL AND v_lote IS NOT NULL AND v_cli IS NOT NULL THEN
            CALL sp_registrar_venta(v_caj, v_cli, 'EFECTIVO', 0.00, JSON_ARRAY(
                JSON_OBJECT('id_lote', v_lote, 'cantidad', 2)));
        END IF;
    END IF;
END$$

DELIMITER ;

CALL sp_seed_ejemplo();
DROP PROCEDURE IF EXISTS sp_seed_ejemplo;

-- =========================================================================
-- CONSULTAS DE VERIFICACIÓN (solo si cargaste los datos de ejemplo)
-- =========================================================================
-- Esperado: Amoxicilina L-AMX-2501, por caducar (45 días)
SELECT * FROM v_alerta_caducidad;

-- Esperado: Vitamina C (stock 4) y Diclofenaco (stock 0, sin lotes)
SELECT * FROM v_alerta_stock_critico;

-- Esperado: 1 venta COMPLETADA por 124.00 con 12 puntos
SELECT id_venta, folio_ticket, total, puntos_generados, estatus_venta FROM ventas;

-- Esperado: Ana Sofía Ramírez con 12 puntos y su cuenta cliente1@farmaciasurb.com vinculada
SELECT c.nombre, c.puntos_acumulados, u.correo FROM clientes c LEFT JOIN usuarios u ON u.id_usuario = c.id_usuario;

-- Esperado: Paracetamol L-PAR-2501 con stock 58 (60 recibidas - 2 vendidas); 1 entrada registrada
SELECT m.nombre_comercial, l.num_lote, l.stock_actual FROM lotes l JOIN medicamentos m ON m.id_medicamento = l.id_medicamento;
SELECT * FROM entradas;

-- Inventario y almacén (con estado de alerta por colores en la app)
SELECT nombre_comercial, num_lote, stock_actual, estado FROM v_inventario_lotes;
SELECT nombre_comercial, stock_vigente, estado FROM v_almacen ORDER BY nombre_comercial;
