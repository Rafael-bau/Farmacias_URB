<%@ page import="org.TecNova.service.ClienteService" %>
<%@ page import="org.TecNova.service.impl.ClienteServiceImpl" %>
<%@ page import="org.TecNova.model.Cliente" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "Cajero".equals( ( (org.TecNova.model.Usuario) session.getAttribute( "usuario" ) ).getRol( ).getNombre( ) ) ? "catalogos" : "clientes"; String titulo = "Clientes"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    ClienteService clienteService = new ClienteServiceImpl( );
    List<Cliente> clientes = clienteService.findAll( );
%>
<h1 class="titulo-seccion">Clientes</h1>
<% if( esCajero ) { %>
<ul class="nav nav-tabs mb-3">
    <li class="nav-item"><a class="nav-link" href="Catalogos.jsp">Medicamentos</a></li>
    <li class="nav-item"><a class="nav-link active" href="Clientes.jsp">Clientes</a></li>
</ul>
<% } %>
<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#clienteModal" onclick="nuevoCliente()">
    Agregar cliente
</button>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr>
        <th scope="col">#</th>
        <th scope="col">Cliente</th>
        <th scope="col">Teléfono</th>
        <th scope="col">Correo</th>
        <th scope="col">Puntos</th>
        <th scope="col">Acción</th>
    </tr>
    </thead>
    <tbody>
    <% int i = 0;
       for( Cliente cliente : clientes )
       {
    %>
    <tr class="<%= "" %>">
        <th scope="row"><%= ++i %></th>
        <td><a href="Cliente.jsp?id=<%= cliente.getId( ) %>" class="link-primary link-offset-2 link-underline-opacity-25 link-underline-opacity-100-hover"><%= Formato.esc( cliente.getNombre( ) ) %></a></td>
        <td><%= Formato.esc( cliente.getTelefono( ) ) %></td>
        <td><%= Formato.esc( cliente.getCorreo( ) ) %></td>
        <td><%= Formato.esc( cliente.getPuntosAcumulados( ) ) %></td>
        <td class="text-nowrap">
            <button type="button" class="btn btn-warning btn-sm btn-editar" data-bs-toggle="modal" data-bs-target="#clienteModal"
                    data-id="<%= cliente.getId( ) %>" data-nombre="<%= Formato.esc( cliente.getNombre( ) ) %>" data-telefono="<%= Formato.esc( cliente.getTelefono( ) ) %>" data-correo="<%= Formato.esc( cliente.getCorreo( ) ) %>">
                Editar
            </button>
            <% if( esAdmin ) { %>
            <form action="ClienteServlet" method="post" style="display:inline;">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="delete">
                <input type="hidden" name="id" value="<%= cliente.getId( ) %>">
                <button type="submit" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Eliminar a este cliente? Sus ventas se conservan.');">
                    Borrar
                </button>
            </form>
            <% } %>
        </td>
    </tr>
    <% } %>
    <% if( clientes.isEmpty( ) ) { %>
    <tr><td colspan="6" class="vacio">No hay clientes registrados.</td></tr>
    <% } %>
    </tbody>
</table>
</div>

<div class="modal fade" id="clienteModal" tabindex="-1" aria-labelledby="clienteModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="clienteModalLabel">Formulario de cliente</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <form action="ClienteServlet" method="post" id="formCliente">
        <%= Formato.csrf( session ) %>
        <input type="hidden" id="accion" name="accion" value="save" />
        <input type="hidden" id="id" name="id" value="">
        <div class="modal-body">

          <div class="mb-3">
            <label for="nombre" class="form-label">Nombre completo</label>
            <input type="text" class="form-control" id="nombre" name="nombre" maxlength="100" required pattern="[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ .'\-]{2,99}" title="Solo letras y espacios (mínimo 3 caracteres)">
          </div>

          <div class="mb-3">
            <label for="telefono" class="form-label">Teléfono (10 dígitos)</label>
            <input type="text" class="form-control" id="telefono" name="telefono" pattern="[0-9]{10}" maxlength="10" inputmode="numeric" title="Deben ser 10 dígitos, sin espacios ni guiones" required>
          </div>

          <div class="mb-3">
            <label for="correo" class="form-label">Correo electrónico</label>
            <input type="email" class="form-control" id="correo" name="correo" maxlength="100" required>
          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
          <button type="submit" class="btn btn-primary" id="btnGuardar">Guardar cliente</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
    function nuevoCliente()
    {
        document.getElementById("formCliente").reset();
        document.getElementById("id").value = "0";
        document.getElementById("accion").value = "save";
        document.getElementById("clienteModalLabel").textContent = "Agregar cliente";
        document.getElementById("btnGuardar").textContent = "Guardar cliente";
    }
    const modalCliente = document.getElementById("clienteModal");
    modalCliente.addEventListener("show.bs.modal",
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
            document.getElementById("accion").value = "update";
            document.getElementById("clienteModalLabel").textContent = "Editar cliente";
            document.getElementById("btnGuardar").textContent = "Actualizar cliente";
        }
    );
</script>
<%@ include file="fragmentos/pie.jspf" %>
