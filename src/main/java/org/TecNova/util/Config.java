package org.TecNova.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/** Lee config.properties (IVA, opciones de arranque). Una variable de entorno IVA_TASA, etc. tiene prioridad. */
public final class Config
{
    private static final Properties PROPS = new Properties( );

    static
    {
        try( InputStream in = Config.class.getClassLoader( ).getResourceAsStream( "config.properties" ) )
        {
            if( in != null )
            {
                PROPS.load( new InputStreamReader( in, StandardCharsets.UTF_8 ) );
            }
        }
        catch( IOException e )
        {
            e.printStackTrace( );
        }
    }

    private Config( )
    {
    }

    public static String get( String clave, String porDefecto )
    {
        String env = System.getenv( clave.toUpperCase( ).replace( '.', '_' ) );
        if( env != null && !env.isBlank( ) )
        {
            return env;
        }
        return PROPS.getProperty( clave, porDefecto );
    }
}
