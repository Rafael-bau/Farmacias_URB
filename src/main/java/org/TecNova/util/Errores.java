package org.TecNova.util;

import java.sql.SQLException;

/** Convierte excepciones de Hibernate/MySQL en mensajes entendibles para el usuario. */
public final class Errores
{
    private Errores( )
    {
    }

    public static String mensaje( Throwable e )
    {
        Throwable t = e;
        while( t != null )
        {
            if( t instanceof SQLException )
            {
                SQLException se = (SQLException) t;
                if( "45000".equals( se.getSQLState( ) ) )          // mensajes de los triggers (SIGNAL)
                {
                    return se.getMessage( );
                }
                switch( se.getErrorCode( ) )
                {
                    case 1062: return "Ya existe un registro con esos datos.";
                    case 1451: return "No se puede eliminar: tiene registros relacionados.";
                    case 1452: return "Uno de los datos seleccionados ya no existe.";
                    case 3819: return "Algún valor está fuera del rango permitido.";
                    default: break;
                }
            }
            if( t instanceof IllegalArgumentException || t instanceof IllegalStateException )
            {
                return t.getMessage( );
            }
            t = t.getCause( );
        }
        e.printStackTrace( );
        return "No se pudo completar la operación.";
    }
}
