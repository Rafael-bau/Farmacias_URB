<%@ page import="org.TecNova.service.ReporteService" %>
<%@ page import="org.TecNova.service.impl.ReporteServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "catalogos"; String titulo = "Catálogos"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String q = request.getParameter( "q" ) == null ? "" : request.getParameter( "q" ).trim( );
    ReporteService reporteService = new ReporteServiceImpl( );
    List<Map<String, Object>> productos = reporteService.catalogo( q );
%>
<h1 class="titulo-seccion">Catálogos</h1>

<% if( esCajero ) { %>
<ul class="nav nav-tabs mb-3">
    <li class="nav-item"><a class="nav-link active" href="Catalogos.jsp">Medicamentos</a></li>
    <li class="nav-item"><a class="nav-link" href="Clientes.jsp">Clientes</a></li>
</ul>
<% } %>

<form class="barra-filtros" method="get" action="Catalogos.jsp">
    <input class="form-control" style="max-width:340px" type="search" name="q" placeholder="Buscar por nombre o sustancia activa" value="<%= Formato.esc( q ) %>">
    <button class="btn btn-urb btn-chico" type="submit">Buscar</button>
</form>

<div class="row g-4">
    <% for( Map<String, Object> p : productos ) { %>
    <div class="col-md-6 col-xl-4">
        <div class="tarjeta-urb">
            <i class="bi bi-capsule-pill icono-grande"></i>
            <h3><%= Formato.esc( p.get( "nombre_comercial" ) ) %></h3>
            <small class="text-secondary"><%= Formato.esc( p.get( "sustancia_activa" ) ) %> · <%= Formato.esc( p.get( "nombre_categoria" ) ) %></small>
            <% if( Formato.entero( p.get( "stock" ) ) > 0 ) { %>
            <span class="insignia ok align-self-start">Disponible</span>
            <% } else { %>
            <span class="insignia peligro align-self-start">Agotado</span>
            <% } %>
            <span class="precio"><%= Formato.dinero( p.get( "precio_venta" ) ) %></span>
        </div>
    </div>
    <% } %>
    <% if( productos.isEmpty( ) ) { %>
    <p class="text-center text-secondary">No se encontraron medicamentos.</p>
    <% } %>
</div>
<%@ include file="fragmentos/pie.jspf" %>
