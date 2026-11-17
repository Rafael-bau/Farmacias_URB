package org.TecNova.service.impl;

import org.TecNova.service.AlumnoService;

import java.util.List;

public class AlumnoServiceImpl implements AlumnoService
{
    private AlumnoDao alumnoDao;

    public AlumnoServiceImpl( )
    {
        this.alumnoDao = new AlumnoDaoImpl( );
    }

    @Override
    public List<Alumno> findAll()
    {
        return alumnoDao.findAll( );
    }

    @Override
    public Alumno findById(Long id)
    {
        return alumnoDao.findById( id );
    }

    @Override
    public void save(Alumno alumno)
    {
        alumnoDao.save( alumno );
    }

    @Override
    public void deleteById(Long id)
    {
        alumnoDao.deleteById( id );
    }

    @Override
    public void update(Alumno alumno)
    {
        alumnoDao.update( alumno );
    }
}
