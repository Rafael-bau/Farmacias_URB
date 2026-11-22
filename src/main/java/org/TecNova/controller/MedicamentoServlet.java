package org.TecNova.controller;

import org.TecNova.model.Categoria;
import org.TecNova.model.Medicamento;
import org.TecNova.service.CategoriaService;
import org.TecNova.service.MedicamentoService;
import org.TecNova.service.impl.CategoriaServiceImpl;
import org.TecNova.service.impl.MedicamentoServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet( "/MedicamentoServlet" )
public class MedicamentoServlet extends BaseServlet
{
    private static final long serialVersionUID = 1L;

    private final MedicamentoService service = new MedicamentoServiceImpl( );
    private final CategoriaService categoriaService = new CategoriaServiceImpl( );

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws IOException
    {
        try
        {
            Long id = id( req.getParameter( "id" ) );
            if( "delete".equals( req.getParameter( "accion" ) ) )
            {
                if( id == null )
                {
                    throw new IllegalArgumentException( "El medicamento no existe." );
                }
                service.deleteById( id );                       // baja lógica
                ok( req, "Medicamento dado de baja (puedes reactivarlo editándolo)." );
            }
            else
            {
                Medicamento m = id == null ? new Medicamento( ) : service.findById( id );
                if( m == null )
                {
                    throw new IllegalArgumentException( "El medicamento no existe." );
                }
                Categoria categoria = categoriaService.findById( id( req.getParameter( "categoriaId" ) ) );
                if( categoria == null )
                {
                    throw new IllegalArgumentException( "Selecciona una categoría." );
                }
                m.setCodigoBarras( texto( req, "codigoBarras" ) );
                m.setNombreComercial( texto( req, "nombreComercial" ) );
                m.setSustanciaActiva( texto( req, "sustanciaActiva" ) );
                m.setPrecioVenta( decimal( req, "precioVenta" ) );
                m.setStockMinimo( entero( req, "stockMinimo" ) );
                m.setCategoria( categoria );
                m.setEstatus( !"0".equals( req.getParameter( "estatus" ) ) );
                if( id == null )
                {
                    service.save( m );
                    ok( req, "Medicamento creado correctamente." );
                }
                else
                {
                    service.update( m );
                    ok( req, "Medicamento actualizado correctamente." );
                }
            }
        }
        catch( RuntimeException e )
        {
            error( req, e );
        }
        ir( req, resp, "Medicamentos.jsp" );
    }
}
