package org.TecNova.dao;

import org.TecNova.model.Venta;
import org.TecNova.model.Usuario;
import org.TecNova.model.Cliente;
import org.TecNova.model.DetalleVenta;
import org.TecNova.model.ItemCarrito;
import java.math.BigDecimal;

import java.util.List;

public interface VentaDao
{
    List<Venta> findAll( );
    Venta findById(Long id);
    Venta save(Venta venta);
    void deleteById(Long id);
    Venta update(Venta venta);
    Venta registrar(Usuario cajero, Cliente cliente, String metodoPago, BigDecimal tasaIva, List<ItemCarrito> items);
    void cancelar(Long idVenta);
    List<Venta> findHistorial(Long idUsuario);
    List<DetalleVenta> findDetalle(Long idVenta);
    List<Venta> findByCliente(Long idCliente);
}
