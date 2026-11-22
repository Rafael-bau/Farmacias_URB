<%@ page import="org.TecNova.service.ReporteService" %>
<%@ page import="org.TecNova.service.impl.ReporteServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "almacen"; String titulo = "Almacén"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String filtro = request.getParameter( "filtro" ) == null ? "" : request.getParameter( "filtro" );
    String q = request.getParameter( "q" ) == null ? "" : request.getParameter( "q" ).trim( );
    ReporteService reporteService = new ReporteServiceImpl( );
    List<Map<String, Object>> items = reporteService.almacen( filtro, q );
    //gerdoc
%>
<h1 class="titulo-seccion">Almacén</h1>

<form class="barra-filtros" method="get" action="Almacen.jsp">
    <a class="btn btn-sm <%= filtro.isEmpty( ) ? "btn-primary" : "btn-outline-primary" %>" href="Almacen.jsp">Todos</a>
    <a class="btn btn-sm <%= "stock".equals( filtro ) ? "btn-primary" : "btn-outline-primary" %>" href="Almacen.jsp?filtro=stock">Stock bajo / agotados</a>
    <input type="hidden" name="filtro" value="<%= Formato.esc( filtro ) %>">
    <input class="form-control" style="max-width:280px" type="search" name="q" placeholder="Buscar medicamento, código o sustancia" value="<%= Formato.esc( q ) %>">
    <button class="btn btn-urb btn-chico" type="submit">Buscar</button>
</form>

<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead>
        <tr><th>Medicamento</th><th>Categoría</th><th>Stock vigente</th><th>Mínimo</th><th>Lotes</th><th>Próxima caducidad</th><th>Estado</th></tr>
        </thead>
        <tbody>
        <% for( Map<String, Object> a : items )
           {
               String estado = (String) a.get( "estado" );
               String clase = "AGOTADO".equals( estado ) ? "fila-caducado" : "STOCK BAJO".equals( estado ) ? "fila-alerta" : "";
               int caducado = Formato.entero( a.get( "stock_caducado" ) );
        %>
        <tr class="<%= clase %>">
            <td><%= Formato.esc( a.get( "nombre_comercial" ) ) %><br><small><%= Formato.esc( a.get( "sustancia_activa" ) ) %></small></td>
            <td><%= Formato.esc( a.get( "nombre_categoria" ) ) %></td>
            <td class="text-center"><%= Formato.entero( a.get( "stock_vigente" ) ) %>
                <% if( caducado > 0 ) { %><br><small>(+<%= caducado %> caducado)</small><% } %></td>
            <td class="text-center"><%= Formato.entero( a.get( "stock_minimo" ) ) %></td>
            <td class="text-center"><%= Formato.entero( a.get( "lotes_con_stock" ) ) %></td>
            <td class="text-center"><%= Formato.fecha( a.get( "proxima_caducidad" ) ) %></td>
            <td class="text-center"><%= Formato.esc( estado ) %></td>
        </tr>
        <% } %>
        <% if( items.isEmpty( ) ) { %>
        <tr><td colspan="7" class="vacio">No hay medicamentos que mostrar.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<%@ include file="fragmentos/pie.jspf" %>
