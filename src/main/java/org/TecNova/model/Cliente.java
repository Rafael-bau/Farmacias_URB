package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table( name = "clientes" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Cliente
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_cliente" )
    private Long id;

    @Column( name = "nombre", nullable = false, length = 100 )
    private String nombre;

    @Column( name = "telefono", nullable = false, length = 15 )
    private String telefono;

    @Column( name = "correo", nullable = false, length = 100 )
    private String correo;

    @Column( name = "puntos_acumulados", nullable = false )
    private Integer puntosAcumulados;

    @Column( name = "fecha_registro", insertable = false, updatable = false )
    private LocalDateTime fechaRegistro;

    @ManyToOne
    @JoinColumn( name = "id_usuario" )
    private Usuario usuario;
}
