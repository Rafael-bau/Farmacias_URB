package org.TecNova.controller;

import org.TecNova.service.EntradaService;
import org.TecNova.service.impl.EntradaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/** Entradas de mercancía: crean un lote nuevo o suman al existente. */
@WebServlet( "/EntradaServlet" )
public class EntradaServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final EntradaService service = new EntradaServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            LocalDate caducidad;
            try
            {
                caducidad = LocalDate.parse( texto( req, "fechaCaducidad" ) );
            }
            catch( DateTimeParseException e )
            {
                throw new IllegalArgumentException( "La fecha de caducidad no es válida." );
            }
            service.registrar( id( req.getParameter( "proveedorId" ) ), id( req.getParameter( "medicamentoId" ) ),
                    texto( req, "numLote" ), caducidad, entero( req, "cantidad" ),
                    texto( req, "costoUnitario" ).isEmpty( ) ? null : decimal( req, "costoUnitario" ), usuario( req ) );
            ok( req, "Entrada registrada: el stock del lote se actualizó." );
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Entradas.jsp" );
    }
}
