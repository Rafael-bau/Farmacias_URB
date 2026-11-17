package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

@Entity
@Table( name = "proveedores" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Proveedor
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_proveedor" )
    private Long id;

    @Column( name = "nombre", nullable = false, length = 100 )
    private String nombre;

    @Column( name = "telefono", length = 15 )
    private String telefono;

    @Column( name = "correo", length = 100 )
    private String correo;

    @Column( name = "direccion", length = 200 )
    private String direccion;

    @Column( name = "estatus", nullable = false )
    private Boolean estatus;
}
