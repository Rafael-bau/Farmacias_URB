package org.TecNova.controller;

import org.TecNova.service.UsuarioService;
import org.TecNova.service.impl.UsuarioServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Cambio de contraseña de la cuenta en sesión. */
@WebServlet( "/ConfiguracionServlet" )
public class ConfiguracionServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final UsuarioService service = new UsuarioServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            String nueva = req.getParameter( "nueva" );
            if( nueva == null || !nueva.equals( req.getParameter( "confirmar" ) ) )
            {
                throw new IllegalArgumentException( "La confirmación no coincide con la nueva contraseña." );
            }
            service.cambiarPassword( usuario( req ).getId( ), req.getParameter( "actual" ), nueva );
            ok( req, "Contraseña actualizada correctamente." );
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Configuracion.jsp" );
    }
}
