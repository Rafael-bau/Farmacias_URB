package org.TecNova.service;

import java.util.List;

public interface ProfesorMateriaService
{
    List<ProfesorMateria> findAll( );
    ProfesorMateria findById( Long id );
    void save( ProfesorMateria profesorMateria );
    void deleteById( Long id );
    void update( ProfesorMateria profesorMateria );
}
