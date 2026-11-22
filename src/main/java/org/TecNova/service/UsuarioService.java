package org.TecNova.service;

import org.TecNova.model.Usuario;

import java.util.List;

public interface UsuarioService
{
    List<Usuario> findAll( );
    Usuario findById(Long id);
    Usuario save(Usuario usuario);
    void deleteById(Long id);
    Usuario update(Usuario usuario);
    Usuario autenticar(String correo, String password);
    Usuario crear(Usuario usuario, String password, Long clienteId);
    Usuario actualizar(Usuario usuario, String passwordOpcional, Long clienteId);
    void cambiarPassword(Long idUsuario, String actual, String nueva);
    int inicializarPasswordsDePrueba( );
}
