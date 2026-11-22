package org.TecNova.service.impl;

import org.TecNova.dao.ClienteDao;
import org.TecNova.dao.impl.ClienteDaoImpl;
import org.TecNova.model.Cliente;
import org.TecNova.service.ClienteService;
import org.TecNova.util.Validador;

import java.util.List;

public class ClienteServiceImpl implements ClienteService
{
    private final ClienteDao dao = new ClienteDaoImpl( );

    @Override
    public List<Cliente> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Cliente findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Cliente save( Cliente cliente )
    {
        validar( cliente );
        if( cliente.getPuntosAcumulados( ) == null )
        {
            cliente.setPuntosAcumulados( 0 );
        }
        return dao.save( cliente );
    }

    @Override
    public void deleteById( Long id )
    {
        dao.deleteById( id );      // sus ventas se conservan (id_cliente pasa a NULL en la BD)
    }

    @Override
    public Cliente update( Cliente cliente )
    {
        validar( cliente );
        return dao.update( cliente );
    }

    /** RF-10: validación estricta con expresiones regulares en el servidor. */
    private void validar( Cliente cliente )
    {
        String error = Validador.validarCliente( cliente.getNombre( ), cliente.getTelefono( ), cliente.getCorreo( ) );
        if( error != null )
        {
            throw new IllegalArgumentException( error );
        }
        cliente.setNombre( cliente.getNombre( ).trim( ) );
        cliente.setTelefono( cliente.getTelefono( ).trim( ) );
        cliente.setCorreo( cliente.getCorreo( ).trim( ).toLowerCase( ) );
    }

    @Override
    public Cliente findByTelefono( String telefono )
    {
        return dao.findByTelefono( telefono );
    }

    @Override
    public Cliente findByUsuarioId( Long idUsuario )
    {
        return dao.findByUsuarioId( idUsuario );
    }

    @Override
    public List<Cliente> findSinCuenta( Long idUsuarioActual )
    {
        return dao.findSinCuenta( idUsuarioActual );
    }

    @Override
    public List<Cliente> buscar( String texto )
    {
        return dao.buscar( texto == null ? "" : texto );
    }
}