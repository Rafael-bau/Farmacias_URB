package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table( name = "ventas" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Venta
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_venta" )
    private Long id;

    @Column( name = "folio_ticket", nullable = false, length = 20 )
    private String folioTicket;

    @Column( name = "fecha_venta", insertable = false, updatable = false )
    private LocalDateTime fechaVenta;

    @Column( name = "subtotal", nullable = false )
    private BigDecimal subtotal;

    @Column( name = "iva", nullable = false )
    private BigDecimal iva;

    @Column( name = "total", nullable = false )
    private BigDecimal total;

    @Column( name = "metodo_pago", nullable = false, length = 20 )
    private String metodoPago;

    @Column( name = "puntos_generados", nullable = false )
    private Integer puntosGenerados;

    @Column( name = "estatus_venta", nullable = false, length = 20 )
    private String estatusVenta;

    @ManyToOne
    @JoinColumn( name = "id_usuario", nullable = false )
    private Usuario usuario;

    @ManyToOne
    @JoinColumn( name = "id_cliente" )
    private Cliente cliente;
}
