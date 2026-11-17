<%@ page import="org.TecNova.service.CategoriaService" %>
<%@ page import="org.TecNova.service.impl.CategoriaServiceImpl" %>
<%@ page import="org.TecNova.model.Categoria" %>
<%@ page import="org.TecNova.util.Formato" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<% String activo = "productos"; String titulo = "Categoría"; %>
<%@ include file="fragmentos/cabecera.jspf" %>
<%
    String categoriaId = request.getParameter( "id" );
    CategoriaService categoriaService = null;
    Categoria categoria = null;
    if( categoriaId != null && categoriaId.matches( "[0-9]+" ) )
    {
        categoriaService = new CategoriaServiceImpl( );
        categoria = categoriaService.findById( Long.parseLong( categoriaId ) );
    }
%>
<h1 class="titulo-seccion">Categoría</h1>
<div class="tabla-responsive">
<table class="tabla-urb">
    <thead>
    <tr><th colspan="2">Información</th></tr>
    </thead>
    <tbody>
    <% if( categoria != null ) { %>
    <tr>
        <td>Nombre</td>
        <td><%= Formato.esc( categoria.getNombre( ) ) %></td>
    </tr>
    <% } else { %>
    <tr><td colspan="2" class="vacio">Registro no encontrado.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<a href="Categorias.jsp" class="btn btn-secondary">Regresar</a>
<%@ include file="fragmentos/pie.jspf" %>
