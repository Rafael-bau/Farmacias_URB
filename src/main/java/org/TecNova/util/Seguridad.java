package org.TecNova.util;

import org.mindrot.jbcrypt.BCrypt;

/** Cifrado de contraseñas con bcrypt (RNF de seguridad). */
public final class Seguridad {

    private Seguridad() {
    }

    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt(10));
    }

    public static boolean verificar(String password, String hash) {
        try {
            return hash != null && BCrypt.checkpw(password, hash);
        } catch (IllegalArgumentException e) {   // hash con formato inválido
            return false;
        }
    }
}
