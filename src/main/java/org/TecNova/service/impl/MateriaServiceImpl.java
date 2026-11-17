package org.TecNova.service.impl;

import org.TecNova.service.MateriaService;

import java.util.List;

public class MateriaServiceImpl implements MateriaService
{
    private MateriaDao materiaDao;

    public MateriaServiceImpl( )
    {
        this.materiaDao = new MateriaDaoImpl( );
    }

    @Override
    public List<Materia> findAll()
    {
        return materiaDao.findAll( );
    }

    @Override
    public Materia findById(Long id)
    {
        return materiaDao.findById( id );
    }

    @Override
    public void save(Materia materia)
    {
        materiaDao.save( materia );
    }

    @Override
    public void deleteById(Long id)
    {
        materiaDao.deleteById( id );
    }

    @Override
    public void update(Materia materia)
    {
        materiaDao.update( materia );
    }
}
