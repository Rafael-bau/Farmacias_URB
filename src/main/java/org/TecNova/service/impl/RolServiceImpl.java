package org.TecNova.service.impl;

import org.TecNova.dao.RolDao;
import org.TecNova.dao.impl.RolDaoImpl;
import org.TecNova.model.Rol;
import org.TecNova.service.RolService;

import java.util.List;

public class RolServiceImpl implements RolService
{
    private final RolDao dao = new RolDaoImpl( );

    @Override
    public List<Rol> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Rol findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Rol save( Rol entity )
    {
        validar( entity );
        return dao.save( entity );
    }

    @Override
    public void deleteById( Long id )
    {
        dao.deleteById( id );
    }

    @Override
    public Rol update( Rol entity )
    {
        validar( entity );
        return dao.update( entity );
    }

    private void validar( Rol entity )
    {
        // sin reglas adicionales
    }
}

