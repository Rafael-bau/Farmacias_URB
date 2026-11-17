<%@ page import="org.TecNova.service.CategoriaService" %>
<%@ page import="org.TecNova.service.impl.CategoriaServiceImpl" %>
<%@ page import="org.TecNova.model.Categoria" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "productos"; String titulo = "Productos › Categorías"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    CategoriaService categoriaService = new CategoriaServiceImpl( );
    List<Categoria> categorias = categoriaService.findAll( );
%>
<h1 class="titulo-seccion">Productos › Categorías</h1>
<button type="button" class="btn btn-success mb-3" data-bs-toggle="modal" data-bs-target="#categoriaModal" onclick="nuevoCategoria()">
    Agregar categoría
</button>
<p><a href="Medicamentos.jsp" class="btn btn-outline-secondary btn-sm">← Volver a productos</a></p>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr>
        <th scope="col">#</th>
        <th scope="col">Nombre</th>
        <th scope="col">Acción</th>
    </tr>
    </thead>
    <tbody>
    <% int i = 0;
       for( Categoria categoria : categorias )
       {
    %>
    <tr class="<%= "" %>">
        <th scope="row"><%= ++i %></th>
        <td><a href="Categoria.jsp?id=<%= categoria.getId( ) %>" class="link-primary link-offset-2 link-underline-opacity-25 link-underline-opacity-100-hover"><%= Formato.esc( categoria.getNombre( ) ) %></a></td>
        <td class="text-nowrap">
            <button type="button" class="btn btn-warning btn-sm btn-editar" data-bs-toggle="modal" data-bs-target="#categoriaModal"
                    data-id="<%= categoria.getId( ) %>" data-nombre="<%= Formato.esc( categoria.getNombre( ) ) %>">
                Editar
            </button>
            <form action="CategoriaServlet" method="post" style="display:inline;">
                <%= Formato.csrf( session ) %>
                <input type="hidden" name="accion" value="delete">
                <input type="hidden" name="id" value="<%= categoria.getId( ) %>">
                <button type="submit" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Seguro que deseas eliminar esta categoría?');">
                    Borrar
                </button>
            </form>
        </td>
    </tr>
    <% } %>
    <% if( categorias.isEmpty( ) ) { %>
    <tr><td colspan="3" class="vacio">Aún no hay categorías. Crea la primera con el botón verde.</td></tr>
    <% } %>
    </tbody>
</table>
</div>

<div class="modal fade" id="categoriaModal" tabindex="-1" aria-labelledby="categoriaModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="categoriaModalLabel">Formulario de categoría</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <form action="CategoriaServlet" method="post" id="formCategoria">
        <%= Formato.csrf( session ) %>
        <input type="hidden" id="accion" name="accion" value="save" />
        <input type="hidden" id="id" name="id" value="">
        <div class="modal-body">

          <div class="mb-3">
            <label for="nombre" class="form-label">Nombre de la categoría</label>
            <input type="text" class="form-control" id="nombre" name="nombre" maxlength="50" required>
          </div>

        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
          <button type="submit" class="btn btn-primary" id="btnGuardar">Guardar categoría</button>
        </div>
      </form>

    </div>
  </div>
</div>

<script>
    function nuevoCategoria()
    {
        document.getElementById("formCategoria").reset();
        document.getElementById("id").value = "0";
        document.getElementById("accion").value = "save";
        document.getElementById("categoriaModalLabel").textContent = "Agregar categoría";
        document.getElementById("btnGuardar").textContent = "Guardar categoría";
    }
    const modalCategoria = document.getElementById("categoriaModal");
    modalCategoria.addEventListener("show.bs.modal",
        function(event)
        {
            const boton = event.relatedTarget;
            if (!boton || !boton.classList.contains("btn-editar"))
            {
                return;
            }
            document.getElementById("id").value = boton.getAttribute("data-id");
            document.getElementById("nombre").value = boton.getAttribute("data-nombre");
            document.getElementById("accion").value = "update";
            document.getElementById("categoriaModalLabel").textContent = "Editar categoría";
            document.getElementById("btnGuardar").textContent = "Actualizar categoría";
        }
    );
</script>
<%@ include file="fragmentos/pie.jspf" %>
