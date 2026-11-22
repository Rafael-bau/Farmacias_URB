package org.TecNova.controller;

import org.TecNova.model.Usuario;
import org.TecNova.service.RolService;
import org.TecNova.service.UsuarioService;
import org.TecNova.service.impl.RolServiceImpl;
import org.TecNova.service.impl.UsuarioServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet( "/UsuarioServlet" )
public class UsuarioServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final UsuarioService service = new UsuarioServiceImpl( );
    private final RolService rolService = new RolServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            Long id = id( req.getParameter( "id" ) );
            Long propio = usuario( req ).getId( );
            if( "delete".equals( req.getParameter( "accion" ) ) )
            {
                if( id == null )
                {
                    throw new IllegalArgumentException( "El usuario no existe." );
                }
                if( id.equals( propio ) )
                {
                    throw new IllegalArgumentException( "No puedes dar de baja tu propia cuenta." );
                }
                service.deleteById( id );                       // baja lógica
                ok( req, "Usuario dado de baja (puedes reactivarlo editándolo)." );
            }
            else
            {
                Usuario u = id == null ? new Usuario( ) : service.findById( id );
                if( u == null )
                {
                    throw new IllegalArgumentException( "El usuario no existe." );
                }
                boolean activo = !"0".equals( req.getParameter( "estatus" ) );
                if( id != null && !activo && id.equals( propio ) )
                {
                    throw new IllegalArgumentException( "No puedes dar de baja tu propia cuenta." );
                }
                u.setNombre( texto( req, "nombre" ) );
                u.setCorreo( texto( req, "correo" ) );
                u.setRol( rolService.findById( id( req.getParameter( "rolId" ) ) ) );
                u.setEstatus( activo );
                Long clienteId = id( req.getParameter( "clienteId" ) );
                String password = req.getParameter( "password" );
                if( id == null )
                {
                    service.crear( u, password, clienteId );
                    ok( req, "Usuario creado correctamente." );
                }
                else
                {
                    service.actualizar( u, password, clienteId );
                    ok( req, "Usuario actualizado correctamente." );
                }
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Usuarios.jsp" );
    }
}
