package org.TecNova.dao.impl;

import org.TecNova.dao.RolDao;
import org.TecNova.model.Rol;

public class RolDaoImpl extends BaseDaoImpl<Rol> implements RolDao
{
    public RolDaoImpl( )
    {
        super( Rol.class );
    }

    @Override
    protected String orden( )
    {
        return " order by id";
    }
}
