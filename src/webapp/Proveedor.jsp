<%@ page import="org.TecNova.service.ProveedorService" %>
<%@ page import="org.TecNova.service.impl.ProveedorServiceImpl" %>
<%@ page import="org.TecNova.model.Proveedor" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "proveedores"; String titulo = "Proveedor"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String proveedorId = request.getParameter( "id" );
    ProveedorService proveedorService = null;
    Proveedor proveedor = null;
    if( proveedorId != null && proveedorId.matches( "[0-9]+" ) )
    {
        proveedorService = new ProveedorServiceImpl( );
        proveedor = proveedorService.findById( Long.parseLong( proveedorId ) );
    }
%>
<h1 class="titulo-seccion">Proveedor</h1>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr><th colspan="2">Información</th></tr>
    </thead>
    <tbody>
    <% if( proveedor != null ) { %>
    <tr>
        <td>Nombre</td>
        <td><%= Formato.esc( proveedor.getNombre( ) ) %></td>
    </tr>
    <tr>
        <td>Teléfono</td>
        <td><%= Formato.esc( proveedor.getTelefono( ) ) %></td>
    </tr>
    <tr>
        <td>Correo</td>
        <td><%= Formato.esc( proveedor.getCorreo( ) ) %></td>
    </tr>
    <tr>
        <td>Dirección</td>
        <td><%= Formato.esc( proveedor.getDireccion( ) ) %></td>
    </tr>
    <tr>
        <td>Estatus</td>
        <td><span class="insignia <%= proveedor.getEstatus( ) ? "ok" : "peligro" %>"><%= proveedor.getEstatus( ) ? "Activo" : "Baja" %></span></td>
    </tr>
    <% } else { %>
    <tr><td colspan="2" class="vacio">Registro no encontrado.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<a href="Proveedores.jsp" class="btn btn-secondary">Regresar</a>
<%@ include file="fragmentos/pie.jspf" %>
