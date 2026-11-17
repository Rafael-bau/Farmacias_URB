<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="org.TecNova.util.Formato" %>
<%
    String ctx = request.getContextPath( );
    if( session.getAttribute( "usuario" ) != null )
    {
        response.sendRedirect( ctx + "/index.jsp" );
        return;
    }
    String error = (String) request.getAttribute( "error" );
    String correo = (String) request.getAttribute( "correo" );
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesión · Farmacias URB</title>
    <link href="https://fonts.googleapis.com/css2?family=Alike&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <link rel="stylesheet" href="<%= ctx %>/css/estilos.css">
</head>
<body class="login-fondo">
    <h1 class="login-titulo">Farmacias URB</h1>

    <form class="login-card" method="post" action="<%= ctx %>/LoginServlet" autocomplete="on">
        <%= Formato.csrf( session ) %>
        <h2>Log in</h2>
        <% if( error != null ) { %>
        <div class="alert alert-danger py-2"><%= Formato.esc( error ) %></div>
        <% } %>
        <input type="text" name="correo" placeholder="Correo Electrónico / Usuario" maxlength="100"
               value="<%= Formato.esc( correo ) %>" required autofocus autocomplete="username">
        <input type="password" name="password" placeholder="Contraseña" maxlength="72"
               required autocomplete="current-password">
        <button type="submit" class="btn-login">Log in</button>
    </form>
</body>
</html>
