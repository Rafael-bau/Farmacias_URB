package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table( name = "entradas" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Entrada
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_entrada" )
    private Long id;

    @ManyToOne
    @JoinColumn( name = "id_lote", nullable = false )
    private Lote lote;

    @ManyToOne
    @JoinColumn( name = "id_proveedor", nullable = false )
    private Proveedor proveedor;

    @Column( name = "cantidad", nullable = false )
    private Integer cantidad;

    @Column( name = "costo_unitario", nullable = false )
    private BigDecimal costoUnitario;

    @Column( name = "fecha", insertable = false, updatable = false )
    private LocalDateTime fecha;

    @ManyToOne
    @JoinColumn( name = "id_usuario", nullable = false )
    private Usuario usuario;
}
