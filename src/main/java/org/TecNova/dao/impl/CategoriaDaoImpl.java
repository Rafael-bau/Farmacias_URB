package org.TecNova.dao.impl;

import org.TecNova.dao.CategoriaDao;
import org.TecNova.model.Categoria;

public class CategoriaDaoImpl extends BaseDaoImpl<Categoria> implements CategoriaDao
{
    public CategoriaDaoImpl( )
    {
        super( Categoria.class );
    }

    @Override
    protected String orden( )
    {
        return " order by nombre";
    }
}
