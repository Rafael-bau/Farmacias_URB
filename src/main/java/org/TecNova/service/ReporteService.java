package org.TecNova.service;

import java.util.List;
import java.util.Map;

public interface ReporteService
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