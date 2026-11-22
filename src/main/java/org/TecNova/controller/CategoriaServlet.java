package org.TecNova.controller;

import org.TecNova.model.Categoria;
import org.TecNova.service.CategoriaService;
import org.TecNova.service.impl.CategoriaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet( "/CategoriaServlet" )
public class CategoriaServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final CategoriaService service = new CategoriaServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            Long id = id( req.getParameter( "id" ) );
            if( "delete".equals( req.getParameter( "accion" ) ) )
            {
                if( id == null )
                {
                    throw new IllegalArgumentException( "La categoría no existe." );
                }
                service.deleteById( id );
                ok( req, "Categoría eliminada." );
            }
            else
            {
                Categoria categoria = id == null ? new Categoria( ) : service.findById( id );
                if( categoria == null )
                {
                    throw new IllegalArgumentException( "La categoría no existe." );
                }
                categoria.setNombre( texto( req, "nombre" ) );
                if( id == null )
                {
                    service.save( categoria );
                    ok( req, "Categoría creada correctamente." );
                }
                else
                {
                    service.update( categoria );
                    ok( req, "Categoría actualizada correctamente." );
                }
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Categorias.jsp" );
    }
}
