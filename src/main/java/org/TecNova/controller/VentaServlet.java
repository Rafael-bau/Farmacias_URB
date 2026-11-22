package org.TecNova.controller;

import org.TecNova.service.VentaService;
import org.TecNova.service.impl.VentaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Cancelación de ventas (solo administrador; el filtro ya lo restringe). */
@WebServlet( "/VentaServlet" )
public class VentaServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final VentaService service = new VentaServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            Long id = id( req.getParameter( "id" ) );
            if( id == null )
            {
                throw new IllegalArgumentException( "La venta no existe." );
            }
            service.cancelar( id );
            ok( req, "Venta cancelada: el stock y los puntos fueron revertidos." );
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Ventas.jsp" );
    }
}
