# Farmacias URB — Aplicación web (Maven + Servlets/JSP + Hibernate + MySQL)

Proyecto de **TecNova Software Solutions**. Arquitectura **MVC**:

| Capa | Paquete / carpeta | Qué contiene |
|---|---|---|
| Modelo | `model`, `dao`, `service` | Entidades JPA, DAO y servicios (Hibernate + MySQL) |
| Vista | `src/webapp (*.jsp)` | Páginas JSP (Bootstrap) + `css/estilos.css` |
| Controlador | `controller`, `filter`, `listener` | Servlets, filtro de seguridad y arranque |

## Requisitos
- JDK 17 · Maven 3.9+ · **Apache Tomcat 9.x** (⚠ no usar Tomcat 10/11: usan `jakarta.*` y este proyecto usa `javax.*`) · MySQL 8.0.16+

## Conexión con el Spring Boot (`Farmacias_URB_SpringBoot`)
Son **dos proyectos separados que comparten la misma base de datos MySQL `farmacias_urb`**. Todo lo que registres, edites
o elimines desde Swagger (Spring Boot, `http://localhost:8081/swagger-ui.html`) se guarda en esa base y se ve de inmediato
en esta aplicación (`http://localhost:8080/Farmacias_URB/`), y viceversa.

| Proyecto | Puerto | Dirección |
|---|---|---|
| Farmacias_URB (Tomcat 9, JSP) | 8080 | http://localhost:8080/Farmacias_URB/ |
| Farmacias_URB_SpringBoot (API + Swagger) | **8081** | http://localhost:8081/swagger-ui.html |

Ambos usan el mismo script `sql/Farmacias_BD.sql`, las mismas entidades y las mismas contraseñas (bcrypt).

## Puesta en marcha
1. **Base de datos:** ejecuta `sql/Farmacias_BD.sql` completo en MySQL Workbench (un solo script; es el mismo del Spring Boot).
2. **Conexión:** define las variables de entorno `DB_URL`, `DB_USER` y `DB_PASSWORD` (las mismas para los dos proyectos) o edita
   `src/main/resources/hibernate.cfg.xml` (reemplaza `CAMBIAR_PASSWORD`).
3. **Compilar:** `mvn clean package` → genera `target/Farmacias_URB.war`.
4. **Desplegar:** copia el `.war` a `TOMCAT_9/webapps/` y abre **http://localhost:8080/Farmacias_URB/**.
   (En IntelliJ con Smart Tomcat: Tomcat 9, *Deployment directory* = `target/Farmacias_URB`, tras ejecutar `mvn clean package`.)

## Cuentas (se asignan al primer arranque)
El script crea el administrador y, como **datos de ejemplo opcionales**, un cajero, un cliente y muy pocos
medicamentos. Para empezar con el inventario vacío, borra en `Farmacias_BD.sql` la sección
«DATOS DE EJEMPLO» (queda solo el administrador).

| Rol | Correo | Contraseña |
|---|---|---|
| Administrador | admin@farmaciasurb.com | Admin123 |
| Cajero | cajero1@farmaciasurb.com | Cajero123 |
| Cliente | cliente1@farmaciasurb.com | Cliente123 |

> En producción pon `app.inicializar.passwords=false` en `config.properties`, usa HTTPS y credenciales por variables de entorno.

## Pantallas por rol
- **Administrador:** Inicio (alertas), Inventario, Entradas, Salidas, Almacén, Ventas, Configuración › Usuarios / Proveedores / Productos / Clientes
- **Cajero:** Inicio, Inventario, Compras (punto de venta), Catálogos (medicamentos y clientes), Almacén, Ventas, Configuración
- **Cliente:** Inicio (novedades), Compras (su historial y tickets), Catálogos, Configuración

## Estructura
```
Farmacias_URB/
├── pom.xml
├── sql/Farmacias_BD.sql
└── src/
    ├── main/java/org/TecNova/
    │   ├── model/       Entidades JPA (Usuario, Medicamento, Lote, Venta...)
    │   ├── dao/         Interfaces DAO · dao/impl (Hibernate)
    │   ├── service/     Interfaces de servicio · service/impl
    │   ├── controller/  Un Servlet por pantalla (+ BaseServlet con utilidades comunes)
    │   ├── filter/      FiltroSeguridad.java (sesión, roles, CSRF, UTF-8)
    │   ├── listener/    InicioApp.java (arranque: contraseñas de ejemplo)
    │   └── util/        Seguridad (bcrypt) · Validador (regex) · Formato · TicketPdf
    ├── main/resources/  hibernate.cfg.xml · config.properties
    └── webapp/          *.jsp · fragmentos/ · css/ · WEB-INF/web.xml
```
