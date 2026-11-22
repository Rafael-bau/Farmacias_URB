package org.TecNova.listener;

import org.TecNova.service.impl.UsuarioServiceImpl;
import org.TecNova.util.Config;
import org.TecNova.util.HibernateUtil;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Arranque y cierre de la aplicación.
 * Si app.inicializar.passwords=true (config.properties) reemplaza los hashes de prueba del script SQL
 * por Admin123 / Cajero123 / Cliente123. Solo desarrollo.
 */
@WebListener
public class InicioApp implements ServletContextListener
{
    @Override
    public void contextInitialized( ServletContextEvent evento )
    {
        if( "true".equalsIgnoreCase( Config.get( "app.inicializar.passwords", "false" ) ) )
        {
            try
            {
                int n = new UsuarioServiceImpl( ).inicializarPasswordsDePrueba( );
                if( n > 0 )
                {
                    System.out.println( "[Farmacias URB] Contraseñas de prueba asignadas a " + n + " usuario(s)." );
                }
            }
            catch( Throwable e )
            {
                System.err.println( "[Farmacias URB] No se pudo conectar a la base de datos: " + e );
            }
        }
    }

    @Override
    public void contextDestroyed( ServletContextEvent evento )
    {
        try
        {
            HibernateUtil.shutdown( );
        }
        catch( Throwable e )
        {
            // la SessionFactory nunca llegó a crearse
        }
    }
}
