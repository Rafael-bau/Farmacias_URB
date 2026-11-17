package org.TecNova.dao;

import java.util.List;
import java.util.Map;

/** Consultas de solo lectura sobre las vistas de la base de datos (alertas, inventario, almacén, catálogo). */
public interface ReporteDao
{
    long totalCaducidad( );
    long totalStockBajo( );
    List<Map<String, Object>> resumenStock(int limite);
    List<Map<String, Object>> inventario(String filtro, String texto);
    List<Map<String, Object>> almacen(String filtro, String texto);
    List<Map<String, Object>> catalogo(String texto);
    List<Map<String, Object>> novedades(int limite);
    List<Map<String, Object>> lotesDisponibles(String texto);
    Map<String, Object> lotePorId(Long idLote);
}
