package org.TecNova.dao.impl;

import org.TecNova.dao.SalidaDao;
import org.TecNova.model.Lote;
import org.TecNova.model.Salida;
import org.TecNova.model.Usuario;
import org.hibernate.LockMode;

public class SalidaDaoImpl extends BaseDaoImpl<Salida> implements SalidaDao
{
    public SalidaDaoImpl( )
    {
        super( Salida.class );
    }

    @Override
    protected String orden( )
    {
        return " order by fecha desc, id desc";
    }

    /** Descuenta stock por merma, caducidad o ajuste y guarda la salida. */
    @Override
    public Salida registrar( Long idLote, int cantidad, String motivo, String observaciones, Usuario usuario )
    {
        return ejecutar( session ->
        {
            if( cantidad <= 0 )
            {
                throw new IllegalArgumentException( "La cantidad debe ser mayor a 0." );
            }
            Lote lote = session.get( Lote.class, idLote, LockMode.PESSIMISTIC_WRITE );
            if( lote == null )
            {
                throw new IllegalArgumentException( "El lote no existe." );
            }
            if( lote.getStockActual( ) < cantidad )
            {
                throw new IllegalArgumentException( "Stock insuficiente en el lote (disponibles: " + lote.getStockActual( ) + ")." );
            }
            lote.setStockActual( lote.getStockActual( ) - cantidad );
            Salida salida = new Salida( );
            salida.setLote( lote );
            salida.setCantidad( cantidad );
            salida.setMotivo( motivo );
            salida.setObservaciones( observaciones );
            salida.setUsuario( usuario );
            session.save( salida );
            return salida;
        } );
    }
}
