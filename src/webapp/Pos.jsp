<%@ page import="org.TecNova.model.ItemCarrito" %>
<%@ page import="org.TecNova.model.Venta" %>
<%@ page import="org.TecNova.service.ReporteService" %>
<%@ page import="org.TecNova.service.impl.ReporteServiceImpl" %>
<%@ page import="org.TecNova.util.Config" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "pos"; String titulo = "Compras · Punto de venta"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String q = request.getParameter( "q" ) == null ? "" : request.getParameter( "q" ).trim( );
    ReporteService reporteService = new ReporteServiceImpl( );
    List<Map<String, Object>> lotes = reporteService.lotesDisponibles( q );

    List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute( "carrito" );
    if( carrito == null )
    {
        carrito = new ArrayList<>( );
    }
    BigDecimal tasa = new BigDecimal( Config.get( "iva.tasa", "0.00" ) );
    BigDecimal subtotal = BigDecimal.ZERO;
    for( ItemCarrito item : carrito )
    {
        subtotal = subtotal.add( item.getSubtotal( ) );
    }
    BigDecimal iva = subtotal.multiply( tasa ).setScale( 2, RoundingMode.HALF_UP );
    BigDecimal total = subtotal.add( iva );

    Venta ultimaVenta = (Venta) session.getAttribute( "ultimaVenta" );
    session.removeAttribute( "ultimaVenta" );
%>
<h1 class="titulo-seccion">Compras · Punto de venta</h1>

<% if( ultimaVenta != null ) { %>
<div class="alert alert-success d-flex flex-wrap justify-content-between align-items-center gap-2">
    <span><i class="bi bi-check-circle-fill"></i> Venta registrada · Folio <strong><%= Formato.esc( ultimaVenta.getFolioTicket( ) ) %></strong>
        · Total <%= Formato.dinero( ultimaVenta.getTotal( ) ) %>
        <% if( ultimaVenta.getPuntosGenerados( ) > 0 ) { %>· <%= ultimaVenta.getPuntosGenerados( ) %> puntos para el cliente<% } %></span>
    <a class="btn btn-success btn-sm" target="_blank" href="TicketServlet?id=<%= ultimaVenta.getId( ) %>"><i class="bi bi-file-earmark-pdf"></i> Ver ticket PDF</a>
</div>
<% } %>

<div class="row g-4">
    <!-- ===== Búsqueda de productos ===== -->
    <div class="col-lg-7">
        <form class="barra-filtros" method="get" action="Pos.jsp">
            <input class="form-control" style="max-width:340px" type="search" name="q" autofocus
                   placeholder="Buscar por nombre o código de barras" value="<%= Formato.esc( q ) %>">
            <button class="btn btn-urb btn-chico" type="submit">Buscar</button>
        </form>

        <div class="tabla-responsive">
            <table class="tabla-urb">
                <thead><tr><th>Medicamento</th><th>Precio</th><th>Disp.</th><th>Agregar</th></tr></thead>
                <tbody>
                <% for( Map<String, Object> lote : lotes ) { %>
                <tr>
                    <td><%= Formato.esc( lote.get( "nombre_comercial" ) ) %><br>
                        <small>Lote <%= Formato.esc( lote.get( "num_lote" ) ) %> · cad. <%= Formato.fecha( lote.get( "fecha_caducidad" ) ) %></small></td>
                    <td class="text-end"><%= Formato.dinero( lote.get( "precio_venta" ) ) %></td>
                    <td class="text-center"><%= Formato.entero( lote.get( "stock_actual" ) ) %></td>
                    <td>
                        <form action="PosServlet" method="post" class="d-flex gap-1 justify-content-center">
                            <%= Formato.csrf( session ) %>
                            <input type="hidden" name="accion" value="agregar">
                            <input type="hidden" name="q" value="<%= Formato.esc( q ) %>">
                            <input type="hidden" name="idLote" value="<%= lote.get( "id_lote" ) %>">
                            <input class="form-control form-control-sm entrada-cantidad" type="number" name="cantidad"
                                   value="1" min="1" max="<%= Formato.entero( lote.get( "stock_actual" ) ) %>">
                            <button class="btn btn-urb btn-chico" type="submit" title="Agregar al carrito"><i class="bi bi-cart-plus"></i></button>
                        </form>
                    </td>
                </tr>
                <% } %>
                <% if( lotes.isEmpty( ) ) { %>
                <tr><td colspan="4" class="vacio">No hay productos disponibles con esa búsqueda.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ===== Carrito ===== -->
    <div class="col-lg-5">
        <div class="panel-carrito">
            <h2 class="h5 mb-3"><i class="bi bi-cart3"></i> Carrito</h2>

            <% if( carrito.isEmpty( ) ) { %>
            <p class="text-secondary mb-0">El carrito está vacío. Agrega productos de la lista.</p>
            <% } %>

            <% for( ItemCarrito item : carrito ) { %>
            <div class="border-bottom pb-2 mb-2">
                <div class="d-flex justify-content-between">
                    <strong><%= Formato.esc( item.getMedicamento( ) ) %></strong>
                    <span><%= Formato.dinero( item.getSubtotal( ) ) %></span>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                    <small class="text-secondary">Lote <%= Formato.esc( item.getNumLote( ) ) %> · <%= Formato.dinero( item.getPrecio( ) ) %> c/u</small>
                    <div class="d-flex gap-1">
                        <form action="PosServlet" method="post" class="d-flex gap-1">
                            <%= Formato.csrf( session ) %>
                            <input type="hidden" name="accion" value="cantidad">
                            <input type="hidden" name="q" value="<%= Formato.esc( q ) %>">
                            <input type="hidden" name="idLote" value="<%= item.getIdLote( ) %>">
                            <input class="form-control form-control-sm entrada-cantidad" type="number" name="cantidad"
                                   value="<%= item.getCantidad( ) %>" min="0" max="<%= item.getStock( ) %>">
                            <button class="btn btn-outline-primary btn-chico" type="submit" title="Actualizar cantidad"><i class="bi bi-arrow-repeat"></i></button>
                        </form>
                        <form action="PosServlet" method="post">
                            <%= Formato.csrf( session ) %>
                            <input type="hidden" name="accion" value="quitar">
                            <input type="hidden" name="q" value="<%= Formato.esc( q ) %>">
                            <input type="hidden" name="idLote" value="<%= item.getIdLote( ) %>">
                            <button class="btn btn-outline-danger btn-chico" type="submit" title="Quitar"><i class="bi bi-trash"></i></button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>

            <% if( !carrito.isEmpty( ) ) { %>
            <div class="total-linea"><span>Subtotal</span><span><%= Formato.dinero( subtotal ) %></span></div>
            <div class="total-linea"><span>IVA (<%= tasa.multiply( BigDecimal.valueOf( 100 ) ).setScale( 0, RoundingMode.HALF_UP ) %>%)</span><span><%= Formato.dinero( iva ) %></span></div>
            <div class="total-linea grande"><span>Total</span><span><%= Formato.dinero( total ) %></span></div>

            <form action="PosServlet" method="post" class="mt-3">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="cobrar">
                <input type="hidden" name="q" value="<%= Formato.esc( q ) %>">
                <label class="form-label">Teléfono del cliente (opcional, suma puntos)</label>
                <input class="form-control mb-2" name="telefonoCliente" pattern="[0-9]{10}" maxlength="10"
                       inputmode="numeric" title="10 dígitos" placeholder="10 dígitos">
                <label class="form-label">Método de pago</label>
                <select class="form-select mb-3" name="metodoPago" required>
                    <option value="EFECTIVO">Efectivo</option>
                    <option value="TARJETA">Tarjeta</option>
                    <option value="TRANSFERENCIA">Transferencia</option>
                </select>
                <button class="btn btn-urb w-100 py-2" type="submit"><i class="bi bi-cash-coin"></i> Cobrar</button>
            </form>
            <form action="PosServlet" method="post" class="mt-2">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="vaciar">
                <input type="hidden" name="q" value="<%= Formato.esc( q ) %>">
                <button class="btn btn-outline-secondary w-100 btn-sm" type="submit">Vaciar carrito</button>
            </form>
            <% } %>
        </div>
    </div>
</div>
<%@ include file="fragmentos/pie.jspf" %>
