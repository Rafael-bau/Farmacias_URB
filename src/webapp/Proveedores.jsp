<%@ page import="org.TecNova.service.ProveedorService" %>
<%@ page import="org.TecNova.service.impl.ProveedorServiceImpl" %>
<%@ page import="org.TecNova.model.Proveedor" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "proveedores"; String titulo = "Proveedores"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    ProveedorService proveedorService = new ProveedorServiceImpl( );
    List<Proveedor> proveedores = proveedorService.findAll( );
%>
<h1 class="titulo-seccion">Proveedores</h1>
<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#proveedorModal" onclick="nuevoProveedor()">
    Agregar proveedor
</button>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr>
        <th scope="col">#</th>
        <th scope="col">Proveedor</th>
        <th scope="col">Teléfono</th>
        <th scope="col">Correo</th>
        <th scope="col">Estatus</th>
        <th scope="col">Acción</th>
    </tr>
    </thead>
    <tbody>
    <% int i = 0;
       for( Proveedor proveedor : proveedores )
       {
    %>
    <tr class="<%= proveedor.getEstatus( ) ? "" : "fila-inactiva" %>">
        <th scope="row"><%= ++i %></th>
        <td><a href="Proveedor.jsp?id=<%= proveedor.getId( ) %>" class="link-primary link-offset-2 link-underline-opacity-25 link-underline-opacity-100-hover"><%= Formato.esc( proveedor.getNombre( ) ) %></a><br><small><%= Formato.esc( proveedor.getDireccion( ) ) %></small></td>
        <td><%= Formato.esc( proveedor.getTelefono( ) ) %></td>
        <td><%= Formato.esc( proveedor.getCorreo( ) ) %></td>
        <td><span class="insignia <%= proveedor.getEstatus( ) ? "ok" : "peligro" %>"><%= proveedor.getEstatus( ) ? "Activo" : "Baja" %></span></td>
        <td class="text-nowrap">
            <button type="button" class="btn btn-warning btn-sm btn-editar" data-bs-toggle="modal" data-bs-target="#proveedorModal"
                    data-id="<%= proveedor.getId( ) %>" data-nombre="<%= Formato.esc( proveedor.getNombre( ) ) %>" data-telefono="<%= Formato.esc( proveedor.getTelefono( ) ) %>" data-correo="<%= Formato.esc( proveedor.getCorreo( ) ) %>" data-direccion="<%= Formato.esc( proveedor.getDireccion( ) ) %>" data-estatus="<%= proveedor.getEstatus( ) ? 1 : 0 %>">
                Editar
            </button>
            <form action="ProveedorServlet" method="post" style="display:inline;">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="delete">
                <input type="hidden" name="id" value="<%= proveedor.getId( ) %>">
                <button type="submit" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Dar de baja este proveedor?');">
                    Baja
                </button>
            </form>
        </td>
    </tr>
    <% } %>
    <% if( proveedores.isEmpty( ) ) { %>
    <tr><td colspan="6" class="vacio">Aún no hay proveedores. Crea el primero con el botón verde.</td></tr>
    <% } %>
    </tbody>
</table>
</div>

<div class="modal fade" id="proveedorModal" tabindex="-1" aria-labelledby="proveedorModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="proveedorModalLabel">Formulario de proveedor</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <form action="ProveedorServlet" method="post" id="formProveedor">
        <%= Formato.csrf( session ) %>
        <input type="hidden" id="accion" name="accion" value="save" />
        <input type="hidden" id="id" name="id" value="">
        <div class="modal-body">

          <div class="mb-3">
            <label for="nombre" class="form-label">Nombre / razón social</label>
            <input type="text" class="form-control" id="nombre" name="nombre" maxlength="100" required>
          </div>

          <div class="mb-3">
            <label for="telefono" class="form-label">Teléfono (10 dígitos)</label>
            <input type="text" class="form-control" id="telefono" name="telefono" pattern="[0-9]{10}" maxlength="10" inputmode="numeric" title="Deben ser 10 dígitos">
          </div>

          <div class="mb-3">
            <label for="correo" class="form-label">Correo electrónico</label>
            <input type="email" class="form-control" id="correo" name="correo" maxlength="100">
          </div>

          <div class="mb-3">
            <label for="direccion" class="form-label">Dirección</label>
            <input type="text" class="form-control" id="direccion" name="direccion" maxlength="200">
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
          <button type="submit" class="btn btn-primary" id="btnGuardar">Guardar proveedor</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
    function nuevoProveedor()
    {
        document.getElementById("formProveedor").reset();
        document.getElementById("id").value = "0";
        document.getElementById("accion").value = "save";
        document.getElementById("proveedorModalLabel").textContent = "Agregar proveedor";
        document.getElementById("btnGuardar").textContent = "Guardar proveedor";
    }
    const modalProveedor = document.getElementById("proveedorModal");
    modalProveedor.addEventListener("show.bs.modal",
        function(event)
        {
            const boton = event.relatedTarget;
            if (!boton || !boton.classList.contains("btn-editar"))
            {
                return;
            }
            document.getElementById("id").value = boton.getAttribute("data-id");
            document.getElementById("nombre").value = boton.getAttribute("data-nombre");
            document.getElementById("telefono").value = boton.getAttribute("data-telefono");
            document.getElementById("correo").value = boton.getAttribute("data-correo");
            document.getElementById("direccion").value = boton.getAttribute("data-direccion");
            document.getElementById("estatus").value = boton.getAttribute("data-estatus");
            document.getElementById("accion").value = "update";
            document.getElementById("proveedorModalLabel").textContent = "Editar proveedor";
            document.getElementById("btnGuardar").textContent = "Actualizar proveedor";
        }
    );
</script>
<%@ include file="fragmentos/pie.jspf" %>
