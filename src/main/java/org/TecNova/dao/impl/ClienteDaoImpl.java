package org.TecNova.dao.impl;

import org.TecNova.dao.ClienteDao;
import org.TecNova.model.Cliente;
import org.TecNova.model.Usuario;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;

import java.util.List;

public class ClienteDaoImpl extends BaseDaoImpl<Cliente> implements ClienteDao
{
    public ClienteDaoImpl( )
    {
        super( Cliente.class );
    }

    @Override
    protected String orden( )
    {
        return " order by nombre";
    }

    @Override
    public Cliente findByTelefono( String telefono )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Cliente c where c.telefono = :telefono", Cliente.class )
                    .setParameter( "telefono", telefono ).uniqueResult( );
        }
    }

    @Override
    public Cliente findByUsuarioId( Long idUsuario )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Cliente c where c.usuario.id = :id", Cliente.class )
                    .setParameter( "id", idUsuario ).uniqueResult( );
        }
    }

    /** Clientes sin cuenta de acceso (más el que ya tiene la cuenta indicada, para poder editar). */
    @Override
    public List<Cliente> findSinCuenta( Long idUsuarioActual )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery(
                    "from Cliente c where c.usuario is null or c.usuario.id = :u order by c.nombre", Cliente.class )
                    .setParameter( "u", idUsuarioActual == null ? -1L : idUsuarioActual ).list( );
        }
    }

    @Override
    public List<Cliente> buscar( String texto )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery(
                    "from Cliente c where c.nombre like :t or c.telefono like :t or c.correo like :t order by c.nombre",
                    Cliente.class )
                    .setParameter( "t", "%" + texto + "%" ).setMaxResults( 300 ).list( );
        }
    }

    /** Liga (o desliga si idCliente es null) la cuenta de usuario con un cliente. */
    @Override
    public void vincularUsuario( Long idCliente, Long idUsuario )
    {
        ejecutar( session ->
        {
            session.createQuery( "update Cliente c set c.usuario = null where c.usuario.id = :u" )
                    .setParameter( "u", idUsuario ).executeUpdate( );
            if( idCliente != null )
            {
                Cliente cliente = session.get( Cliente.class, idCliente );
                if( cliente == null )
                {
                    throw new IllegalArgumentException( "El cliente indicado no existe." );
                }
                if( cliente.getUsuario( ) != null && !cliente.getUsuario( ).getId( ).equals( idUsuario ) )
                {
                    throw new IllegalArgumentException( "Ese cliente ya tiene una cuenta de acceso asignada." );
                }
                cliente.setUsuario( session.get( Usuario.class, idUsuario ) );
            }
            return null;
        } );
    }
}
