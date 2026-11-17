package org.TecNova.service.impl;

import org.TecNova.service.ProfesorService;

import java.util.List;

public class ProfesorServiceImpl implements ProfesorService
{
    private ProfesorDao profesorDao;

    public ProfesorServiceImpl( )
    {
        this.profesorDao = new ProfesorDaoImpl( );
    }

    @Override
    public List<Profesor> findAll()
    {
        return profesorDao.findAll( );
    }

    @Override
    public Profesor findById(Long id)
    {
        return profesorDao.findById( id );
    }

    @Override
    public void save(Profesor profesor)
    {
        profesorDao.save( profesor );
    }

    @Override
    public void deleteById(Long id)
    {
        profesorDao.deleteById( id );
    }

    @Override
    public void update(Profesor profesor)
    {
        profesorDao.update( profesor );
    }
}
