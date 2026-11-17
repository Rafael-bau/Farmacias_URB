package org.TecNova.dao;

import org.TecNova.model.Medicamento;

import java.util.List;

public interface MedicamentoDao
{
    List<Medicamento> findAll( );
    Medicamento findById(Long id);
    Medicamento save(Medicamento medicamento);
    void deleteById(Long id);
    Medicamento update(Medicamento medicamento);
    List<Medicamento> findActivos( );
    Medicamento findByCodigoBarras(String codigoBarras);
}
