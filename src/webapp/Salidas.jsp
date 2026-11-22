<%@ page import="org.TecNova.model.Lote" %>
<%@ page import="org.TecNova.model.Salida" %>
<%@ page import="org.TecNova.service.LoteService" %>
<%@ page import="org.TecNova.service.SalidaService" %>
<%@ page import="org.TecNova.service.impl.LoteServiceImpl" %>
<%@ page import="org.TecNova.service.impl.SalidaServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "salidas"; String titulo = "Salidas"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    SalidaService salidaService = new SalidaServiceImpl( );
    List<Salida> salidas = salidaService.findAll( );
    LoteService loteService = new LoteServiceImpl( );
    List<Lote> lotes = loteService.findConStock( );
%>
<h1 class="titulo-seccion">Salidas</h1>
<p class="text-secondary">Salidas de inventario que no son ventas: merma, productos caducados o ajustes por conteo. Las ventas se consultan en la sección Ventas.</p>

<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#salidaModal">
    Registrar salida
</button>

<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead>
        <tr><th>Medicamento</th><th>Lote</th><th>Cantidad</th><th>Motivo</th><th>Observaciones</th><th>Fecha</th></tr>
        </thead>
        <tbody>
        <% for( Salida salida : salidas ) { %>
        <tr>
            <td><%= Formato.esc( salida.getLote( ).getMedicamento( ).getNombreComercial( ) ) %><br><small>Registró: <%= Formato.esc( salida.getUsuario( ).getNombre( ) ) %></small></td>
            <td><%= Formato.esc( salida.getLote( ).getNumLote( ) ) %></td>
            <td class="text-center"><%= salida.getCantidad( ) %></td>
            <td class="text-center"><%= Formato.esc( salida.getMotivo( ) ) %></td>
            <td><%= Formato.esc( salida.getObservaciones( ) ) %></td>
            <td class="text-center"><%= Formato.fecha( salida.getFecha( ) ) %></td>
        </tr>
        <% } %>
        <% if( salidas.isEmpty( ) ) { %>
        <tr><td colspan="6" class="vacio">Aún no hay salidas registradas.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>

<div class="modal fade" id="salidaModal" tabindex="-1" aria-labelledby="salidaModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="salidaModalLabel">Registrar salida</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <form action="SalidaServlet" method="post">
        <%= Formato.csrf( session ) %>
        <div class="modal-body">
          <div class="mb-3">
            <label for="loteId" class="form-label">Lote</label>
            <select class="form-select" id="loteId" name="loteId" required>
                <option value="">Selecciona un lote</option>
                <% for( Lote lote : lotes ) { %>
                <option value="<%= lote.getId( ) %>"><%= Formato.esc( lote.getMedicamento( ).getNombreComercial( ) ) %> · Lote <%= Formato.esc( lote.getNumLote( ) ) %> · <%= lote.getStockActual( ) %> pzas · cad. <%= Formato.fecha( lote.getFechaCaducidad( ) ) %></option>
                <% } %>
            </select>
          </div>
          <div class="row">
            <div class="col-5 mb-3">
              <label for="cantidad" class="form-label">Cantidad</label>
              <input type="number" class="form-control" id="cantidad" name="cantidad" min="1" step="1" required>
            </div>
            <div class="col-7 mb-3">
              <label for="motivo" class="form-label">Motivo</label>
              <select class="form-select" id="motivo" name="motivo" required>
                  <option value="CADUCIDAD">Caducidad</option>
                  <option value="MERMA">Merma (daño / pérdida)</option>
                  <option value="AJUSTE">Ajuste de inventario</option>
                  <option value="OTRO">Otro</option>
              </select>
            </div>
          </div>
          <div class="mb-3">
            <label for="observaciones" class="form-label">Observaciones (opcional)</label>
            <input type="text" class="form-control" id="observaciones" name="observaciones" maxlength="200">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
          <button type="submit" class="btn btn-primary">Registrar salida</button>
        </div>
      </form>
    </div>
  </div>
</div>
<%@ include file="fragmentos/pie.jspf" %>
