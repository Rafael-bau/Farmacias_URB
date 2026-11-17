package org.TecNova.dao;

import org.TecNova.model.Cliente;

import java.util.List;

public interface ClienteDao
{
    List<Cliente> findAll( );
    Cliente findById(Long id);
    Cliente save(Cliente cliente);
    void deleteById(Long id);
    Cliente update(Cliente cliente);
    Cliente findByTelefono(String telefono);
    Cliente findByUsuarioId(Long idUsuario);
    List<Cliente> findSinCuenta(Long idUsuarioActual);
    List<Cliente> buscar(String texto);
    void vincularUsuario(Long idCliente, Long idUsuario);
}
