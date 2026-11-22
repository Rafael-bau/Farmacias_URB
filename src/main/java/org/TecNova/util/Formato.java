package org.TecNova.util;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

/** Ayudas para las páginas JSP: escape HTML, formato de fechas y dinero, token CSRF. */
public final class Formato
{
    private static final DateTimeFormatter FECHA = DateTimeFormatter.ofPattern( "dd/MM/yyyy" );
    private static final DateTimeFormatter FECHA_HORA = DateTimeFormatter.ofPattern( "dd/MM/yyyy HH:mm" );

    private Formato( )
    {
    }

    /** Escapa texto para imprimirlo de forma segura dentro de HTML (evita XSS). */
    public static String esc( Object o )
    {
        if( o == null )
        {
            return "";
        }
        String s = o.toString( );
        StringBuilder sb = new StringBuilder( s.length( ) + 16 );
        for( char c : s.toCharArray( ) )
        {
            switch( c )
            {
                case '&': sb.append( "&amp;" ); break;
                case '<': sb.append( "&lt;" ); break;
                case '>': sb.append( "&gt;" ); break;
                case '"': sb.append( "&quot;" ); break;
                case '\'': sb.append( "&#39;" ); break;
                default: sb.append( c );
            }
        }
        return sb.toString( );
    }

    public static String dinero( Object o )
    {
        if( o == null )
        {
            return "$0.00";
        }
        return String.format( Locale.US, "$%,.2f", new BigDecimal( o.toString( ) ) );
    }

    public static String fecha( Object o )
    {
        if( o == null )
        {
            return "";
        }
        if( o instanceof LocalDate )
        {
            return ( (LocalDate) o ).format( FECHA );
        }
        if( o instanceof LocalDateTime )
        {
            return ( (LocalDateTime) o ).format( FECHA_HORA );
        }
        if( o instanceof java.sql.Timestamp )
        {
            return ( (java.sql.Timestamp) o ).toLocalDateTime( ).format( FECHA_HORA );
        }
        if( o instanceof java.sql.Date )
        {
            return ( (java.sql.Date) o ).toLocalDate( ).format( FECHA );
        }
        return o.toString( );
    }

    /** Convierte cualquier número (Integer, Long, BigDecimal, BigInteger...) a int. */
    public static int entero( Object o )
    {
        return o == null ? 0 : ( (Number) o ).intValue( );
    }

    /** Devuelve "activo" si el elemento del menú es el de la página actual. */
    public static String activo( String actual, String item )
    {
        return item.equals( actual ) ? "activo" : "";
    }

    /** Campo oculto con el token CSRF; va dentro de todo formulario POST. */
    public static String csrf( HttpSession sesion )
    {
        Object token = sesion.getAttribute( "csrf" );
        return "<input type=\"hidden\" name=\"_csrf\" value=\"" + esc( token ) + "\">";
    }
}
