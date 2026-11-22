package org.TecNova.dao.impl;

import org.TecNova.dao.VentaDao;
import org.TecNova.model.Cliente;
import org.TecNova.model.DetalleVenta;
import org.TecNova.model.ItemCarrito;
import org.TecNova.model.Lote;
import org.TecNova.model.Medicamento;
import org.TecNova.model.Usuario;
import org.TecNova.model.Venta;
import org.TecNova.util.HibernateUtil;
import org.hibernate.LockMode;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class VentaDaoImpl extends BaseDaoImpl<Venta> implements VentaDao
{
    public VentaDaoImpl( )
    {
        super( Venta.class );
    }

    @Override
    protected String orden( )
    {
        return " order by fechaVenta desc";
    }

    /**
     * Registra la venta en UNA transacción (RF-07): si algo falla (stock insuficiente, lote caducado...)
     * se hace rollback y no se guarda nada. El descuento de stock y la suma de puntos los hacen los
     * triggers de la base de datos al insertar el detalle y la venta.
     */
    @Override
    public Venta registrar( Usuario cajero, Cliente cliente, String metodoPago, BigDecimal tasaIva,
                            List<ItemCarrito> items )
    {
        return ejecutar( session ->
        {
            if( items == null || items.isEmpty( ) )
            {
                throw new IllegalArgumentException( "La venta no tiene productos." );
            }
            BigDecimal subtotal = BigDecimal.ZERO;
            List<DetalleVenta> detalles = new ArrayList<>( );
            for( ItemCarrito item : items )
            {
                Lote lote = session.get( Lote.class, item.getIdLote( ), LockMode.PESSIMISTIC_WRITE );
                if( lote == null )
                {
                    throw new IllegalArgumentException( "Uno de los lotes ya no existe." );
                }
                Medicamento medicamento = lote.getMedicamento( );
                if( !Boolean.TRUE.equals( medicamento.getEstatus( ) ) )
                {
                    throw new IllegalArgumentException( medicamento.getNombreComercial( ) + " está dado de baja." );
                }
                if( lote.getFechaCaducidad( ).isBefore( LocalDate.now( ) ) )
                {
                    throw new IllegalArgumentException( "Lote caducado: " + medicamento.getNombreComercial( ) + "." );
                }
                if( lote.getStockActual( ) < item.getCantidad( ) )
                {
                    throw new IllegalArgumentException( "Stock insuficiente de " + medicamento.getNombreComercial( )
                            + " (disponibles: " + lote.getStockActual( ) + ")." );
                }
                DetalleVenta detalle = new DetalleVenta( );
                detalle.setLote( lote );
                detalle.setCantidad( item.getCantidad( ) );
                detalle.setPrecioUnitario( medicamento.getPrecioVenta( ) );
                detalle.setSubtotalLinea( medicamento.getPrecioVenta( ).multiply( BigDecimal.valueOf( item.getCantidad( ) ) ) );
                subtotal = subtotal.add( detalle.getSubtotalLinea( ) );
                detalles.add( detalle );
            }
            subtotal = subtotal.setScale( 2, RoundingMode.HALF_UP );
            BigDecimal iva = subtotal.multiply( tasaIva ).setScale( 2, RoundingMode.HALF_UP );
            BigDecimal total = subtotal.add( iva );

            Venta venta = new Venta( );
            venta.setFolioTicket( UUID.randomUUID( ).toString( ).replace( "-", "" ).substring( 0, 20 ) );
            venta.setSubtotal( subtotal );
            venta.setIva( iva );
            venta.setTotal( total );
            venta.setMetodoPago( metodoPago );
            venta.setPuntosGenerados( cliente == null ? 0 : total.divideToIntegralValue( BigDecimal.TEN ).intValue( ) );
            venta.setEstatusVenta( "COMPLETADA" );
            venta.setUsuario( cajero );
            venta.setCliente( cliente );
            session.save( venta );
            venta.setFolioTicket( "V" + LocalDate.now( ).format( DateTimeFormatter.ofPattern( "yyMMdd" ) )
                    + String.format( "%06d", venta.getId( ) ) );

            for( DetalleVenta detalle : detalles )
            {
                detalle.setVenta( venta );
                session.save( detalle );
            }
            return venta;
        } );
    }

    /** Cancela la venta: devuelve el stock, revierte los puntos del cliente y conserva el historial. */
    @Override
    public void cancelar( Long idVenta )
    {
        ejecutar( session ->
        {
            Venta venta = session.get( Venta.class, idVenta, LockMode.PESSIMISTIC_WRITE );
            if( venta == null )
            {
                throw new IllegalArgumentException( "La venta no existe." );
            }
            if( "CANCELADA".equals( venta.getEstatusVenta( ) ) )
            {
                throw new IllegalArgumentException( "La venta ya estaba cancelada." );
            }
            List<DetalleVenta> detalles = session.createQuery( "from DetalleVenta d where d.venta.id = :id",
                    DetalleVenta.class ).setParameter( "id", idVenta ).list( );
            for( DetalleVenta detalle : detalles )
            {
                Lote lote = session.get( Lote.class, detalle.getLote( ).getId( ), LockMode.PESSIMISTIC_WRITE );
                lote.setStockActual( lote.getStockActual( ) + detalle.getCantidad( ) );
            }
            if( venta.getCliente( ) != null )
            {
                Cliente cliente = session.get( Cliente.class, venta.getCliente( ).getId( ) );
                cliente.setPuntosAcumulados(
                        Math.max( 0, cliente.getPuntosAcumulados( ) - venta.getPuntosGenerados( ) ) );
            }
            venta.setEstatusVenta( "CANCELADA" );
            return null;
        } );
    }

    @Override
    public List<Venta> findHistorial( Long idUsuario )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            String hql = "from Venta v " + ( idUsuario != null ? "where v.usuario.id = :u " : "" )
                    + "order by v.fechaVenta desc, v.id desc";
            Query<Venta> query = session.createQuery( hql, Venta.class );
            if( idUsuario != null )
            {
                query.setParameter( "u", idUsuario );
            }
            return query.setMaxResults( 200 ).list( );
        }
    }

    @Override
    public List<DetalleVenta> findDetalle( Long idVenta )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from DetalleVenta d where d.venta.id = :id order by d.id",
                    DetalleVenta.class ).setParameter( "id", idVenta ).list( );
        }
    }

    @Override
    public List<Venta> findByCliente( Long idCliente )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            return session.createQuery( "from Venta v where v.cliente.id = :id order by v.fechaVenta desc, v.id desc",
                    Venta.class ).setParameter( "id", idCliente ).setMaxResults( 60 ).list( );
        }
    }
}
