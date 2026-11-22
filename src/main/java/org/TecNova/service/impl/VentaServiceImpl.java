package org.TecNova.service.impl;

import org.TecNova.dao.VentaDao;
import org.TecNova.dao.impl.ClienteDaoImpl;
import org.TecNova.dao.impl.VentaDaoImpl;
import org.TecNova.dao.ClienteDao;
import org.TecNova.model.Cliente;
import org.TecNova.model.DetalleVenta;
import org.TecNova.model.ItemCarrito;
import org.TecNova.model.Usuario;
import org.TecNova.model.Venta;
import org.TecNova.service.VentaService;
import org.TecNova.util.Config;
import org.TecNova.util.TicketPdf;
import org.TecNova.util.Validador;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class VentaServiceImpl implements VentaService
{
    private static final Set<String> METODOS = Set.of( "EFECTIVO", "TARJETA", "TRANSFERENCIA" );

    private final VentaDao dao = new VentaDaoImpl( );
    private final ClienteDao clienteDao = new ClienteDaoImpl( );

    @Override
    public List<Venta> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Venta findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Venta save( Venta venta )
    {
        return dao.save( venta );
    }

    @Override
    public void deleteById( Long id )
    {
        throw new IllegalStateException( "Las ventas no se borran: cancélalas para conservar el historial." );
    }

    @Override
    public Venta update( Venta venta )
    {
        return dao.update( venta );
    }

    /** RF-06 / RF-07: cobra el carrito en una transacción (commit si todo sale bien, rollback si falla). */
    @Override
    public Venta registrar( Usuario cajero, String telefonoCliente, String metodoPago, List<ItemCarrito> items )
    {
        if( items == null || items.isEmpty( ) )
        {
            throw new IllegalArgumentException( "El carrito está vacío." );
        }
        if( !METODOS.contains( metodoPago ) )
        {
            throw new IllegalArgumentException( "Selecciona un método de pago válido." );
        }
        Cliente cliente = null;
        if( telefonoCliente != null && !telefonoCliente.isBlank( ) )
        {
            if( !Validador.telefono( telefonoCliente.trim( ) ) )
            {
                throw new IllegalArgumentException( "Teléfono del cliente inválido: deben ser 10 dígitos." );
            }
            cliente = clienteDao.findByTelefono( telefonoCliente.trim( ) );
            if( cliente == null )
            {
                throw new IllegalArgumentException( "No existe un cliente con ese teléfono. Regístralo en Catálogos › Clientes." );
            }
        }
        BigDecimal tasaIva = new BigDecimal( Config.get( "iva.tasa", "0.00" ) );
        return dao.registrar( cajero, cliente, metodoPago, tasaIva, items );
    }

    @Override
    public void cancelar( Long idVenta )
    {
        dao.cancelar( idVenta );
    }

    /** El administrador ve todas las ventas; el cajero solo las suyas. */
    @Override
    public List<Venta> findHistorial( Usuario usuario )
    {
        return dao.findHistorial( usuario.getRol( ).getNombre( ).equals( "Administrador" ) ? null : usuario.getId( ) );
    }

    @Override
    public List<DetalleVenta> findDetalle( Long idVenta )
    {
        return dao.findDetalle( idVenta );
    }

    /** Compras de un cliente con un resumen de artículos (portal del cliente). */
    @Override
    public List<Map<String, Object>> comprasDeCliente( Long idCliente )
    {
        List<Map<String, Object>> resultado = new ArrayList<>( );
        for( Venta venta : dao.findByCliente( idCliente ) )
        {
            StringBuilder articulos = new StringBuilder( );
            for( DetalleVenta d : dao.findDetalle( venta.getId( ) ) )
            {
                if( articulos.length( ) > 0 )
                {
                    articulos.append( ", " );
                }
                articulos.append( d.getCantidad( ) ).append( " x " ).append( d.getLote( ).getMedicamento( ).getNombreComercial( ) );
            }
            Map<String, Object> fila = new LinkedHashMap<>( );
            fila.put( "venta", venta );
            fila.put( "articulos", articulos.toString( ) );
            resultado.add( fila );
        }
        return resultado;
    }

    /** RF-08: ticket digital en PDF. */
    @Override
    public byte[] ticketPdf( Long idVenta )
    {
        Venta venta = dao.findById( idVenta );
        if( venta == null )
        {
            throw new IllegalArgumentException( "La venta no existe." );
        }
        Map<String, Object> v = new LinkedHashMap<>( );
        v.put( "folio_ticket", venta.getFolioTicket( ) );
        v.put( "fecha_venta", venta.getFechaVenta( ) == null ? null : Timestamp.valueOf( venta.getFechaVenta( ) ) );
        v.put( "cajero", venta.getUsuario( ).getNombre( ) );
        v.put( "cliente", venta.getCliente( ) == null ? null : venta.getCliente( ).getNombre( ) );
        v.put( "id_cliente", venta.getCliente( ) == null ? null : venta.getCliente( ).getId( ) );
        v.put( "subtotal", venta.getSubtotal( ) );
        v.put( "iva", venta.getIva( ) );
        v.put( "total", venta.getTotal( ) );
        v.put( "metodo_pago", venta.getMetodoPago( ) );
        v.put( "puntos_generados", venta.getPuntosGenerados( ) );
        v.put( "estatus_venta", venta.getEstatusVenta( ) );
        List<Map<String, Object>> detalle = new ArrayList<>( );
        for( DetalleVenta d : dao.findDetalle( idVenta ) )
        {
            Map<String, Object> fila = new LinkedHashMap<>( );
            fila.put( "nombre_comercial", d.getLote( ).getMedicamento( ).getNombreComercial( ) );
            fila.put( "cantidad", d.getCantidad( ) );
            fila.put( "precio_unitario", d.getPrecioUnitario( ) );
            fila.put( "subtotal_linea", d.getSubtotalLinea( ) );
            detalle.add( fila );
        }
        return TicketPdf.generar( v, detalle );
    }
}

