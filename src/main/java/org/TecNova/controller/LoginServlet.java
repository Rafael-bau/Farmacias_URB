package org.TecNova.controller;

import org.TecNova.model.Cliente;
import org.TecNova.model.Usuario;
import org.TecNova.service.ClienteService;
import org.TecNova.service.UsuarioService;
import org.TecNova.service.impl.ClienteServiceImpl;
import org.TecNova.service.impl.UsuarioServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/** RF-01: inicio de sesión. */
@WebServlet( "/LoginServlet" )
public class LoginServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final UsuarioService usuarioService = new UsuarioServiceImpl( );
    private final ClienteService clienteService = new ClienteServiceImpl( );

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        ir( req, resp, "Login.jsp" );
    }

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException
    {
        String correo = texto( req, "correo" );
        String password = req.getParameter( "password" );
        Usuario usuario = null;
        try
        {
            usuario = usuarioService.autenticar( correo, password );
        }
        catch( RuntimeException e )
        {
            req.setAttribute( "error", org.TecNova.util.Errores.mensaje( e ) );
            req.setAttribute( "correo", correo );
            req.getRequestDispatcher( "/Login.jsp" ).forward( req, resp );
            return;
        }
        if( usuario == null )
        {
            req.setAttribute( "error", "Correo o contraseña incorrectos." );
            req.setAttribute( "correo", correo );
            req.getRequestDispatcher( "/Login.jsp" ).forward( req, resp );
            return;
        }
        req.changeSessionId( );                                  // evita fijación de sesión
        HttpSession sesion = req.getSession( );
        sesion.setAttribute( "usuario", usuario );
        sesion.removeAttribute( "clienteId" );
        if( "Cliente".equals( usuario.getRol( ).getNombre( ) ) )
        {
            Cliente cliente = clienteService.findByUsuarioId( usuario.getId( ) );
            if( cliente != null )
            {
                sesion.setAttribute( "clienteId", cliente.getId( ) );
            }
        }
        ir( req, resp, "index.jsp" );
    }
}
