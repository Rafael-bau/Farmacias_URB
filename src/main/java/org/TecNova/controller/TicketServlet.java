package org.TecNova.controller;

import org.TecNova.model.Usuario;
import org.TecNova.model.Venta;
import org.TecNova.service.VentaService;
import org.TecNova.service.impl.VentaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Ticket de venta en PDF. Admin: todos · Cajero: los suyos · Cliente: los suyos. */
@WebServlet( "/TicketServlet" )
public class TicketServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final VentaService service = new VentaServiceImpl( );

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        Long id = id( req.getParameter( "id" ) );
        Venta venta = id == null ? null : service.findById( id );
        if( venta == null )
        {
            resp.sendError( HttpServletResponse.SC_NOT_FOUND, "La venta no existe." );
            return;
        }
        Usuario actual = usuario( req );
        String rol = actual.getRol( ).getNombre( );
        Long clienteId = (Long) req.getSession( ).getAttribute( "clienteId" );
        boolean permitido = "Administrador".equals( rol )
                || ( "Cajero".equals( rol ) && venta.getUsuario( ).getId( ).equals( actual.getId( ) ) )
                || ( "Cliente".equals( rol ) && clienteId != null && venta.getCliente( ) != null
                     && venta.getCliente( ).getId( ).equals( clienteId ) );
        if( !permitido )
        {
            resp.sendError( HttpServletResponse.SC_FORBIDDEN, "No tienes permiso para ver este ticket." );
            return;
        }
        byte[] pdf = service.ticketPdf( id );
        resp.setContentType( "application/pdf" );
        resp.setHeader( "Content-Disposition", "inline; filename=\"ticket-" + venta.getFolioTicket( ) + ".pdf\"" );
        resp.setContentLength( pdf.length );
        resp.getOutputStream( ).write( pdf );
    }
}
