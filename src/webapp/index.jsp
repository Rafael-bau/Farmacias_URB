<%@ page import="org.TecNova.service.ReporteService" %>
<%@ page import="org.TecNova.service.impl.ReporteServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "inicio"; String titulo = "Inicio"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    ReporteService reporteService = new ReporteServiceImpl( );
    boolean esCliente = !esAdmin && !esCajero;
%>
<% if( esCliente ) {
    List<Map<String, Object>> novedades = reporteService.novedades( 6 );
%>
<div class="banner"><span>Farmacias URB</span></div>
<h1 class="titulo-seccion">Inicio</h1>
<h2 class="text-center fw-normal mb-4">Novedades</h2>
<div class="row g-4">
    <% for( Map<String, Object> p : novedades ) { %>
    <div class="col-md-6 col-xl-4">
        <div class="tarjeta-urb">
            <i class="bi bi-capsule-pill icono-grande"></i>
            <h3><%= Formato.esc( p.get( "nombre_comercial" ) ) %></h3>
            <small class="text-secondary"><%= Formato.esc( p.get( "sustancia_activa" ) ) %> · <%= Formato.esc( p.get( "nombre_categoria" ) ) %></small>
            <span class="precio"><%= Formato.dinero( p.get( "precio_venta" ) ) %></span>
        </div>
    </div>
    <% } %>
    <% if( novedades.isEmpty( ) ) { %>
    <p class="text-center text-secondary">Pronto habrá novedades.</p>
    <% } %>
</div>
<% } else {
    long alertasCaducidad = reporteService.totalCaducidad( );
    long alertasStock = reporteService.totalStockBajo( );
    List<Map<String, Object>> medicamentos = reporteService.resumenStock( 10 );
%>
<h1 class="titulo-seccion">Inicio</h1>
<div class="row g-4 justify-content-between">
    <div class="col-lg-5">
        <a class="alerta-card alerta-caducidad" href="<%= ctx %>/Inventario.jsp?filtro=caducidad">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>Alerta de Caducidad &gt;&gt; <span class="contador"><%= alertasCaducidad %></span></span>
        </a>
    </div>
    <div class="col-lg-5">
        <a class="alerta-card alerta-stock" href="<%= ctx %>/Almacen.jsp?filtro=stock">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>Stock Bajo &gt;&gt; <span class="contador"><%= alertasStock %></span></span>
        </a>
    </div>
</div>

<h2 class="subtitulo">Medicamentos</h2>
<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead><tr><th>Medicamento</th><th>Stock</th></tr></thead>
        <tbody>
        <% for( Map<String, Object> m : medicamentos ) {
            String estado = (String) m.get( "estado" );
            String clase = "AGOTADO".equals( estado ) ? "fila-caducado" : "STOCK BAJO".equals( estado ) ? "fila-alerta" : "";
        %>
        <tr class="<%= clase %>">
            <td><%= Formato.esc( m.get( "nombre_comercial" ) ) %></td>
            <td class="text-center"><%= Formato.entero( m.get( "stock_vigente" ) ) %></td>
        </tr>
        <% } %>
        <% if( medicamentos.isEmpty( ) ) { %>
        <tr><td colspan="2" class="vacio">Aún no hay medicamentos registrados. Empieza en Configuración › Productos.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>
<%@ include file="fragmentos/pie.jspf" %>
