package org.TecNova.dao.impl;

import org.TecNova.dao.MedicamentoDao;
import org.TecNova.model.Medicamento;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;

import java.util.List;

public class MedicamentoDaoImpl extends BaseDaoImpl<Medicamento> implements MedicamentoDao
{
    public MedicamentoDaoImpl( )
    {
        super( Medicamento.class );
    }

    @Override
    protected String orden( )
    {
        return " order by estatus desc, nombreComercial";
    }

    @Override
    public List<Medicamento> findActivos( )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Medicamento m where m.estatus = true order by m.nombreComercial",
                    Medicamento.class ).list( );
        }
    }

    @Override
    public Medicamento findByCodigoBarras( String codigoBarras )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Medicamento m where m.codigoBarras = :codigo", Medicamento.class )
                    .setParameter( "codigo", codigoBarras ).uniqueResult( );
        }
    }
}
