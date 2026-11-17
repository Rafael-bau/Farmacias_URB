package org.TecNova.model;

import java.io.Serializable;
import java.math.BigDecimal;

/** Partida del carrito del punto de venta (vive en la sesión; no es una entidad). */
public class ItemCarrito implements Serializable
{
    private static final long serialVersionUID = 1L;

    private final Long idLote;
    private final String medicamento;
    private final String numLote;
    private final BigDecimal precio;
    private final int stock;
    private int cantidad;

    public ItemCarrito( Long idLote, String medicamento, String numLote, BigDecimal precio, int cantidad, int stock )
    {
        this.idLote = idLote;
        this.medicamento = medicamento;
        this.numLote = numLote;
        this.precio = precio;
        this.cantidad = cantidad;
        this.stock = stock;
    }

    public Long getIdLote( ) { return idLote; }
    public String getMedicamento( ) { return medicamento; }
    public String getNumLote( ) { return numLote; }
    public BigDecimal getPrecio( ) { return precio; }
    public int getStock( ) { return stock; }
    public int getCantidad( ) { return cantidad; }
    public void setCantidad( int cantidad ) { this.cantidad = cantidad; }

    public BigDecimal getSubtotal( )
    {
        return precio.multiply( BigDecimal.valueOf( cantidad ) );
    }
}
