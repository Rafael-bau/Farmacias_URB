package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table( name = "salidas" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Salida
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_salida" )
    private Long id;

    @ManyToOne
    @JoinColumn( name = "id_lote", nullable = false )
    private Lote lote;

    @Column( name = "cantidad", nullable = false )
    private Integer cantidad;

    @Column( name = "motivo", nullable = false, length = 20 )
    private String motivo;

    @Column( name = "observaciones", length = 200 )
    private String observaciones;

    @Column( name = "fecha", insertable = false, updatable = false )
    private LocalDateTime fecha;

    @ManyToOne
    @JoinColumn( name = "id_usuario", nullable = false )
    private Usuario usuario;
}
