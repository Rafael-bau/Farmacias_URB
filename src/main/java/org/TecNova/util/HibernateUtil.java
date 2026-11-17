package org.TecNova.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Crea una sola SessionFactory para toda la aplicación (lee hibernate.cfg.xml).
 * Las variables de entorno DB_URL, DB_USER y DB_PASSWORD, si existen, tienen prioridad.
 */
public class HibernateUtil
{
    private static final SessionFactory SESSION_FACTORY = build( );

    private HibernateUtil( )
    {
    }

    private static SessionFactory build( )
    {
        try
        {
            Configuration configuration = new Configuration( ).configure( "hibernate.cfg.xml" );
            sobrescribir( configuration, "hibernate.connection.url", "jdbc:mysql://127.0.0.1:3306/farmacias_urb?useSSL=false&amp;allowPublicKeyRetrieval=true&amp;serverTimezone=America/Mexico_City&amp;characterEncoding=UTF-8" );
            sobrescribir( configuration, "hibernate.connection.username", "root" );
            sobrescribir( configuration, "hibernate.connection.password", "1234" );
            return configuration.buildSessionFactory( );
        }
        catch( Throwable e )
        {
            e.printStackTrace( );
            throw new ExceptionInInitializerError( e );
        }
    }

    private static void sobrescribir( Configuration configuration, String propiedad, String variable )
    {
        String valor = System.getenv( variable );
        if( valor != null && !valor.isBlank( ) )
        {
            configuration.setProperty( propiedad, valor );
        }
    }

    public static SessionFactory getSessionFactory( )
    {
        return SESSION_FACTORY;
    }

    public static void shutdown( )
    {
        SESSION_FACTORY.close( );
    }
}
