<%@ page import="org.TecNova.service.MedicamentoService" %>
<%@ page import="org.TecNova.service.impl.MedicamentoServiceImpl" %>
<%@ page import="org.TecNova.model.Medicamento" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "productos"; String titulo = "Medicamento"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String medicamentoId = request.getParameter( "id" );
    MedicamentoService medicamentoService = null;
    Medicamento medicamento = null;
    if( medicamentoId != null && medicamentoId.matches( "[0-9]+" ) )
    {
        medicamentoService = new MedicamentoServiceImpl( );
        medicamento = medicamentoService.findById( Long.parseLong( medicamentoId ) );
    }
%>
<h1 class="titulo-seccion">Medicamento</h1>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr><th colspan="2">Información</th></tr>
    </thead>
    <tbody>
    <% if( medicamento != null ) { %>
    <tr>
        <td>Código de barras</td>
        <td><%= Formato.esc( medicamento.getCodigoBarras( ) ) %></td>
    </tr>
    <tr>
        <td>Nombre comercial</td>
        <td><%= Formato.esc( medicamento.getNombreComercial( ) ) %></td>
    </tr>
    <tr>
        <td>Sustancia activa</td>
        <td><%= Formato.esc( medicamento.getSustanciaActiva( ) ) %></td>
    </tr>
    <tr>
        <td>Categoría</td>
        <td><%= Formato.esc( medicamento.getCategoria( ).getNombre( ) ) %></td>
    </tr>
    <tr>
        <td>Precio de venta</td>
        <td><%= Formato.dinero( medicamento.getPrecioVenta( ) ) %></td>
    </tr>
    <tr>
        <td>Stock mínimo</td>
        <td><%= Formato.esc( medicamento.getStockMinimo( ) ) %></td>
    </tr>
    <tr>
        <td>Estatus</td>
        <td><span class="insignia <%= medicamento.getEstatus( ) ? "ok" : "peligro" %>"><%= medicamento.getEstatus( ) ? "Activo" : "Baja" %></span></td>
    </tr>
    <% } else { %>
    <tr><td colspan="2" class="vacio">Registro no encontrado.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<a href="Medicamentos.jsp" class="btn btn-secondary">Regresar</a>
<%@ include file="fragmentos/pie.jspf" %>
