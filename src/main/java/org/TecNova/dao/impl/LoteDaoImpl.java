package org.TecNova.dao.impl;

import org.TecNova.dao.LoteDao;
import org.TecNova.model.Lote;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;

import java.util.List;

public class LoteDaoImpl extends BaseDaoImpl<Lote> implements LoteDao
{
    public LoteDaoImpl( )
    {
        super( Lote.class );
    }

    @Override
    protected String orden( )
    {
        return " order by fechaCaducidad";
    }

    @Override
    public List<Lote> findConStock( )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Lote l where l.stockActual > 0 "
                    + "order by l.medicamento.nombreComercial, l.fechaCaducidad", Lote.class ).list( );
        }
    }
}
