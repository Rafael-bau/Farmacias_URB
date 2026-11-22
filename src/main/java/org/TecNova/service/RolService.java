package org.TecNova.service;

import org.TecNova.model.Rol;

import java.util.List;

public interface RolService
{
    List<Rol> findAll( );
    Rol findById(Long id);
    Rol save(Rol rol);
    void deleteById(Long id);
    Rol update(Rol rol);
}
