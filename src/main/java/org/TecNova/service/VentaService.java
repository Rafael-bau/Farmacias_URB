package org.TecNova.service;

import org.TecNova.model.Venta;
import org.TecNova.model.DetalleVenta;
import org.TecNova.model.ItemCarrito;
import org.TecNova.model.Usuario;

import java.util.Map;

import java.util.List;

public interface VentaService
{
    List<Venta> findAll( );
    Venta findById(Long id);
    Venta save(Venta venta);
    void deleteById(Long id);
    Venta update(Venta venta);
    Venta registrar(Usuario cajero, String telefonoCliente, String metodoPago, List<ItemCarrito> items);
    void cancelar(Long idVenta);
    List<Venta> findHistorial(Usuario usuario);
    List<DetalleVenta> findDetalle(Long idVenta);
    List<Map<String, Object>> comprasDeCliente(Long idCliente);
    byte[] ticketPdf(Long idVenta);
}

