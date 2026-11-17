package org.TecNova.service;

import java.util.List;

public interface MateriaService
{
    List<Materia> findAll( );
    Materia findById( Long id );
    void save( Materia materia );
    void deleteById( Long id );
    void update( Materia materia );
}
