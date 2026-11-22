package org.TecNova.controller;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/** RF-02: cierre de sesión. */
@WebServlet( "/LogoutServlet" )
public class LogoutServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        HttpSession sesion = req.getSession( false );
        if( sesion != null )
        {
            sesion.invalidate( );
        }
        ir( req, resp, "Login.jsp" );
    }

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        doGet( req, resp );
    }
}
