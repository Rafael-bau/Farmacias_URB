package org.TecNova.service;

import org.TecNova.model.Lote;

import java.util.List;

public interface LoteService
{
    List<Lote> findAll( );
    Lote findById(Long id);
    Lote save(Lote lote);
    void deleteById(Long id);
    Lote update(Lote lote);
    List<Lote> findConStock( );
}
