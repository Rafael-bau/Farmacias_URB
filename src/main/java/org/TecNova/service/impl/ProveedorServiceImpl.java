package org.TecNova.service.impl;

import org.TecNova.dao.ProveedorDao;
import org.TecNova.dao.impl.ProveedorDaoImpl;
import org.TecNova.model.Proveedor;
import org.TecNova.service.ProveedorService;
import org.TecNova.util.Validador;

import java.util.List;

public class ProveedorServiceImpl implements ProveedorService
{
    private final ProveedorDao dao = new ProveedorDaoImpl( );

    @Override
    public List<Proveedor> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Proveedor findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Proveedor save( Proveedor entity )
    {
        validar( entity );
        return dao.save( entity );
    }

    @Override
    public void deleteById( Long id )
    {
        Proveedor proveedor = dao.findById( id );          // baja lógica
        if( proveedor != null )
        {
            proveedor.setEstatus( false );
            dao.update( proveedor );
        }
    }

    @Override
    public Proveedor update( Proveedor entity )
    {
        validar( entity );
        return dao.update( entity );
    }

    private void validar( Proveedor entity )
    {
        if( entity.getNombre( ) == null || entity.getNombre( ).isBlank( ) || entity.getNombre( ).length( ) > 100 )
        {
            throw new IllegalArgumentException( "El nombre del proveedor es obligatorio (máximo 100 caracteres)." );
        }
        if( !blanco( entity.getTelefono( ) ) && !Validador.telefono( entity.getTelefono( ) ) )
        {
            throw new IllegalArgumentException( "Teléfono inválido: deben ser 10 dígitos." );
        }
        if( !blanco( entity.getCorreo( ) ) && !Validador.correo( entity.getCorreo( ) ) )
        {
            throw new IllegalArgumentException( "Correo electrónico inválido." );
        }
        if( entity.getDireccion( ) != null && entity.getDireccion( ).length( ) > 200 )
        {
            throw new IllegalArgumentException( "La dirección es demasiado larga." );
        }
        entity.setNombre( entity.getNombre( ).trim( ) );
        entity.setTelefono( blanco( entity.getTelefono( ) ) ? null : entity.getTelefono( ).trim( ) );
        entity.setCorreo( blanco( entity.getCorreo( ) ) ? null : entity.getCorreo( ).trim( ).toLowerCase( ) );
        entity.setDireccion( blanco( entity.getDireccion( ) ) ? null : entity.getDireccion( ).trim( ) );
        if( entity.getEstatus( ) == null )
        {
            entity.setEstatus( true );
        }
    }

    private boolean blanco( String s )
    {
        return s == null || s.isBlank( );
    }

    @Override
    public List<Proveedor> findActivos( )
    {
        return dao.findActivos( );
    }
}