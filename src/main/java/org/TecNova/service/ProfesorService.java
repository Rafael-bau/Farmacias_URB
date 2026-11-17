package org.TecNova.service;

import java.util.List;

public interface ProfesorService
{
    List<Profesor> findAll( );
    Profesor findById( Long id );
    void save( Profesor profesor );
    void deleteById( Long id );
    void update( Profesor profesor );
}
