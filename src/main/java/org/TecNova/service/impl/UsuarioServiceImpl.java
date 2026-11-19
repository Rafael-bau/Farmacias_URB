package org.TecNova.service.impl;

import org.TecNova.dao.ClienteDao;
import org.TecNova.dao.UsuarioDao;
import org.TecNova.dao.impl.ClienteDaoImpl;
import org.TecNova.dao.impl.UsuarioDaoImpl;
import org.TecNova.model.Usuario;
import org.TecNova.service.UsuarioService;
import org.TecNova.util.Seguridad;
import org.TecNova.util.Validador;

import java.util.List;

public class UsuarioServiceImpl implements UsuarioService
{
    private final UsuarioDao dao = new UsuarioDaoImpl( );
    private final ClienteDao clienteDao = new ClienteDaoImpl( );

    @Override
    public List<Usuario> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Usuario findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Usuario save( Usuario usuario )
    {
        return dao.save( usuario );
    }

    /** Baja lógica: el usuario tiene ventas históricas, no se borra. */
    @Override
    public void deleteById( Long id )
    {
        Usuario usuario = dao.findById( id );
        if( usuario != null )
        {
            usuario.setEstatus( false );
            dao.update( usuario );
        }
    }

    @Override
    public Usuario update( Usuario usuario )
    {
        return dao.update( usuario );
    }

    /** Devuelve el usuario si las credenciales son correctas y está activo; si no, null (RF-01). */
    @Override
    public Usuario autenticar( String correo, String password )
    {
        if( correo == null || password == null )
        {
            return null;
        }
        Usuario usuario = dao.findByCorreo( correo.trim( ).toLowerCase( ) );
        if( usuario == null || !Boolean.TRUE.equals( usuario.getEstatus( ) )
                || !Seguridad.verificar( password, usuario.getPasswordHash( ) ) )
        {
            return null;
        }
        return usuario;
    }

    @Override
    public Usuario crear( Usuario usuario, String password, Long clienteId )
    {
        validar( usuario );
        if( !Validador.password( password ) )
        {
            throw new IllegalArgumentException( "La contraseña debe tener entre 8 y 72 caracteres." );
        }
        exigirCliente( usuario, clienteId );
        usuario.setPasswordHash( Seguridad.hash( password ) );
        usuario.setEstatus( usuario.getEstatus( ) == null ? Boolean.TRUE : usuario.getEstatus( ) );
        Usuario guardado = dao.save( usuario );
        clienteDao.vincularUsuario( "Cliente".equals( usuario.getRol( ).getNombre( ) ) ? clienteId : null, guardado.getId( ) );
        return guardado;
    }

    @Override
    public Usuario actualizar( Usuario usuario, String passwordOpcional, Long clienteId )
    {
        validar( usuario );
        exigirCliente( usuario, clienteId );
        if( passwordOpcional != null && !passwordOpcional.isEmpty( ) )
        {
            if( !Validador.password( passwordOpcional ) )
            {
                throw new IllegalArgumentException( "La contraseña debe tener entre 8 y 72 caracteres." );
            }
            usuario.setPasswordHash( Seguridad.hash( passwordOpcional ) );
        }
        Usuario guardado = dao.update( usuario );
        clienteDao.vincularUsuario( "Cliente".equals( usuario.getRol( ).getNombre( ) ) ? clienteId : null, guardado.getId( ) );
        return guardado;
    }

    private void validar( Usuario usuario )
    {
        String error = Validador.validarPersona( usuario.getNombre( ), usuario.getCorreo( ) );
        if( error != null )
        {
            throw new IllegalArgumentException( error );
        }
        if( usuario.getRol( ) == null )
        {
            throw new IllegalArgumentException( "Selecciona un rol." );
        }
        usuario.setNombre( usuario.getNombre( ).trim( ) );
        usuario.setCorreo( usuario.getCorreo( ).trim( ).toLowerCase( ) );
    }

    private void exigirCliente( Usuario usuario, Long clienteId )
    {
        if( "Cliente".equals( usuario.getRol( ).getNombre( ) ) && clienteId == null )
        {
            throw new IllegalArgumentException( "Para el rol Cliente selecciona el cliente al que pertenece la cuenta." );
        }
    }

    @Override
    public void cambiarPassword( Long idUsuario, String actual, String nueva )
    {
        Usuario usuario = dao.findById( idUsuario );
        if( usuario == null || !Seguridad.verificar( actual == null ? "" : actual, usuario.getPasswordHash( ) ) )
        {
            throw new IllegalArgumentException( "La contraseña actual no es correcta." );
        }
        if( !Validador.password( nueva ) )
        {
            throw new IllegalArgumentException( "La nueva contraseña debe tener entre 8 y 72 caracteres." );
        }
        usuario.setPasswordHash( Seguridad.hash( nueva ) );
        dao.update( usuario );
    }

    /**
     * SOLO DESARROLLO: los usuarios del script SQL traen un hash de marcador. Aquí se reemplaza por
     * una contraseña real según el rol (Admin123 / Cajero123 / Cliente123). Devuelve cuántos cambió.
     */
    @Override
    public int inicializarPasswordsDePrueba( )
    {
        int n = 0;
        for( Usuario usuario : dao.findAll( ) )
        {
            if( usuario.getPasswordHash( ) != null && usuario.getPasswordHash( ).startsWith( "$2b$12$HASH_DE_PRUEBA" ) )
            {
                String rol = usuario.getRol( ).getNombre( );
                String pass = "Administrador".equals( rol ) ? "Admin123" : "Cajero".equals( rol ) ? "Cajero123" : "Cliente123";
                usuario.setPasswordHash( Seguridad.hash( pass ) );
                dao.update( usuario );
                n++;
            }
        }
        return n;
    }
}

