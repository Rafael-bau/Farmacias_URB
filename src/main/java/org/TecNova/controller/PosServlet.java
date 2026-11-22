package org.TecNova.controller;

import org.TecNova.model.ItemCarrito;
import org.TecNova.model.Venta;
import org.TecNova.service.ReporteService;
import org.TecNova.service.VentaService;
import org.TecNova.service.impl.ReporteServiceImpl;
import org.TecNova.service.impl.VentaServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Punto de venta: el carrito vive en la sesión; "cobrar" registra la venta en la base de datos. */
@WebServlet( "/PosServlet" )
public class PosServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final ReporteService reporteService = new ReporteServiceImpl( );
    private final VentaService ventaService = new VentaServiceImpl( );

    @SuppressWarnings( "unchecked" )
    private List<ItemCarrito> carrito( HttpSession sesion )
    {
        List<ItemCarrito> carrito = (List<ItemCarrito>) sesion.getAttribute( "carrito" );
        if( carrito == null )
        {
            carrito = new ArrayList<>( );
            sesion.setAttribute( "carrito", carrito );
        }
        return carrito;
    }

    private ItemCarrito buscar( List<ItemCarrito> carrito, Long idLote )
    {
        for( ItemCarrito item : carrito )
        {
            if( item.getIdLote( ).equals( idLote ) )
            {
                return item;
            }
        }
        return null;
    }

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        ir( req, resp, "Pos.jsp" );
    }

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        HttpSession sesion = req.getSession( );
        List<ItemCarrito> carrito = carrito( sesion );
        String q = texto( req, "q" );
        try
        {
            String accion = texto( req, "accion" );
            Long idLote = id( req.getParameter( "idLote" ) );
            switch( accion )
            {
                case "agregar":
                {
                    int cantidad = entero( req, "cantidad" );
                    if( idLote == null || cantidad <= 0 )
                    {
                        throw new IllegalArgumentException( "La cantidad debe ser mayor a 0." );
                    }
                    Map<String, Object> lote = reporteService.lotePorId( idLote );
                    if( lote == null )
                    {
                        throw new IllegalArgumentException( "El lote ya no está disponible." );
                    }
                    int stock = ( (Number) lote.get( "stock_actual" ) ).intValue( );
                    ItemCarrito existente = buscar( carrito, idLote );
                    int enCarrito = existente == null ? 0 : existente.getCantidad( );
                    if( enCarrito + cantidad > stock )
                    {
                        throw new IllegalArgumentException( "Solo hay " + stock + " unidades disponibles en ese lote." );
                    }
                    if( existente != null )
                    {
                        existente.setCantidad( enCarrito + cantidad );
                    }
                    else
                    {
                        carrito.add( new ItemCarrito( idLote, (String) lote.get( "nombre_comercial" ),
                                (String) lote.get( "num_lote" ), (BigDecimal) lote.get( "precio_venta" ), cantidad, stock ) );
                    }
                    break;
                }
                case "cantidad":
                {
                    ItemCarrito item = idLote == null ? null : buscar( carrito, idLote );
                    if( item != null )
                    {
                        int cantidad = entero( req, "cantidad" );
                        if( cantidad <= 0 )
                        {
                            carrito.remove( item );
                        }
                        else if( cantidad > item.getStock( ) )
                        {
                            throw new IllegalArgumentException( "Solo hay " + item.getStock( ) + " unidades en ese lote." );
                        }
                        else
                        {
                            item.setCantidad( cantidad );
                        }
                    }
                    break;
                }
                case "quitar":
                {
                    ItemCarrito item = idLote == null ? null : buscar( carrito, idLote );
                    if( item != null )
                    {
                        carrito.remove( item );
                    }
                    break;
                }
                case "vaciar":
                    carrito.clear( );
                    break;
                case "cobrar":
                {
                    Venta venta = ventaService.registrar( usuario( req ), texto( req, "telefonoCliente" ),
                            texto( req, "metodoPago" ), carrito );
                    carrito.clear( );
                    sesion.setAttribute( "ultimaVenta", venta );
                    break;
                }
                default:
                    break;
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Pos.jsp" + ( q.isEmpty( ) ? "" : "?q=" + URLEncoder.encode( q, StandardCharsets.UTF_8 ) ) );
    }
}
