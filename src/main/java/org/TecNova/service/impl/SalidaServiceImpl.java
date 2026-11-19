package org.TecNova.service.impl;

import org.TecNova.dao.SalidaDao;
import org.TecNova.dao.impl.SalidaDaoImpl;
import org.TecNova.model.Salida;
import org.TecNova.model.Usuario;
import org.TecNova.service.SalidaService;

import java.util.List;
import java.util.Set;

public class SalidaServiceImpl implements SalidaService
{
    private static final Set<String> MOTIVOS = Set.of( "MERMA", "CADUCIDAD", "AJUSTE", "OTRO" );

    private final SalidaDao dao = new SalidaDaoImpl( );

    @Override
    public List<Salida> findAll( )
    {
        return dao.findAll( );
    }

    @Override
    public Salida findById( Long id )
    {
        return dao.findById( id );
    }

    @Override
    public Salida save( Salida salida )
    {
        return dao.save( salida );
    }

    @Override
    public void deleteById( Long id )
    {
        dao.deleteById( id );
    }

    @Override
    public Salida update( Salida salida )
    {
        return dao.update( salida );
    }

    @Override
    public Salida registrar( Long idLote, int cantidad, String motivo, String observaciones, Usuario usuario )
    {
        if( !MOTIVOS.contains( motivo ) )
        {
            throw new IllegalArgumentException( "Selecciona un motivo válido." );
        }
        if( observaciones != null && observaciones.length( ) > 200 )
        {
            throw new IllegalArgumentException( "Las observaciones son demasiado largas (máximo 200)." );
        }
        return dao.registrar( idLote, cantidad, motivo, observaciones == null || observaciones.isBlank( ) ? null : observaciones.trim( ), usuario );
    }
}
