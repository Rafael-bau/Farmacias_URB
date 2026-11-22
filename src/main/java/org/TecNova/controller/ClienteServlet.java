package org.TecNova.controller;

import org.TecNova.model.Cliente;
import org.TecNova.service.ClienteService;
import org.TecNova.service.impl.ClienteServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet( "/ClienteServlet" )
public class ClienteServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final ClienteService service = new ClienteServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            Long id = id( req.getParameter( "id" ) );
            if( "delete".equals( req.getParameter( "accion" ) ) )
            {
                if( !"Administrador".equals( usuario( req ).getRol( ).getNombre( ) ) )
                {
                    throw new IllegalArgumentException( "Solo el administrador puede eliminar clientes." );
                }
                if( id == null )
                {
                    throw new IllegalArgumentException( "El cliente no existe." );
                }
                service.deleteById( id );
                ok( req, "Cliente eliminado (sus ventas se conservan)." );
            }
            else
            {
                Cliente cliente = id == null ? new Cliente( ) : service.findById( id );
                if( cliente == null )
                {
                    throw new IllegalArgumentException( "El cliente no existe." );
                }
                cliente.setNombre( texto( req, "nombre" ) );
                cliente.setTelefono( texto( req, "telefono" ) );
                cliente.setCorreo( texto( req, "correo" ) );
                if( id == null )
                {
                    service.save( cliente );
                    ok( req, "Cliente registrado correctamente." );
                }
                else
                {
                    service.update( cliente );
                    ok( req, "Cliente actualizado correctamente." );
                }
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Clientes.jsp" );
    }
}
