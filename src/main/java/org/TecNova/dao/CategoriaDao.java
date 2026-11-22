package org.TecNova.dao;

import org.TecNova.model.Categoria;

import java.util.List;

public interface CategoriaDao
{
    List<Categoria> findAll( );
    Categoria findById(Long id);
    Categoria save(Categoria categoria);
    void deleteById(Long id);
    Categoria update(Categoria categoria);
}
