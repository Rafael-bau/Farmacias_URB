<%@ page import="org.TecNova.model.Cliente" %>
<%@ page import="org.TecNova.service.ClienteService" %>
<%@ page import="org.TecNova.service.impl.ClienteServiceImpl" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "configuracion"; String titulo = "Configuración"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    Long clienteId = (Long) session.getAttribute( "clienteId" );
    Cliente perfilCliente = null;
    if( clienteId != null )
    {
        perfilCliente = new ClienteServiceImpl( ).findById( clienteId );
    }
%>
<h1 class="titulo-seccion">Configuración</h1>

<div class="row g-4">
    <div class="col-lg-5">
        <div class="tarjeta-urb">
            <h3>Mi cuenta</h3>
            <p class="mb-1"><strong><%= Formato.esc( usuarioSesion.getNombre( ) ) %></strong></p>
            <p class="mb-1"><%= Formato.esc( usuarioSesion.getCorreo( ) ) %></p>
            <p class="mb-0"><span class="insignia ok"><%= Formato.esc( rolSesion ) %></span></p>
            <% if( perfilCliente != null ) { %>
            <hr>
            <p class="mb-1">Teléfono: <%= Formato.esc( perfilCliente.getTelefono( ) ) %></p>
            <p class="mb-0 fs-5">Puntos acumulados: <strong><%= perfilCliente.getPuntosAcumulados( ) %></strong></p>
            <% } %>
        </div>
    </div>
    <div class="col-lg-5">
        <div class="tarjeta-urb">
            <h3>Cambiar contraseña</h3>
            <form action="ConfiguracionServlet" method="post" class="d-grid gap-2 mt-2">
                <%= Formato.csrf( session ) %>
                <input class="form-control" type="password" name="actual" placeholder="Contraseña actual" required autocomplete="current-password">
                <input class="form-control" type="password" name="nueva" placeholder="Nueva contraseña (mín. 8 caracteres)" minlength="8" maxlength="72" required autocomplete="new-password">
                <input class="form-control" type="password" name="confirmar" placeholder="Confirmar nueva contraseña" minlength="8" maxlength="72" required autocomplete="new-password">
                <button class="btn btn-urb" type="submit">Actualizar contraseña</button>
            </form>
        </div>
    </div>
</div>
<%@ include file="fragmentos/pie.jspf" %>
