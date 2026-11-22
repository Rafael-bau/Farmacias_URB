package org.TecNova.service;

import org.TecNova.model.Categoria;

import java.util.List;

public interface CategoriaService
{
    List<Categoria> findAll( );
    Categoria findById(Long id);
    Categoria save(Categoria categoria);
    void deleteById(Long id);
    Categoria update(Categoria categoria);
}