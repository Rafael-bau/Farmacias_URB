package org.TecNova.service.impl;

import org.TecNova.service.AlumnoMateriaService;

import java.util.List;

public class AlumnoMateriaServiceImpl implements AlumnoMateriaService
{
    private AlumnoMateriaDao alumnoMateriaDao;

    public AlumnoMateriaServiceImpl( )
    {
        this.alumnoMateriaDao = new AlumnoMateriaDaoImpl( );
    }

    @Override
    public List<AlumnoMateria> findAll()
    {
        return alumnoMateriaDao.findAll( );
    }

    @Override
    public AlumnoMateria findById(Long id)
    {
        return alumnoMateriaDao.findById( id );
    }

    @Override
    public void save(AlumnoMateria alumnoMateria)
    {
        alumnoMateriaDao.save( alumnoMateria );
    }

    @Override
    public void deleteById(Long id)
    {
        alumnoMateriaDao.deleteById( id );
    }

    @Override
    public void update(AlumnoMateria alumnoMateria)
    {
        alumnoMateriaDao.update( alumnoMateria );
    }
}
