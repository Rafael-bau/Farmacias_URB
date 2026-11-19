package org.TecNova.service.impl;

import org.TecNova.dao.ReporteDao;
import org.TecNova.dao.impl.ReporteDaoImpl;
import org.TecNova.service.ReporteService;

import java.util.List;
import java.util.Map;

public class ReporteServiceImpl implements ReporteService
{
    private final ReporteDao dao = new ReporteDaoImpl( );

    private String limpio( String s )
    {
        return s == null ? "" : s.trim( );
    }

    @Override
    public long totalCaducidad( )
    {
        return dao.totalCaducidad( );
    }

    @Override
    public long totalStockBajo( )
    {
        return dao.totalStockBajo( );
    }

    @Override
    public List<Map<String, Object>> resumenStock( int limite )
    {
        return dao.resumenStock( limite );
    }

    @Override
    public List<Map<String, Object>> inventario( String filtro, String texto )
    {
        return dao.inventario( limpio( filtro ), limpio( texto ) );
    }

    @Override
    public List<Map<String, Object>> almacen( String filtro, String texto )
    {
        return dao.almacen( limpio( filtro ), limpio( texto ) );
    }

    @Override
    public List<Map<String, Object>> catalogo( String texto )
    {
        return dao.catalogo( limpio( texto ) );
    }

    @Override
    public List<Map<String, Object>> novedades( int limite )
    {
        return dao.novedades( limite );
    }

    @Override
    public List<Map<String, Object>> lotesDisponibles( String texto )
    {
        return dao.lotesDisponibles( limpio( texto ) );
    }

    @Override
    public Map<String, Object> lotePorId( Long idLote )
    {
        return dao.lotePorId( idLote );
    }
}
