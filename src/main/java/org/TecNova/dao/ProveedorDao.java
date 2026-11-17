package org.TecNova.dao;

import org.TecNova.model.Proveedor;

import java.util.List;

public interface ProveedorDao
{
    List<Proveedor> findAll( );
    Proveedor findById(Long id);
    Proveedor save(Proveedor proveedor);
    void deleteById(Long id);
    Proveedor update(Proveedor proveedor);
    List<Proveedor> findActivos( );
}
