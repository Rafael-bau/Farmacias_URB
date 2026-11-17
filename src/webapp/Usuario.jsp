<%@ page import="org.TecNova.service.UsuarioService" %>
<%@ page import="org.TecNova.service.impl.UsuarioServiceImpl" %>
<%@ page import="org.TecNova.model.Usuario" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "usuarios"; String titulo = "Usuario"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String usuarioId = request.getParameter( "id" );
    UsuarioService usuarioService = null;
    Usuario usuario = null;
    if( usuarioId != null && usuarioId.matches( "[0-9]+" ) )
    {
        usuarioService = new UsuarioServiceImpl( );
        usuario = usuarioService.findById( Long.parseLong( usuarioId ) );
    }
%>
<h1 class="titulo-seccion">Usuario</h1>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr><th colspan="2">Información</th></tr>
    </thead>
    <tbody>
    <% if( usuario != null ) { %>
    <tr>
        <td>Nombre</td>
        <td><%= Formato.esc( usuario.getNombre( ) ) %></td>
    </tr>
    <tr>
        <td>Correo</td>
        <td><%= Formato.esc( usuario.getCorreo( ) ) %></td>
    </tr>
    <tr>
        <td>Rol</td>
        <td><%= Formato.esc( usuario.getRol( ).getNombre( ) ) %></td>
    </tr>
    <tr>
        <td>Estatus</td>
        <td><span class="insignia <%= usuario.getEstatus( ) ? "ok" : "peligro" %>"><%= usuario.getEstatus( ) ? "Activo" : "Baja" %></span></td>
    </tr>
    <tr>
        <td>Creado</td>
        <td><%= Formato.fecha( usuario.getFechaCreacion( ) ) %></td>
    </tr>
    <% } else { %>
    <tr><td colspan="2" class="vacio">Registro no encontrado.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<a href="Usuarios.jsp" class="btn btn-secondary">Regresar</a>
<%@ include file="fragmentos/pie.jspf" %>
