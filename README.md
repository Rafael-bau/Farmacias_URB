# Farmacias URB — Aplicación web (Maven + Servlets/JSP + MySQL)

Proyecto de **TecNova Software Solutions**. Arquitectura **MVC**:

| Capa | Paquete / carpeta | Qué contiene |
|---|---|---|
| Modelo | `model`, `dao`, `config/Db.java` | Clases de datos y acceso a MySQL (JDBC) |
| Vista | `src/main/webapp/WEB-INF/views` | Páginas JSP (Bootstrap) + `css/estilos.css` |
| Controlador | `controller`, `filter` | Servlets y filtro de seguridad |

## Requisitos
- JDK 17 · Maven 3.9+ · **Apache Tomcat 9.x** (⚠ no usar Tomcat 10/11: usan `jakarta.*` y este proyecto usa `javax.*`) · MySQL 8.0.16+

## Puesta en marcha
1. **Base de datos:** ejecuta `sql/Farmacias_BD.sql` completo en MySQL Workbench (un solo script).
   Sirve sobre una base nueva o sobre la que ya tenías: agrega solo lo que falte.
2. **Conexión:** edita `src/main/resources/db.properties` (`db.url`, `db.user`, `db.password`).
   En la nube basta cambiar el host en `db.url` (o usar las variables de entorno `DB_URL`, `DB_USER`, `DB_PASSWORD`).
3. **Compilar:** `mvn clean package` → genera `target/Farmacias_URB.war`.
4. **Desplegar:** copia el `.war` a `TOMCAT/webapps/` (o configura Tomcat 9 en IntelliJ Ultimate / NetBeans) y abre
   **http://localhost:8080/Farmacias_URB/**

## Cuentas (contraseñas asignadas al primer arranque)
El script crea el administrador y, como **datos de ejemplo opcionales**, un cajero, un cliente y muy pocos
medicamentos. Para empezar con el inventario vacío, borra en `Farmacias_BD.sql` la sección
«DATOS DE EJEMPLO» (queda solo el administrador).

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | admin@farmaciasurb.com | Admin123 |
| Cajero | cajero1@farmaciasurb.com | Cajero123 |
| Cliente | cliente1@farmaciasurb.com | Cliente123 |

> En producción pon `app.inicializar.passwords=false` en `db.properties`, usa HTTPS y credenciales por variables de entorno.

## Pantallas por rol
- **Administrador:** Inicio (alertas), Inventario, Entradas, Salidas, Almacén, Ventas, Configuración › Usuarios / Proveedores / Productos / Clientes
- **Cajero:** Inicio, Inventario, Compras (punto de venta), Catálogos (medicamentos y clientes), Almacén, Ventas, Configuración
- **Cliente:** Inicio (novedades), Compras (su historial y tickets), Catálogos, Configuración

## Estructura
```
Farmacias_URB/
├── pom.xml
├── sql/Farmacias_BD.sql
└── src/main/
    ├── java/com/farmaciasurb/
    │   ├── config/      Db.java (conexión y consultas) · InicioApp.java (arranque)
    │   ├── model/       Usuario.java · ItemCarrito.java
    │   ├── dao/         UsuarioDAO · MedicamentoDAO · ClienteDAO · ProveedorDAO · MovimientoDAO · InventarioDAO · VentaDAO
    │   ├── controller/  un Servlet por pantalla (+ BaseServlet con utilidades comunes)
    │   ├── filter/      FiltroSeguridad.java (sesión, roles, CSRF, UTF-8)
    │   └── util/        Seguridad (bcrypt) · Validador (regex) · TicketPdf (ticket PDF)
    ├── resources/db.properties
    └── webapp/
        ├── index.jsp · css/estilos.css
        └── WEB-INF/ web.xml · views/*.jsp · views/fragmentos/{cabecera,pie}.jspf
```
