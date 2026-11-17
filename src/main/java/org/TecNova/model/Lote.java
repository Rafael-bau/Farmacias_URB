package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.time.LocalDate;

@Entity
@Table( name = "lotes" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Lote
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_lote" )
    private Long id;

    @Column( name = "num_lote", nullable = false, length = 50 )
    private String numLote;

    @Column( name = "fecha_caducidad", nullable = false )
    private LocalDate fechaCaducidad;

    @Column( name = "stock_actual", nullable = false )
    private Integer stockActual;

    @ManyToOne
    @JoinColumn( name = "id_medicamento", nullable = false )
    private Medicamento medicamento;
}
