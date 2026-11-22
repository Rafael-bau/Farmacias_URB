package org.TecNova.dao.impl;

import org.TecNova.dao.EntradaDao;
import org.TecNova.model.Entrada;
import org.TecNova.model.Lote;
import org.TecNova.model.Medicamento;
import org.TecNova.model.Proveedor;
import org.TecNova.model.Usuario;

import java.math.BigDecimal;
import java.time.LocalDate;

public class EntradaDaoImpl extends BaseDaoImpl<Entrada> implements EntradaDao
{
    public EntradaDaoImpl( )
    {
        super( Entrada.class );
    }

    @Override
    protected String orden( )
    {
        return " order by fecha desc, id desc";
    }

    /** Recepción de mercancía: crea el lote si no existe (o suma stock si ya existe) y guarda la entrada. */
    @Override
    public Entrada registrar( Long idProveedor, Long idMedicamento, String numLote, LocalDate caducidad,
                              int cantidad, BigDecimal costo, Usuario usuario )
    {
        return ejecutar( session ->
        {
            if( cantidad <= 0 )
            {
                throw new IllegalArgumentException( "La cantidad debe ser mayor a 0." );
            }
            if( caducidad == null || !caducidad.isAfter( LocalDate.now( ) ) )
            {
                throw new IllegalArgumentException( "La fecha de caducidad debe ser futura." );
            }
            Proveedor proveedor = session.get( Proveedor.class, idProveedor );
            if( proveedor == null || !Boolean.TRUE.equals( proveedor.getEstatus( ) ) )
            {
                throw new IllegalArgumentException( "El proveedor no existe o está dado de baja." );
            }
            Medicamento medicamento = session.get( Medicamento.class, idMedicamento );
            if( medicamento == null || !Boolean.TRUE.equals( medicamento.getEstatus( ) ) )
            {
                throw new IllegalArgumentException( "El medicamento no existe o está dado de baja." );
            }
            Lote lote = session.createQuery( "from Lote l where l.medicamento.id = :m and l.numLote = :n", Lote.class )
                    .setParameter( "m", idMedicamento ).setParameter( "n", numLote.trim( ) ).uniqueResult( );
            if( lote == null )
            {
                lote = new Lote( );
                lote.setMedicamento( medicamento );
                lote.setNumLote( numLote.trim( ) );
                lote.setFechaCaducidad( caducidad );
                lote.setStockActual( cantidad );
                session.save( lote );
            }
            else
            {
                if( !lote.getFechaCaducidad( ).equals( caducidad ) )
                {
                    throw new IllegalArgumentException( "Ese lote ya existe con otra fecha de caducidad." );
                }
                lote.setStockActual( lote.getStockActual( ) + cantidad );
            }
            Entrada entrada = new Entrada( );
            entrada.setLote( lote );
            entrada.setProveedor( proveedor );
            entrada.setCantidad( cantidad );
            entrada.setCostoUnitario( costo == null ? BigDecimal.ZERO : costo );
            entrada.setUsuario( usuario );
            session.save( entrada );
            return entrada;
        } );
    }
}
