package org.TecNova.util;

import java.util.regex.Pattern;

/** Validaciones con expresiones regulares en el servidor (RF-10). El HTML usa los mismos patrones. */
public final class Validador {

    // Letras (con acentos y ñ), espacios, punto, apóstrofe y guion. 3 a 100 caracteres.
    public static final String REGEX_NOMBRE = "^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ][A-Za-zÁÉÍÓÚÜÑáéíóúüñ .'\\-]{2,99}$";
    // Teléfono mexicano de 10 dígitos.
    public static final String REGEX_TELEFONO = "^[0-9]{10}$";
    public static final String REGEX_CORREO = "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$";

    private static final Pattern NOMBRE = Pattern.compile(REGEX_NOMBRE);
    private static final Pattern TELEFONO = Pattern.compile(REGEX_TELEFONO);
    private static final Pattern CORREO = Pattern.compile(REGEX_CORREO);

    private Validador() {
    }

    public static boolean nombre(String v) {
        return v != null && NOMBRE.matcher(v).matches();
    }

    public static boolean telefono(String v) {
        return v != null && TELEFONO.matcher(v).matches();
    }

    public static boolean correo(String v) {
        return v != null && v.length() <= 100 && CORREO.matcher(v).matches();
    }

    public static boolean password(String v) {
        return v != null && v.length() >= 8 && v.length() <= 72;
    }

    /** Devuelve el mensaje de error o null si todo es válido. */
    public static String validarPersona(String nombre, String correo) {
        if (!nombre(nombre)) {
            return "Nombre inválido: use solo letras y espacios (3 a 100 caracteres).";
        }
        if (!correo(correo)) {
            return "Correo electrónico inválido.";
        }
        return null;
    }

    public static String validarCliente(String nombre, String telefono, String correo) {
        String e = validarPersona(nombre, correo);
        if (e != null) {
            return e;
        }
        if (!telefono(telefono)) {
            return "Teléfono inválido: deben ser 10 dígitos.";
        }
        return null;
    }
}
