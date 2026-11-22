package org.TecNova.controller;

import org.TecNova.service.SalidaService;
import org.TecNova.service.impl.SalidaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Salidas que no son ventas: merma, caducidad, ajustes. */
@WebServlet( "/SalidaServlet" )
public class SalidaServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final SalidaService service = new SalidaServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            service.registrar( id( req.getParameter( "loteId" ) ), entero( req, "cantidad" ),
                    texto( req, "motivo" ), texto( req, "observaciones" ), usuario( req ) );
            ok( req, "Salida registrada: el stock del lote se actualizó." );
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Salidas.jsp" );
    }
}
