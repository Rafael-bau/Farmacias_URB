package org.TecNova.service;

import java.util.List;

public interface AlumnoService
{
    List<Alumno> findAll( );
    Alumno findById( Long id );
    void save( Alumno alumno );
    void deleteById( Long id );
    void update( Alumno alumno );
}
