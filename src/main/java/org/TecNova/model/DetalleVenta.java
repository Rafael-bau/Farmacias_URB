package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.math.BigDecimal;

@Entity
@Table( name = "detalle_ventas" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DetalleVenta
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_detalle" )
    private Long id;

    @ManyToOne
    @JoinColumn( name = "id_venta", nullable = false )
    private Venta venta;

    @ManyToOne
    @JoinColumn( name = "id_lote", nullable = false )
    private Lote lote;

    @Column( name = "cantidad", nullable = false )
    private Integer cantidad;

    @Column( name = "precio_unitario", nullable = false )
    private BigDecimal precioUnitario;

    @Column( name = "subtotal_linea", nullable = false )
    private BigDecimal subtotalLinea;
}
