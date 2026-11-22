package org.TecNova.dao.impl;

import org.TecNova.dao.ReporteDao;
import org.TecNova.util.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.query.NativeQuery;
import org.hibernate.transform.AliasToEntityMapResultTransformer;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Consultas nativas sobre las vistas v_alerta_*, v_inventario_lotes, v_almacen y v_lotes_disponibles. */
public class ReporteDaoImpl implements ReporteDao
{
    @SuppressWarnings( { "unchecked", "deprecation" } )
    private List<Map<String, Object>> consultar( String sql, Map<String, Object> parametros )
    {
        try( Session session = HibernateUtil.getSessionFactory( ).openSession( ) )
        {
            NativeQuery query = session.createNativeQuery( sql );
            for( Map.Entry<String, Object> p : parametros.entrySet( ) )
            {
                query.setParameter( p.getKey( ), p.getValue( ) );
            }
            query.setResultTransformer( AliasToEntityMapResultTransformer.INSTANCE );
            return (List<Map<String, Object>>) query.list( );
        }
    }

    private List<Map<String, Object>> consultar( String sql )
    {
        return consultar( sql, new HashMap<>( ) );
    }

    private long contar( String sql )
    {
        return ( (Number) consultar( sql ).get( 0 ).get( "n" ) ).longValue( );
    }

    @Override
    public long totalCaducidad( )
    {
        return contar( "select count(*) as n from v_alerta_caducidad" );
    }

    @Override
    public long totalStockBajo( )
    {
        return contar( "select count(*) as n from v_alerta_stock_critico" );
    }

    @Override
    public List<Map<String, Object>> resumenStock( int limite )
    {
        return consultar( "select nombre_comercial, stock_vigente, estado from v_almacen "
                + "order by stock_vigente asc, nombre_comercial limit " + limite );
    }

    @Override
    public List<Map<String, Object>> inventario( String filtro, String texto )
    {
        StringBuilder sql = new StringBuilder( "select * from v_inventario_lotes where 1 = 1" );
        Map<String, Object> p = new HashMap<>( );
        if( "caducidad".equals( filtro ) )
        {
            sql.append( " and estado in ('CADUCADO', 'POR CADUCAR')" );
        }
        else if( "stock".equals( filtro ) )
        {
            sql.append( " and stock_total <= stock_minimo" );
        }
        if( !texto.isEmpty( ) )
        {
            sql.append( " and (nombre_comercial like :t or codigo_barras like :t)" );
            p.put( "t", "%" + texto + "%" );
        }
        sql.append( " order by field(estado, 'CADUCADO', 'POR CADUCAR', 'STOCK BAJO', 'VIGENTE'), "
                + "fecha_caducidad, nombre_comercial limit 300" );
        return consultar( sql.toString( ), p );
    }

    @Override
    public List<Map<String, Object>> almacen( String filtro, String texto )
    {
        StringBuilder sql = new StringBuilder( "select * from v_almacen where 1 = 1" );
        Map<String, Object> p = new HashMap<>( );
        if( "stock".equals( filtro ) )
        {
            sql.append( " and estado in ('AGOTADO', 'STOCK BAJO')" );
        }
        if( !texto.isEmpty( ) )
        {
            sql.append( " and (nombre_comercial like :t or codigo_barras like :t or sustancia_activa like :t)" );
            p.put( "t", "%" + texto + "%" );
        }
        sql.append( " order by nombre_comercial limit 300" );
        return consultar( sql.toString( ), p );
    }

    private static final String SQL_CATALOGO =
            "select m.id_medicamento, m.nombre_comercial, m.sustancia_activa, m.precio_venta, "
            + "c.nombre_categoria, coalesce(s.stock, 0) as stock "
            + "from medicamentos m join categorias c on c.id_categoria = m.id_categoria "
            + "left join (select id_medicamento, sum(stock_actual) as stock from lotes "
            + "           where fecha_caducidad >= curdate() group by id_medicamento) s "
            + "       on s.id_medicamento = m.id_medicamento "
            + "where m.estatus = true ";

    @Override
    public List<Map<String, Object>> catalogo( String texto )
    {
        Map<String, Object> p = new HashMap<>( );
        p.put( "t", "%" + texto + "%" );
        return consultar( SQL_CATALOGO + "and (m.nombre_comercial like :t or m.sustancia_activa like :t) "
                + "order by m.nombre_comercial limit 120", p );
    }

    @Override
    public List<Map<String, Object>> novedades( int limite )
    {
        return consultar( SQL_CATALOGO + "order by m.id_medicamento desc limit " + limite );
    }

    @Override
    public List<Map<String, Object>> lotesDisponibles( String texto )
    {
        Map<String, Object> p = new HashMap<>( );
        p.put( "t", "%" + texto + "%" );
        return consultar( "select * from v_lotes_disponibles where nombre_comercial like :t or codigo_barras like :t "
                + "limit 40", p );
    }

    @Override
    public Map<String, Object> lotePorId( Long idLote )
    {
        Map<String, Object> p = new HashMap<>( );
        p.put( "id", idLote );
        List<Map<String, Object>> filas = consultar( "select * from v_lotes_disponibles where id_lote = :id", p );
        return filas.isEmpty( ) ? null : filas.get( 0 );
    }
}
