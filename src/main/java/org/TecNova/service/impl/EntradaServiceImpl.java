package org.TecNova.service.impl;

import org.TecNova.dao.EntradaDao;
import org.TecNova.dao.impl.EntradaDaoImpl;
import org.TecNova.model.Entrada;
import org.TecNova.model.Usuario;
import org.TecNova.service.EntradaService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class EntradaServiceImpl implements EntradaService
{
    private final EntradaDao dao = new EntradaDaoImpl( );

    @Override
    public List<Entrada> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Entrada findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Entrada save( Entrada entrada )
    {
        return dao.save( entrada );
    }

    @Override
    public void deleteById( Long id )
    {
        dao.deleteById( id );
    }

    @Override
    public Entrada update( Entrada entrada )
    {
        return dao.update( entrada );
    }

    @Override
    public Entrada registrar( Long idProveedor, Long idMedicamento, String numLote, LocalDate caducidad,
                              int cantidad, BigDecimal costo, Usuario usuario )
    {
        if( numLote == null || numLote.isBlank( ) || numLote.length( ) > 50 )
        {
            throw new IllegalArgumentException( "El número de lote es obligatorio (máximo 50 caracteres)." );
        }
        if( costo != null && costo.signum( ) < 0 )
        {
            throw new IllegalArgumentException( "El costo no puede ser negativo." );
        }
        return dao.registrar( idProveedor, idMedicamento, numLote, caducidad, cantidad, costo, usuario );
    }
}

