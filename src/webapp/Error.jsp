<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<%@ page import="org.TecNova.util.Formato" %>
<%
    String ctx = request.getContextPath( );
    Object codigo = request.getAttribute( "javax.servlet.error.status_code" );
    Object mensaje = request.getAttribute( "javax.servlet.error.message" );
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Error · Farmacias URB</title>
    <link href="https://fonts.googleapis.com/css2?family=Alike&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <link rel="stylesheet" href="<%= ctx %>/css/estilos.css">
</head>
<body>
    <div class="pagina-error">
        <h1><%= codigo == null ? "Error" : Formato.esc( codigo ) %></h1>
        <p class="fs-4"><%= mensaje == null ? "Ocurrió un error inesperado." : Formato.esc( mensaje ) %></p>
        <a class="btn btn-urb" href="<%= ctx %>/index.jsp">Volver al inicio</a>
    </div>
</body>
</html>
