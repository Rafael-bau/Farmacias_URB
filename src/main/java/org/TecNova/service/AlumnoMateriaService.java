package org.TecNova.service;

import java.util.List;

public interface AlumnoMateriaService
{
    List<AlumnoMateria> findAll( );
    AlumnoMateria findById( Long id );
    void save( AlumnoMateria alumnoMateria );
    void deleteById( Long id );
    void update( AlumnoMateria alumnoMateria );
}
