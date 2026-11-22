package org.TecNova.controller;

import org.TecNova.model.Usuario;
import org.TecNova.util.Errores;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;

/** Utilidades comunes de los Servlets: usuario en sesión, mensajes flash, conversión de parámetros y redirecciones. */
public abstract class BaseServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    protected Usuario usuario( HttpServletRequest req )
    {
        return (Usuario) req.getSession( ).getAttribute( "usuario" );
    }

    protected void ok( HttpServletRequest req, String mensaje )
    {
        req.getSession( ).setAttribute( "flashMensaje", mensaje );
        req.getSession( ).setAttribute( "flashTipo", "success" );
    }

    protected void error( HttpServletRequest req, Exception e )
    {
        req.getSession( ).setAttribute( "flashMensaje", Errores.mensaje( e ) );
        req.getSession( ).setAttribute( "flashTipo", "danger" );
    }

    /** Id numérico o null si viene vacío / inválido. */
    protected Long id( String valor )
    {
        return valor != null && valor.trim( ).matches( "[0-9]+" ) ? Long.valueOf( valor.trim( ) ) : null;
    }

    protected String texto( HttpServletRequest req, String nombre )
    {
        String v = req.getParameter( nombre );
        return v == null ? "" : v.trim( );
    }

    protected int entero( HttpServletRequest req, String nombre )
    {
        try
        {
            return Integer.parseInt( texto( req, nombre ) );
        }
        catch( NumberFormatException e )
        {
            throw new IllegalArgumentException( "Número inválido en el campo «" + nombre + "»." );
        }
    }

    protected BigDecimal decimal( HttpServletRequest req, String nombre )
    {
        try
        {
            return new BigDecimal( texto( req, nombre ) );
        }
        catch( NumberFormatException e )
        {
            throw new IllegalArgumentException( "Importe inválido en el campo «" + nombre + "»." );
        }
    }

    protected void ir( HttpServletRequest req, HttpServletResponse resp, String destino ) throws IOException
    {
        resp.sendRedirect( req.getContextPath( ) + "/" + destino );
    }

    /** Los Servlets solo atienden POST; un GET directo regresa al inicio. */
    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        ir( req, resp, "index.jsp" );
    }
}
