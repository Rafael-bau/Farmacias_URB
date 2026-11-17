package org.TecNova.dao.impl;

import org.TecNova.dao.UsuarioDao;
import org.TecNova.model.Usuario;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;

public class UsuarioDaoImpl extends BaseDaoImpl<Usuario> implements UsuarioDao
{
    public UsuarioDaoImpl( )
    {
        super( Usuario.class );
    }

    @Override
    protected String orden( )
    {
        return " order by estatus desc, nombre";
    }

    @Override
    public Usuario findByCorreo( String correo )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Usuario u where u.correo = :correo", Usuario.class )
                    .setParameter( "correo", correo ).uniqueResult( );
        }
    }
}
