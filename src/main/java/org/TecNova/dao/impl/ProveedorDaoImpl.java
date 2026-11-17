package org.TecNova.dao.impl;

import org.TecNova.dao.ProveedorDao;
import org.TecNova.model.Proveedor;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;

import java.util.List;

public class ProveedorDaoImpl extends BaseDaoImpl<Proveedor> implements ProveedorDao
{
    public ProveedorDaoImpl( )
    {
        super( Proveedor.class );
    }

    @Override
    protected String orden( )
    {
        return " order by estatus desc, nombre";
    }

    @Override
    public List<Proveedor> findActivos( )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Proveedor p where p.estatus = true order by p.nombre", Proveedor.class )
                    .list( );
        }
    }
}
