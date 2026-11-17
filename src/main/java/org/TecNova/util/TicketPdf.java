package org.TecNova.util;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Genera el ticket de venta en PDF (RF-08) sin librerías externas.
 * Usa tipografía Courier (monoespaciada) para alinear columnas como un ticket térmico.
 */
public final class TicketPdf {

    private static final int ANCHO = 40;             // caracteres por línea
    private static final float TAM = 8f;             // tamaño de fuente
    private static final float INTERLINEA = 11f;
    private static final float MARGEN = 12f;
    private static final Charset CP1252 = Charset.forName("windows-1252");

    private TicketPdf() {
    }

    public static byte[] generar(Map<String, Object> venta, List<Map<String, Object>> detalle) {
        List<String> l = new ArrayList<>();
        l.add(centrar("FARMACIAS URB"));
        l.add(centrar("Ticket de venta"));
        l.add(separador());
        l.add("Folio:   " + texto(venta.get("folio_ticket")));
        l.add("Fecha:   " + fecha(venta.get("fecha_venta")));
        l.add("Cajero:  " + recortar(texto(venta.get("cajero")), ANCHO - 9));
        String cliente = venta.get("cliente") == null ? "Mostrador" : texto(venta.get("cliente"));
        l.add("Cliente: " + recortar(cliente, ANCHO - 9));
        if ("CANCELADA".equals(texto(venta.get("estatus_venta")))) {
            l.add(separador());
            l.add(centrar("*** VENTA CANCELADA ***"));
        }
        l.add(separador());

        for (Map<String, Object> d : detalle) {
            l.add(recortar(texto(d.get("nombre_comercial")), ANCHO));
            String izq = "  " + texto(d.get("cantidad")) + " x $" + dinero(d.get("precio_unitario"));
            l.add(derecha(izq, "$" + dinero(d.get("subtotal_linea"))));
        }

        l.add(separador());
        l.add(derecha("SUBTOTAL", "$" + dinero(venta.get("subtotal"))));
        l.add(derecha("IVA", "$" + dinero(venta.get("iva"))));
        l.add(derecha("TOTAL", "$" + dinero(venta.get("total"))));
        l.add(separador());
        l.add("Pago: " + texto(venta.get("metodo_pago")));
        if (venta.get("id_cliente") != null) {
            l.add("Puntos ganados: " + texto(venta.get("puntos_generados")));
        }
        l.add("");
        l.add(centrar("Gracias por su compra"));

        float ancho = 2 * MARGEN + ANCHO * 0.6f * TAM;
        float alto = 2 * MARGEN + (l.size() + 1) * INTERLINEA;
        return construirPdf(l, ancho, alto);
    }

    // ---------- formato de texto ----------

    private static String texto(Object o) {
        return o == null ? "" : o.toString();
    }

    private static String dinero(Object o) {
        if (o == null) {
            return "0.00";
        }
        return new BigDecimal(o.toString()).setScale(2, RoundingMode.HALF_UP).toPlainString();
    }

    private static String fecha(Object o) {
        if (o instanceof java.util.Date) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format((java.util.Date) o);
        }
        return texto(o);
    }

    private static String separador() {
        return "-".repeat(ANCHO);
    }

    private static String recortar(String s, int max) {
        return s.length() <= max ? s : s.substring(0, max);
    }

    private static String centrar(String s) {
        int espacios = Math.max(0, (ANCHO - s.length()) / 2);
        return " ".repeat(espacios) + s;
    }

    private static String derecha(String izq, String der) {
        int libres = Math.max(1, ANCHO - izq.length() - der.length());
        return izq + " ".repeat(libres) + der;
    }

    // ---------- escritura del PDF ----------

    private static byte[] construirPdf(List<String> lineas, float ancho, float alto) {
        // Contenido de la página: texto de arriba hacia abajo
        ByteArrayOutputStream cont = new ByteArrayOutputStream();
        escribir(cont, "BT\n/F1 " + TAM + " Tf\n" + INTERLINEA + " TL\n"
                + MARGEN + " " + (alto - MARGEN - TAM) + " Td\n");
        for (String linea : lineas) {
            escribir(cont, "(" + escapar(linea) + ") Tj T*\n");
        }
        escribir(cont, "ET\n");
        byte[] contenido = cont.toByteArray();

        ByteArrayOutputStream pdf = new ByteArrayOutputStream();
        List<Integer> offsets = new ArrayList<>();

        escribir(pdf, "%PDF-1.4\n");
        offsets.add(pdf.size());
        escribir(pdf, "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n");
        offsets.add(pdf.size());
        escribir(pdf, "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n");
        offsets.add(pdf.size());
        escribir(pdf, "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + ancho + " " + alto
                + "] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n");
        offsets.add(pdf.size());
        escribir(pdf, "4 0 obj\n<< /Length " + contenido.length + " >>\nstream\n");
        pdf.write(contenido, 0, contenido.length);
        escribir(pdf, "endstream\nendobj\n");
        offsets.add(pdf.size());
        escribir(pdf, "5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Courier /Encoding /WinAnsiEncoding >>\nendobj\n");

        int xref = pdf.size();
        escribir(pdf, "xref\n0 " + (offsets.size() + 1) + "\n0000000000 65535 f \n");
        for (int off : offsets) {
            escribir(pdf, String.format("%010d 00000 n \n", off));
        }
        escribir(pdf, "trailer\n<< /Size " + (offsets.size() + 1) + " /Root 1 0 R >>\nstartxref\n" + xref + "\n%%EOF\n");
        return pdf.toByteArray();
    }

    private static String escapar(String s) {
        return s.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)");
    }

    private static void escribir(ByteArrayOutputStream out, String s) {
        byte[] b = s.getBytes(CP1252);
        out.write(b, 0, b.length);
    }
}
