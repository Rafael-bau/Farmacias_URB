<%@ page import="org.TecNova.service.MedicamentoService" %>
<%@ page import="org.TecNova.service.impl.MedicamentoServiceImpl" %>
<%@ page import="org.TecNova.model.Medicamento" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="org.TecNova.service.CategoriaService" %>
<%@ page import="org.TecNova.service.impl.CategoriaServiceImpl" %>
<%@ page import="org.TecNova.model.Categoria" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "productos"; String titulo = "Productos"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    MedicamentoService medicamentoService = new MedicamentoServiceImpl( );
    List<Medicamento> medicamentos = medicamentoService.findAll( );
    CategoriaService categoriaService = new CategoriaServiceImpl( );
    List<Categoria> categorias = categoriaService.findAll( );
%>
<h1 class="titulo-seccion">Productos</h1>
<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#medicamentoModal" onclick="nuevoMedicamento()">
    Agregar medicamento
</button>
<p><a href="Categorias.jsp" class="btn btn-outline-primary btn-sm"><i class="bi bi-tags"></i> Administrar categorías</a></p>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr>
        <th scope="col">#</th>
        <th scope="col">Medicamento</th>
        <th scope="col">Código</th>
        <th scope="col">Categoría</th>
        <th scope="col">Precio</th>
        <th scope="col">Mín.</th>
        <th scope="col">Estatus</th>
        <th scope="col">Acción</th>
    </tr>
    </thead>
    <tbody>
    <% int i = 0;
       for( Medicamento medicamento : medicamentos )
       {
    %>
    <tr class="<%= medicamento.getEstatus( ) ? "" : "fila-inactiva" %>">
        <th scope="row"><%= ++i %></th>
        <td><a href="Medicamento.jsp?id=<%= medicamento.getId( ) %>" class="link-primary link-offset-2 link-underline-opacity-25 link-underline-opacity-100-hover"><%= Formato.esc( medicamento.getNombreComercial( ) ) %></a><br><small><%= Formato.esc( medicamento.getSustanciaActiva( ) ) %></small></td>
        <td><%= Formato.esc( medicamento.getCodigoBarras( ) ) %></td>
        <td><%= Formato.esc( medicamento.getCategoria( ).getNombre( ) ) %></td>
        <td><%= Formato.dinero( medicamento.getPrecioVenta( ) ) %></td>
        <td><%= Formato.esc( medicamento.getStockMinimo( ) ) %></td>
        <td><span class="insignia <%= medicamento.getEstatus( ) ? "ok" : "peligro" %>"><%= medicamento.getEstatus( ) ? "Activo" : "Baja" %></span></td>
        <td class="text-nowrap">
            <button type="button" class="btn btn-warning btn-sm btn-editar" data-bs-toggle="modal" data-bs-target="#medicamentoModal"
                    data-id="<%= medicamento.getId( ) %>" data-codigobarras="<%= Formato.esc( medicamento.getCodigoBarras( ) ) %>" data-nombrecomercial="<%= Formato.esc( medicamento.getNombreComercial( ) ) %>" data-sustanciaactiva="<%= Formato.esc( medicamento.getSustanciaActiva( ) ) %>" data-precioventa="<%= Formato.esc( medicamento.getPrecioVenta( ) ) %>" data-stockminimo="<%= Formato.esc( medicamento.getStockMinimo( ) ) %>" data-categoriaid="<%= medicamento.getCategoria( ).getId( ) %>" data-estatus="<%= medicamento.getEstatus( ) ? 1 : 0 %>">
                Editar
            </button>
            <form action="MedicamentoServlet" method="post" style="display:inline;">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="delete">
                <input type="hidden" name="id" value="<%= medicamento.getId( ) %>">
                <button type="submit" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Dar de baja este medicamento?');">
                    Baja
                </button>
            </form>
        </td>
    </tr>
    <% } %>
    <% if( medicamentos.isEmpty( ) ) { %>
    <tr><td colspan="8" class="vacio">Aún no hay medicamentos. Crea el primero con el botón verde.</td></tr>
    <% } %>
    </tbody>
</table>
</div>

<div class="modal fade" id="medicamentoModal" tabindex="-1" aria-labelledby="medicamentoModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="medicamentoModalLabel">Formulario de medicamento</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <form action="MedicamentoServlet" method="post" id="formMedicamento">
        <%= Formato.csrf( session ) %>
        <input type="hidden" id="accion" name="accion" value="save" />
        <input type="hidden" id="id" name="id" value="">
        <div class="modal-body">

          <div class="mb-3">
            <label for="codigoBarras" class="form-label">Código de barras</label>
            <input type="text" class="form-control" id="codigoBarras" name="codigoBarras" maxlength="50" required>
          </div>

          <div class="mb-3">
            <label for="nombreComercial" class="form-label">Nombre comercial</label>
            <input type="text" class="form-control" id="nombreComercial" name="nombreComercial" maxlength="100" required>
          </div>

          <div class="mb-3">
            <label for="sustanciaActiva" class="form-label">Sustancia activa</label>
            <input type="text" class="form-control" id="sustanciaActiva" name="sustanciaActiva" maxlength="100" required>
          </div>

          <div class="mb-3">
            <label for="precioVenta" class="form-label">Precio de venta ($)</label>
            <input type="number" step="0.01" min="0.01" class="form-control" id="precioVenta" name="precioVenta" required>
          </div>

          <div class="mb-3">
            <label for="stockMinimo" class="form-label">Stock mínimo (alerta de stock bajo)</label>
            <input type="number" min="0" step="1" class="form-control" id="stockMinimo" name="stockMinimo" value="5" required>
          </div>

          <div class="mb-3">
            <label for="categoriaId" class="form-label">Categoría</label>
            <select class="form-select" id="categoriaId" name="categoriaId" required>
                <option value="">Selecciona una categoría</option>
                <% for( Categoria categoria : categorias ) { %>
                <option value="<%= categoria.getId( ) %>"><%= Formato.esc( categoria.getNombre( ) ) %></option>
                <% } %>
            </select>
          </div>

          <div class="mb-3">
            <label for="estatus" class="form-label">Estatus</label>
            <select class="form-select" id="estatus" name="estatus">
                <option value="1">Activo</option>
                <option value="0">Baja</option>
            </select>
          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
          <button type="submit" class="btn btn-primary" id="btnGuardar">Guardar medicamento</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
    function nuevoMedicamento()
    {
        document.getElementById("formMedicamento").reset();
        document.getElementById("id").value = "0";
        document.getElementById("accion").value = "save";
        document.getElementById("medicamentoModalLabel").textContent = "Agregar medicamento";
        document.getElementById("btnGuardar").textContent = "Guardar medicamento";
        document.getElementById("stockMinimo").value = "5";
    }
    const modalMedicamento = document.getElementById("medicamentoModal");
    modalMedicamento.addEventListener("show.bs.modal",
        function(event)
        {
            const boton = event.relatedTarget;
            if (!boton || !boton.classList.contains("btn-editar"))
            {
                return;
            }
            document.getElementById("id").value = boton.getAttribute("data-id");
            document.getElementById("codigoBarras").value = boton.getAttribute("data-codigobarras");
            document.getElementById("nombreComercial").value = boton.getAttribute("data-nombrecomercial");
            document.getElementById("sustanciaActiva").value = boton.getAttribute("data-sustanciaactiva");
            document.getElementById("precioVenta").value = boton.getAttribute("data-precioventa");
            document.getElementById("stockMinimo").value = boton.getAttribute("data-stockminimo");
            document.getElementById("categoriaId").value = boton.getAttribute("data-categoriaid");
            document.getElementById("estatus").value = boton.getAttribute("data-estatus");
            document.getElementById("accion").value = "update";
            document.getElementById("medicamentoModalLabel").textContent = "Editar medicamento";
            document.getElementById("btnGuardar").textContent = "Actualizar medicamento";
        }
    );
</script>
<%@ include file="fragmentos/pie.jspf" %>
