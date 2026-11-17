<%@ page import="org.TecNova.model.Entrada" %>
<%@ page import="org.TecNova.model.Medicamento" %>
<%@ page import="org.TecNova.model.Proveedor" %>
<%@ page import="org.TecNova.service.EntradaService" %>
<%@ page import="org.TecNova.service.MedicamentoService" %>
<%@ page import="org.TecNova.service.ProveedorService" %>
<%@ page import="org.TecNova.service.impl.EntradaServiceImpl" %>
<%@ page import="org.TecNova.service.impl.MedicamentoServiceImpl" %>
<%@ page import="org.TecNova.service.impl.ProveedorServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "entradas"; String titulo = "Entradas"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    EntradaService entradaService = new EntradaServiceImpl( );
    List<Entrada> entradas = entradaService.findAll( );
    List<Proveedor> proveedores = new ProveedorServiceImpl( ).findActivos( );
    List<Medicamento> medicamentos = new MedicamentoServiceImpl( ).findActivos( );
%>
<h1 class="titulo-seccion">Entradas</h1>

<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#entradaModal">
    Registrar entrada de mercancía
</button>

<div class="tabla-responsive">
    <table class="tabla-urb">
        <thead>
        <tr><th>Medicamento</th><th>Lote</th><th>Caducidad</th><th>Cantidad</th><th>Costo</th><th>Proveedor</th><th>Fecha</th></tr>
        </thead>
        <tbody>
        <% for( Entrada entrada : entradas ) { %>
        <tr>
            <td><%= Formato.esc( entrada.getLote( ).getMedicamento( ).getNombreComercial( ) ) %><br><small>Registró: <%= Formato.esc( entrada.getUsuario( ).getNombre( ) ) %></small></td>
            <td><%= Formato.esc( entrada.getLote( ).getNumLote( ) ) %></td>
            <td class="text-center"><%= Formato.fecha( entrada.getLote( ).getFechaCaducidad( ) ) %></td>
            <td class="text-center"><%= entrada.getCantidad( ) %></td>
            <td class="text-end"><%= Formato.dinero( entrada.getCostoUnitario( ) ) %></td>
            <td><%= Formato.esc( entrada.getProveedor( ).getNombre( ) ) %></td>
            <td class="text-center"><%= Formato.fecha( entrada.getFecha( ) ) %></td>
        </tr>
        <% } %>
        <% if( entradas.isEmpty( ) ) { %>
        <tr><td colspan="7" class="vacio">Aún no hay entradas registradas.</td></tr>
        <% } %>
        </tbody>
    </table>
</div>

<div class="modal fade" id="entradaModal" tabindex="-1" aria-labelledby="entradaModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="entradaModalLabel">Registrar entrada</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <form action="EntradaServlet" method="post">
        <%= Formato.csrf( session ) %>
        <div class="modal-body">
          <div class="mb-3">
            <label for="proveedorId" class="form-label">Proveedor</label>
            <select class="form-select" id="proveedorId" name="proveedorId" required>
                <option value="">Selecciona un proveedor</option>
                <% for( Proveedor proveedor : proveedores ) { %>
                <option value="<%= proveedor.getId( ) %>"><%= Formato.esc( proveedor.getNombre( ) ) %></option>
                <% } %>
            </select>
            <% if( proveedores.isEmpty( ) ) { %><small class="text-danger">Primero registra un proveedor en Configuración › Proveedores.</small><% } %>
          </div>
          <div class="mb-3">
            <label for="medicamentoId" class="form-label">Medicamento</label>
            <select class="form-select" id="medicamentoId" name="medicamentoId" required>
                <option value="">Selecciona un medicamento</option>
                <% for( Medicamento medicamento : medicamentos ) { %>
                <option value="<%= medicamento.getId( ) %>"><%= Formato.esc( medicamento.getNombreComercial( ) ) %> (<%= Formato.esc( medicamento.getCodigoBarras( ) ) %>)</option>
                <% } %>
            </select>
            <% if( medicamentos.isEmpty( ) ) { %><small class="text-danger">Primero registra medicamentos en Configuración › Productos.</small><% } %>
          </div>
          <div class="mb-3">
            <label for="numLote" class="form-label">Número de lote</label>
            <input type="text" class="form-control" id="numLote" name="numLote" maxlength="50" required>
          </div>
          <div class="row">
            <div class="col-6 mb-3">
              <label for="fechaCaducidad" class="form-label">Fecha de caducidad</label>
              <input type="date" class="form-control" id="fechaCaducidad" name="fechaCaducidad" required>
            </div>
            <div class="col-6 mb-3">
              <label for="cantidad" class="form-label">Cantidad recibida</label>
              <input type="number" class="form-control" id="cantidad" name="cantidad" min="1" step="1" required>
            </div>
          </div>
          <div class="mb-3">
            <label for="costoUnitario" class="form-label">Costo unitario ($)</label>
            <input type="number" class="form-control" id="costoUnitario" name="costoUnitario" min="0" step="0.01" value="0.00">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
          <button type="submit" class="btn btn-primary">Registrar entrada</button>
        </div>
      </form>
    </div>
  </div>
</div>
<%@ include file="fragmentos/pie.jspf" %>
