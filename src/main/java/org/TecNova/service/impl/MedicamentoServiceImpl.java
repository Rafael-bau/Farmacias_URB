package org.TecNova.service.impl;

import org.TecNova.dao.MedicamentoDao;
import org.TecNova.dao.impl.MedicamentoDaoImpl;
import org.TecNova.model.Medicamento;
import org.TecNova.service.MedicamentoService;

import java.util.List;

public class MedicamentoServiceImpl implements MedicamentoService
{
    private final MedicamentoDao dao = new MedicamentoDaoImpl( );

    @Override
    public List<Medicamento> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Medicamento findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Medicamento save( Medicamento entity )
    {
        validar( entity );
        return dao.save( entity );
    }

    @Override
    public void deleteById( Long id )
    {
        Medicamento medicamento = dao.findById( id );      // baja lógica: el medicamento ya pudo venderse
        if( medicamento != null )
        {
            medicamento.setEstatus( false );
            dao.update( medicamento );
        }
    }

    @Override
    public Medicamento update( Medicamento entity )
    {
        validar( entity );
        return dao.update( entity );
    }

    private void validar( Medicamento entity )
    {
        if( vacio( entity.getCodigoBarras( ) ) || vacio( entity.getNombreComercial( ) ) || vacio( entity.getSustanciaActiva( ) ) )
        {
            throw new IllegalArgumentException( "Código de barras, nombre y sustancia activa son obligatorios." );
        }
        if( entity.getCodigoBarras( ).length( ) > 50 || entity.getNombreComercial( ).length( ) > 100
                || entity.getSustanciaActiva( ).length( ) > 100 )
        {
            throw new IllegalArgumentException( "Alguno de los textos es demasiado largo." );
        }
        if( entity.getPrecioVenta( ) == null || entity.getPrecioVenta( ).signum( ) <= 0 )
        {
            throw new IllegalArgumentException( "El precio debe ser mayor a 0." );
        }
        if( entity.getStockMinimo( ) == null || entity.getStockMinimo( ) < 0 )
        {
            throw new IllegalArgumentException( "El stock mínimo no puede ser negativo." );
        }
        if( entity.getCategoria( ) == null )
        {
            throw new IllegalArgumentException( "Selecciona una categoría." );
        }
        if( entity.getEstatus( ) == null )
        {
            entity.setEstatus( true );
        }
        entity.setCodigoBarras( entity.getCodigoBarras( ).trim( ) );
        entity.setNombreComercial( entity.getNombreComercial( ).trim( ) );
        entity.setSustanciaActiva( entity.getSustanciaActiva( ).trim( ) );
    }

    private boolean vacio( String s )
    {
        return s == null || s.isBlank( );
    }

    @Override
    public List<Medicamento> findActivos( )
    {
        return dao.findActivos( );
    }
}

