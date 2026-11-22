package org.TecNova.controller;

import org.TecNova.model.Proveedor;
import org.TecNova.service.ProveedorService;
import org.TecNova.service.impl.ProveedorServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet( "/ProveedorServlet" )
public class ProveedorServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final ProveedorService service = new ProveedorServiceImpl( );

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
                    throw new IllegalArgumentException( "El proveedor no existe." );
                }
                service.deleteById( id );                       // baja lógica
                ok( req, "Proveedor dado de baja (puedes reactivarlo editándolo)." );
            }
            else
            {
                Proveedor p = id == null ? new Proveedor( ) : service.findById( id );
                if( p == null )
                {
                    throw new IllegalArgumentException( "El proveedor no existe." );
                }
                p.setNombre( texto( req, "nombre" ) );
                p.setTelefono( texto( req, "telefono" ) );
                p.setCorreo( texto( req, "correo" ) );
                p.setDireccion( texto( req, "direccion" ) );
                p.setEstatus( !"0".equals( req.getParameter( "estatus" ) ) );
                if( id == null )
                {
                    service.save( p );
                    ok( req, "Proveedor creado correctamente." );
                }
                else
                {
                    service.update( p );
                    ok( req, "Proveedor actualizado correctamente." );
                }
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Proveedores.jsp" );
    }
}
