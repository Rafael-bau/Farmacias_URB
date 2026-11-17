package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.time.LocalDateTime;
import java.io.Serializable;

@Entity
@Table( name = "usuarios" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Usuario implements Serializable
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_usuario" )
    private Long id;

    @Column( name = "nombre", nullable = false, length = 100 )
    private String nombre;

    @Column( name = "correo", nullable = false, length = 100 )
    private String correo;

    @Column( name = "password_hash", nullable = false, length = 255 )
    private String passwordHash;

    @ManyToOne
    @JoinColumn( name = "id_rol", nullable = false )
    private Rol rol;

    @Column( name = "estatus", nullable = false )
    private Boolean estatus;

    @Column( name = "fecha_creacion", insertable = false, updatable = false )
    private LocalDateTime fechaCreacion;
}
