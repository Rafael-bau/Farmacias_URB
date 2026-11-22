package org.TecNova.dao;

import org.TecNova.model.Entrada;
import org.TecNova.model.Usuario;
import java.math.BigDecimal;
import java.time.LocalDate;

import java.util.List;

public interface EntradaDao
{
    List<Entrada> findAll( );
    Entrada findById(Long id);
    Entrada save(Entrada entrada);
    void deleteById(Long id);
    Entrada update(Entrada entrada);
    Entrada registrar(Long idProveedor, Long idMedicamento, String numLote, LocalDate caducidad,
                      int cantidad, BigDecimal costo, Usuario usuario);
}
