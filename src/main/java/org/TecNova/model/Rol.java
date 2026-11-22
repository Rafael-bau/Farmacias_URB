package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

import java.io.Serializable;

@Entity
@Table( name = "roles" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Rol implements Serializable
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_rol" )
    private Long id;

    @Column( name = "nombre_rol", nullable = false, length = 30 )
    private String nombre;
}
