package org.TecNova.dao;

import org.TecNova.model.Salida;
import org.TecNova.model.Usuario;

import java.util.List;

public interface SalidaDao
{
    List<Salida> findAll( );
    Salida findById(Long id);
    Salida save(Salida salida);
    void deleteById(Long id);
    Salida update(Salida salida);
    Salida registrar(Long idLote, int cantidad, String motivo, String observaciones, Usuario usuario);
}
