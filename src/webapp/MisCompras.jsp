<%@ page import="org.TecNova.model.Venta" %>
<%@ page import="org.TecNova.service.VentaService" %>
<%@ page import="org.TecNova.service.impl.VentaServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "compras"; String titulo = "Compras"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    Long clienteId = (Long) session.getAttribute( "clienteId" );
    List<Map<String, Object>> compras = new ArrayList<>( );
    if( clienteId != null )
    {
        compras = new VentaServiceImpl( ).comprasDeCliente( clienteId );
    }
%>
<h1 class="titulo-seccion">Compras</h1>
<% if( clienteId == null ) { %>
<div class="alert alert-warning">Tu cuenta aún no está vinculada a un cliente. Pide al administrador que la vincule.</div>
<% } %>

<div class="row g-4">
    <% for( Map<String, Object> fila : compras )
       {
           Venta venta = (Venta) fila.get( "venta" );
           boolean cancelada = "CANCELADA".equals( venta.getEstatusVenta( ) );
    %>
    <div class="col-md-6 col-xl-4">
        <div class="tarjeta-urb <%= cancelada ? "opacity-50" : "" %>">
            <small class="text-secondary"><%= Formato.fecha( venta.getFechaVenta( ) ) %> · Folio <%= Formato.esc( venta.getFolioTicket( ) ) %></small>
            <h3><%= Formato.esc( fila.get( "articulos" ) ) %></h3>
            <small>Pago: <%= Formato.esc( venta.getMetodoPago( ) ) %>
                <% if( !cancelada && venta.getPuntosGenerados( ) > 0 ) { %> · +<%= venta.getPuntosGenerados( ) %> puntos<% } %>
                <% if( cancelada ) { %> · <strong>CANCELADA</strong><% } %></small>
            <span class="precio"><%= Formato.dinero( venta.getTotal( ) ) %></span>
            <a class="btn btn-outline-primary btn-sm mt-2 align-self-start" target="_blank" href="TicketServlet?id=<%= venta.getId( ) %>">Ver ticket PDF</a>
        </div>
    </div>
    <% } %>
    <% if( compras.isEmpty( ) && clienteId != null ) { %>
    <p class="text-center text-secondary">Aún no tienes compras registradas.</p>
    <% } %>
</div>
<%@ include file="fragmentos/pie.jspf" %>
