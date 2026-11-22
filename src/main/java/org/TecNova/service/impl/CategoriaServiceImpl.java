package org.TecNova.service.impl;

import org.TecNova.dao.CategoriaDao;
import org.TecNova.dao.impl.CategoriaDaoImpl;
import org.TecNova.model.Categoria;
import org.TecNova.service.CategoriaService;

import java.util.List;

public class CategoriaServiceImpl implements CategoriaService
{
    private final CategoriaDao dao = new CategoriaDaoImpl( );

    @Override
    public List<Categoria> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Categoria findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Categoria save( Categoria entity )
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
    public Categoria update( Categoria entity )
    {
        validar( entity );
        return dao.update( entity );
    }

    private void validar( Categoria entity )
    {
        if( entity.getNombre( ) == null || entity.getNombre( ).isBlank( ) || entity.getNombre( ).length( ) > 50 )
        {
            throw new IllegalArgumentException( "El nombre de la categoría es obligatorio (máximo 50 caracteres)." );
        }
        entity.setNombre( entity.getNombre( ).trim( ) );
    }
}
