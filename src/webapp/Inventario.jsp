<%@ page import="org.TecNova.service.ReporteService" %>
<%@ page import="org.TecNova.service.impl.ReporteServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "inventario"; String titulo = "Inventario"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String filtro = request.getParameter( "filtro" ) == null ? "" : request.getParameter( "filtro" );
    String q = request.getParameter( "q" ) == null ? "" : request.getParameter( "q" ).trim( );
    ReporteService reporteService = new ReporteServiceImpl( );
    List<Map<String, Object>> lotes = reporteService.inventario( filtro, q );
%>
<h1 class="titulo-seccion">Inventario</h1>

<form class="barra-filtros" method="get" action="Inventario.jsp">
    <a class="btn btn-sm <%= filtro.isEmpty( ) ? "btn-primary" : "btn-outline-primary" %>" href="Inventario.jsp">Todos</a>
    <a class="btn btn-sm <%= "caducidad".equals( filtro ) ? "btn-primary" : "btn-outline-primary" %>" href="Inventario.jsp?filtro=caducidad">Caducidad</a>
    <a class="btn btn-sm <%= "stock".equals( filtro ) ? "btn-primary" : "btn-outline-primary" %>" href="Inventario.jsp?filtro=stock">Stock bajo</a>
    <input type="hidden" name="filtro" value="<%= Formato.esc( filtro ) %>">
    <input class="form-control" style="max-width:280px" type="search" name="q" placeholder="Buscar medicamento o código" value="<%= Formato.esc( q ) %>">
    <button class="btn btn-urb btn-chico" type="submit">Buscar</button>
</form>

<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead><tr><th>Medicamento</th><th>Stock</th><th>Caducidad del lote</th><th>Estado</th></tr></thead>
        <tbody>
        <% for( Map<String, Object> lote : lotes )
           {
               String estado = (String) lote.get( "estado" );
               String clase = "CADUCADO".equals( estado ) ? "fila-caducado"
                       : ( "POR CADUCAR".equals( estado ) || "STOCK BAJO".equals( estado ) ) ? "fila-alerta" : "";
               int dias = Formato.entero( lote.get( "dias_restantes" ) );
        %>
        <tr class="<%= clase %>">
            <td><%= Formato.esc( lote.get( "nombre_comercial" ) ) %><br><small>Lote <%= Formato.esc( lote.get( "num_lote" ) ) %></small></td>
            <td class="text-center"><%= Formato.entero( lote.get( "stock_actual" ) ) %></td>
            <td class="text-center"><%= Formato.fecha( lote.get( "fecha_caducidad" ) ) %>
                <% if( dias >= 0 ) { %><br><small>(<%= dias %> días)</small><% } %></td>
            <td class="text-center"><%= Formato.esc( estado ) %></td>
        </tr>
        <% } %>
        <% if( lotes.isEmpty( ) ) { %>
        <tr><td colspan="4" class="vacio">No hay lotes que mostrar.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<%@ include file="fragmentos/pie.jspf" %>
