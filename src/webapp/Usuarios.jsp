<%@ page import="org.TecNova.service.UsuarioService" %>
<%@ page import="org.TecNova.service.impl.UsuarioServiceImpl" %>
<%@ page import="org.TecNova.model.Usuario" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page import="org.TecNova.service.RolService" %>
<%@ page import="org.TecNova.service.impl.RolServiceImpl" %>
<%@ page import="org.TecNova.model.Rol" %>
<%@ page import="org.TecNova.service.ClienteService" %>
<%@ page import="org.TecNova.service.impl.ClienteServiceImpl" %>
<%@ page import="org.TecNova.model.Cliente" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "usuarios"; String titulo = "Usuarios"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    UsuarioService usuarioService = new UsuarioServiceImpl( );
    List<Usuario> usuarios = usuarioService.findAll( );
    RolService rolService = new RolServiceImpl( );
    List<Rol> roles = rolService.findAll( );
    ClienteService clienteService = new ClienteServiceImpl( );
    List<Cliente> clientes = clienteService.findAll( );
    Map<Long, Cliente> clientePorUsuario = new HashMap<>( );
    for( Cliente cl : clientes )
    {
        if( cl.getUsuario( ) != null )
        {
            clientePorUsuario.put( cl.getUsuario( ).getId( ), cl );
        }
    }
%>
<h1 class="titulo-seccion">Usuarios</h1>
<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#usuarioModal" onclick="nuevoUsuario()">
    Agregar usuario
</button>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr>
        <th scope="col">#</th>
        <th scope="col">Usuario</th>
        <th scope="col">Rol</th>
        <th scope="col">Cliente vinculado</th>
        <th scope="col">Estatus</th>
        <th scope="col">Acción</th>
    </tr>
    </thead>
    <tbody>
    <% int i = 0;
       for( Usuario usuario : usuarios )
       {
    %>
    <tr class="<%= usuario.getEstatus( ) ? "" : "fila-inactiva" %>">
        <th scope="row"><%= ++i %></th>
        <td><a href="Usuario.jsp?id=<%= usuario.getId( ) %>" class="link-primary link-offset-2 link-underline-opacity-25 link-underline-opacity-100-hover"><%= Formato.esc( usuario.getNombre( ) ) %></a><br><small><%= Formato.esc( usuario.getCorreo( ) ) %></small></td>
        <td><%= Formato.esc( usuario.getRol( ).getNombre( ) ) %></td>
        <td><%= Formato.esc( clientePorUsuario.get( usuario.getId( ) ) == null ? "" : clientePorUsuario.get( usuario.getId( ) ).getNombre( ) ) %></td>
        <td><span class="insignia <%= usuario.getEstatus( ) ? "ok" : "peligro" %>"><%= usuario.getEstatus( ) ? "Activo" : "Baja" %></span></td>
        <td class="text-nowrap">
            <button type="button" class="btn btn-warning btn-sm btn-editar" data-bs-toggle="modal" data-bs-target="#usuarioModal"
                    data-id="<%= usuario.getId( ) %>" data-nombre="<%= Formato.esc( usuario.getNombre( ) ) %>" data-correo="<%= Formato.esc( usuario.getCorreo( ) ) %>" data-rolid="<%= usuario.getRol( ).getId( ) %>" data-clienteid="<%= clientePorUsuario.get( usuario.getId( ) ) == null ? "" : clientePorUsuario.get( usuario.getId( ) ).getId( ) %>" data-estatus="<%= usuario.getEstatus( ) ? 1 : 0 %>">
                Editar
            </button>
            <% if( !usuario.getId( ).equals( usuarioSesion.getId( ) ) ) { %>
            <form action="UsuarioServlet" method="post" style="display:inline;">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="delete">
                <input type="hidden" name="id" value="<%= usuario.getId( ) %>">
                <button type="submit" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Dar de baja a este usuario?');">
                    Baja
                </button>
            </form>
            <% } %>
        </td>
    </tr>
    <% } %>
    <% if( usuarios.isEmpty( ) ) { %>
    <tr><td colspan="6" class="vacio">No hay usuarios.</td></tr>
    <% } %>
    </tbody>
</table>
</div>

<div class="modal fade" id="usuarioModal" tabindex="-1" aria-labelledby="usuarioModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="usuarioModalLabel">Formulario de usuario</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <form action="UsuarioServlet" method="post" id="formUsuario">
        <%= Formato.csrf( session ) %>
        <input type="hidden" id="accion" name="accion" value="save" />
        <input type="hidden" id="id" name="id" value="">
        <div class="modal-body">

          <div class="mb-3">
            <label for="nombre" class="form-label">Nombre completo</label>
            <input type="text" class="form-control" id="nombre" name="nombre" maxlength="100" required pattern="[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ .'\-]{2,99}" title="Solo letras y espacios (mínimo 3 caracteres)">
          </div>

          <div class="mb-3">
            <label for="correo" class="form-label">Correo electrónico</label>
            <input type="email" class="form-control" id="correo" name="correo" maxlength="100" required>
          </div>

          <div class="mb-3">
            <label for="password" class="form-label">Contraseña <small class="text-secondary" id="ayudaPassword">(mínimo 8 caracteres)</small></label>
            <input type="password" class="form-control" id="password" name="password" minlength="8" maxlength="72" autocomplete="new-password" required>
          </div>

          <div class="mb-3">
            <label for="rolId" class="form-label">Rol</label>
            <select class="form-select" id="rolId" name="rolId" required>
                <option value="" data-cliente="0">Selecciona un rol</option>
                <% for( Rol rol : roles ) { %>
                <option value="<%= rol.getId( ) %>" data-cliente="<%= "Cliente".equals( rol.getNombre( ) ) ? 1 : 0 %>"><%= Formato.esc( rol.getNombre( ) ) %></option>
                <% } %>
            </select>
          </div>

          <div class="mb-3" id="bloqueCliente" style="display:none">
            <label for="clienteId" class="form-label">Cliente al que pertenece la cuenta</label>
            <select class="form-select" id="clienteId" name="clienteId">
                <option value="">Selecciona un cliente</option>
                <% for( Cliente cl : clientes ) { %>
                <option value="<%= cl.getId( ) %>"><%= Formato.esc( cl.getNombre( ) ) %> (<%= Formato.esc( cl.getTelefono( ) ) %>)<%= cl.getUsuario( ) != null ? " — ya tiene cuenta" : "" %></option>
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
          <button type="submit" class="btn btn-primary" id="btnGuardar">Guardar usuario</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
    function nuevoUsuario()
    {
        document.getElementById("formUsuario").reset();
        document.getElementById("id").value = "0";
        document.getElementById("accion").value = "save";
        document.getElementById("usuarioModalLabel").textContent = "Agregar usuario";
        document.getElementById("btnGuardar").textContent = "Guardar usuario";
        document.getElementById("password").required = true;
        document.getElementById("ayudaPassword").textContent = "(mínimo 8 caracteres)";
        actualizarCliente();
    }
    const modalUsuario = document.getElementById("usuarioModal");
    modalUsuario.addEventListener("show.bs.modal",
        function(event)
        {
            const boton = event.relatedTarget;
            if (!boton || !boton.classList.contains("btn-editar"))
            {
                return;
            }
            document.getElementById("id").value = boton.getAttribute("data-id");
            document.getElementById("nombre").value = boton.getAttribute("data-nombre");
            document.getElementById("correo").value = boton.getAttribute("data-correo");
            document.getElementById("rolId").value = boton.getAttribute("data-rolid");
            document.getElementById("clienteId").value = boton.getAttribute("data-clienteid");
            document.getElementById("estatus").value = boton.getAttribute("data-estatus");
            document.getElementById("accion").value = "update";
            document.getElementById("usuarioModalLabel").textContent = "Editar usuario";
            document.getElementById("btnGuardar").textContent = "Actualizar usuario";
        document.getElementById("password").value = "";
        document.getElementById("password").required = false;
        document.getElementById("ayudaPassword").textContent = "(déjala vacía para no cambiarla)";
        actualizarCliente();
        }
    );
    // El selector de cliente solo se muestra cuando el rol elegido es "Cliente"
    function actualizarCliente()
    {
        const sel = document.getElementById("rolId");
        const opcion = sel.options[sel.selectedIndex];
        const esCliente = opcion && opcion.getAttribute("data-cliente") === "1";
        document.getElementById("bloqueCliente").style.display = esCliente ? "" : "none";
        document.getElementById("clienteId").required = esCliente;
    }
    document.getElementById("rolId").addEventListener("change", actualizarCliente);
</script>
<%@ include file="fragmentos/pie.jspf" %>
