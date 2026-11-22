<%@ page import="org.TecNova.service.ClienteService" %>
<%@ page import="org.TecNova.service.impl.ClienteServiceImpl" %>
<%@ page import="org.TecNova.model.Cliente" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "Cajero".equals( ( (org.TecNova.model.Usuario) session.getAttribute( "usuario" ) ).getRol( ).getNombre( ) ) ? "catalogos" : "clientes"; String titulo = "Cliente"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String clienteId = request.getParameter( "id" );
    ClienteService clienteService = null;
    Cliente cliente = null;
    if( clienteId != null && clienteId.matches( "[0-9]+" ) )
    {
        clienteService = new ClienteServiceImpl( );
        cliente = clienteService.findById( Long.parseLong( clienteId ) );
    }
%>
<h1 class="titulo-seccion">Cliente</h1>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr><th colspan="2">Información</th></tr>
    </thead>
    <tbody>
    <% if( cliente != null ) { %>
    <tr>
        <td>Nombre</td>
        <td><%= Formato.esc( cliente.getNombre( ) ) %></td>
    </tr>
    <tr>
        <td>Teléfono</td>
        <td><%= Formato.esc( cliente.getTelefono( ) ) %></td>
    </tr>
    <tr>
        <td>Correo</td>
        <td><%= Formato.esc( cliente.getCorreo( ) ) %></td>
    </tr>
    <tr>
        <td>Puntos acumulados</td>
        <td><%= Formato.esc( cliente.getPuntosAcumulados( ) ) %></td>
    </tr>
    <tr>
        <td>Registro</td>
        <td><%= Formato.fecha( cliente.getFechaRegistro( ) ) %></td>
    </tr>
    <% } else { %>
    <tr><td colspan="2" class="vacio">Registro no encontrado.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<a href="Clientes.jsp" class="btn btn-secondary">Regresar</a>
<%@ include file="fragmentos/pie.jspf" %>
