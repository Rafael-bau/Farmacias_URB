package org.TecNova.dao;

import org.TecNova.model.Lote;

import java.util.List;

public interface LoteDao
{
    List<Lote> findAll( );
    Lote findById(Long id);
    Lote save(Lote lote);
    void deleteById(Long id);
    Lote update(Lote lote);
    List<Lote> findConStock( );
}
