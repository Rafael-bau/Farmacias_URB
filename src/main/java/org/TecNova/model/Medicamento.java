package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.math.BigDecimal;

@Entity
@Table( name = "medicamentos" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Medicamento
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_medicamento" )
    private Long id;

    @Column( name = "codigo_barras", nullable = false, length = 50 )
    private String codigoBarras;

    @Column( name = "nombre_comercial", nullable = false, length = 100 )
    private String nombreComercial;

    @Column( name = "sustancia_activa", nullable = false, length = 100 )
    private String sustanciaActiva;

    @Column( name = "precio_venta", nullable = false )
    private BigDecimal precioVenta;

    @Column( name = "stock_minimo", nullable = false )
    private Integer stockMinimo;

    @ManyToOne
    @JoinColumn( name = "id_categoria", nullable = false )
    private Categoria categoria;

    @Column( name = "estatus", nullable = false )
    private Boolean estatus;
}
