package org.TecNova.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.persistence.*;

@Entity
@Table( name = "categorias" )
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Categoria
{
    @Id
    @GeneratedValue( strategy = GenerationType.IDENTITY )
    @Column( name = "id_categoria" )
    private Long id;

    @Column( name = "nombre_categoria", nullable = false, length = 50 )
    private String nombre;
}
