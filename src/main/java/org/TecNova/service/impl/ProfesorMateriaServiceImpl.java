package org.TecNova.service.impl;

import org.TecNova.service.ProfesorMateriaService;

import java.util.List;

public class ProfesorMateriaServiceImpl implements ProfesorMateriaService
{
    private ProfesorMateriaDao profesorMateriaDao;

    public ProfesorMateriaServiceImpl( )
    {
        this.profesorMateriaDao = new ProfesorMateriaDaoImpl( );
    }

    @Override
    public List<ProfesorMateria> findAll()
    {
        return profesorMateriaDao.findAll( );
    }

    @Override
    public ProfesorMateria findById(Long id)
    {
        return profesorMateriaDao.findById( id );
    }

    @Override
    public void save(ProfesorMateria profesorMateria)
    {
        profesorMateriaDao.save( profesorMateria );
    }

    @Override
    public void deleteById(Long id)
    {
        profesorMateriaDao.deleteById( id );
    }

    @Override
    public void update(ProfesorMateria profesorMateria)
    {
        profesorMateriaDao.update( profesorMateria );
    }
}
