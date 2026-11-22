package org.TecNova.service.impl;


import org.TecNova.dao.LoteDao;
import org.TecNova.dao.impl.LoteDaoImpl;
import org.TecNova.model.Lote;
import org.TecNova.service.LoteService;

import java.util.List;

public class LoteServiceImpl implements LoteService
{
    private final LoteDao dao = new LoteDaoImpl( );

    @Override
    public List<Lote> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Lote findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Lote save( Lote entity )
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
    public Lote update( Lote entity )
    {
        validar( entity );
        return dao.update( entity );
    }

    private void validar( Lote entity )
    {
        // sin reglas adicionales
    }

    @Override
    public List<Lote> findConStock( )
    {
        return dao.findConStock( );
    }
}

