package org.TecNova.dao.impl;

import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;
import java.util.function.Function;

/** CRUD genérico con Hibernate: cada operación abre su sesión y confirma (commit) o revierte (rollback). */
public abstract class BaseDaoImpl<T>
{
    private final Class<T> clase;

    protected BaseDaoImpl( Class<T> clase )
    {
        this.clase = clase;
    }

    /** Cláusula "order by" opcional para findAll( ). */
    protected String orden( )
    {
        return "";
    }

    public List<T> findAll( )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from " + clase.getSimpleName( ) + orden( ), clase ).list( );
        }
    }

    public T findById( Long id )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.get( clase, id );
        }
    }

    public T save( T entity )
    {
        return ejecutar( session ->
        {
            session.save( entity );
            return entity;
        } );
    }

    public void deleteById( Long id )
    {
        ejecutar( session ->
        {
            T entity = session.get( clase, id );
            if( entity != null )
            {
                session.delete( entity );
            }
            return null;
        } );
    }

    @SuppressWarnings( "unchecked" )
    public T update( T entity )
    {
        return ejecutar( session -> (T) session.merge( entity ) );
    }

    /** Ejecuta una acción dentro de una transacción. Si algo falla hace rollback y relanza la excepción. */
    protected <R> R ejecutar( Function<Session, R> accion )
    {
        Transaction tx = null;
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            tx = session.beginTransaction( );
            R resultado = accion.apply( session );
            tx.commit( );
            return resultado;
        }
        catch( RuntimeException e )
        {
            if( tx != null && tx.isActive( ) )
            {
                tx.rollback( );
            }
            throw e;
        }
    }
}
