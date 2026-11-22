<%@ page import="org.TecNova.model.Venta" %>
<%@ page import="org.TecNova.service.VentaService" %>
<%@ page import="org.TecNova.service.impl.VentaServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "ventas"; String titulo = "Ventas"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    VentaService ventaService = new VentaServiceImpl( );
    List<Venta> ventas = ventaService.findHistorial( usuarioSesion );
%>
<h1 class="titulo-seccion">Ventas</h1>
<% if( esCajero ) { %>
<p class="text-secondary">Se muestran tus ventas. Para registrar una nueva, ve a <a href="Pos.jsp">Compras</a>.</p>
<% } %>

<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead>
        <tr><th>Folio</th><th>Fecha</th><th>Cliente</th><th>Cajero</th><th>Pago</th><th>Total</th><th>Estatus</th><th>Acción</th></tr>
        </thead>
        <tbody>
        <% for( Venta venta : ventas )
           {
               boolean cancelada = "CANCELADA".equals( venta.getEstatusVenta( ) );
        %>
        <tr class="<%= cancelada ? "fila-inactiva" : "" %>">
            <td><%= Formato.esc( venta.getFolioTicket( ) ) %></td>
            <td class="text-center"><%= Formato.fecha( venta.getFechaVenta( ) ) %></td>
            <td><%= venta.getCliente( ) == null ? "Mostrador" : Formato.esc( venta.getCliente( ).getNombre( ) ) %></td>
            <td><%= Formato.esc( venta.getUsuario( ).getNombre( ) ) %></td>
            <td class="text-center"><%= Formato.esc( venta.getMetodoPago( ) ) %></td>
            <td class="text-end"><%= Formato.dinero( venta.getTotal( ) ) %></td>
            <td class="text-center"><span class="insignia <%= cancelada ? "peligro" : "ok" %>"><%= Formato.esc( venta.getEstatusVenta( ) ) %></span></td>
            <td class="text-nowrap">
                <a class="btn btn-outline-primary btn-sm" target="_blank" href="TicketServlet?id=<%= venta.getId( ) %>">Ticket PDF</a>
                <% if( esAdmin && !cancelada ) { %>
                <form action="VentaServlet" method="post" style="display:inline;">
                    <%= Formato.csrf( session ) %>
                    <input type="hidden" name="accion" value="cancel">
                    <input type="hidden" name="id" value="<%= venta.getId( ) %>">
                    <button type="submit" class="btn btn-danger btn-sm"
                            onclick="return confirm('¿Cancelar esta venta? Se devolverá el stock y se revertirán los puntos.');">
                        Cancelar
                    </button>
                </form>
                <% } %>
            </td>
        </tr>
        <% } %>
        <% if( ventas.isEmpty( ) ) { %>
        <tr><td colspan="8" class="vacio">Aún no hay ventas registradas.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<%@ include file="fragmentos/pie.jspf" %>
