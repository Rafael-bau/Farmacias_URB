package org.TecNova.filter;

import org.TecNova.model.Usuario;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * Filtro global: codificación UTF-8, token CSRF en los POST, sesión obligatoria y
 * control de acceso por rol. Protege también las páginas JSP (que llaman a los servicios directamente).
 */
@WebFilter("/*")
public class FiltroSeguridad implements Filter
{
    private static final Set<String> TODOS = Set.of( "Administrador", "Cajero", "Cliente" );
    private static final Set<String> PERSONAL = Set.of( "Administrador", "Cajero" );
    private static final Set<String> ADMIN = Set.of( "Administrador" );
    private static final Set<String> CLIENTE = Set.of( "Cliente" );

    /** Ruta -> roles con permiso. Lo que no está aquí (css, Login.jsp, Error.jsp) es público. */
    private static final Map<String, Set<String>> RUTAS = Map.ofEntries(
            Map.entry( "/", TODOS ),
            Map.entry( "/index.jsp", TODOS ),
            Map.entry( "/LogoutServlet", TODOS ),
            Map.entry( "/Configuracion.jsp", TODOS ),
            Map.entry( "/ConfiguracionServlet", TODOS ),
            Map.entry( "/Catalogos.jsp", TODOS ),
            Map.entry( "/TicketServlet", TODOS ),
            Map.entry( "/Inventario.jsp", PERSONAL ),
            Map.entry( "/Almacen.jsp", PERSONAL ),
            Map.entry( "/Ventas.jsp", PERSONAL ),
            Map.entry( "/Pos.jsp", PERSONAL ),
            Map.entry( "/PosServlet", PERSONAL ),
            Map.entry( "/Clientes.jsp", PERSONAL ),
            Map.entry( "/Cliente.jsp", PERSONAL ),
            Map.entry( "/ClienteServlet", PERSONAL ),
            Map.entry( "/VentaServlet", ADMIN ),
            Map.entry( "/Entradas.jsp", ADMIN ),
            Map.entry( "/EntradaServlet", ADMIN ),
            Map.entry( "/Salidas.jsp", ADMIN ),
            Map.entry( "/SalidaServlet", ADMIN ),
            Map.entry( "/Medicamentos.jsp", ADMIN ),
            Map.entry( "/Medicamento.jsp", ADMIN ),
            Map.entry( "/MedicamentoServlet", ADMIN ),
            Map.entry( "/Categorias.jsp", ADMIN ),
            Map.entry( "/Categoria.jsp", ADMIN ),
            Map.entry( "/CategoriaServlet", ADMIN ),
            Map.entry( "/Proveedores.jsp", ADMIN ),
            Map.entry( "/Proveedor.jsp", ADMIN ),
            Map.entry( "/ProveedorServlet", ADMIN ),
            Map.entry( "/Usuarios.jsp", ADMIN ),
            Map.entry( "/Usuario.jsp", ADMIN ),
            Map.entry( "/UsuarioServlet", ADMIN ),
            Map.entry( "/MisCompras.jsp", CLIENTE ) );

    @Override
    public void doFilter( ServletRequest rq, ServletResponse rs, FilterChain chain ) throws IOException, ServletException
    {
        HttpServletRequest req = (HttpServletRequest) rq;
        HttpServletResponse resp = (HttpServletResponse) rs;
        req.setCharacterEncoding( "UTF-8" );
        resp.setCharacterEncoding( "UTF-8" );

        String ruta = req.getRequestURI( ).substring( req.getContextPath( ).length( ) );
        if( ruta.startsWith( "/css/" ) || ruta.startsWith( "/js/" ) || ruta.startsWith( "/img/" ) )
        {
            chain.doFilter( rq, rs );
            return;
        }

        HttpSession sesion = req.getSession( true );
        if( sesion.getAttribute( "csrf" ) == null )
        {
            sesion.setAttribute( "csrf", UUID.randomUUID( ).toString( ) );
        }
        if( "POST".equalsIgnoreCase( req.getMethod( ) ) )
        {
            String token = req.getParameter( "_csrf" );
            if( token == null || !token.equals( sesion.getAttribute( "csrf" ) ) )
            {
                resp.sendError( 403, "Token de seguridad inválido. Recarga la página e inténtalo de nuevo." );
                return;
            }
        }

        Set<String> permitidos = RUTAS.get( ruta );
        if( permitidos == null )                    // Login.jsp, LoginServlet, Error.jsp...
        {
            chain.doFilter( rq, rs );
            return;
        }
        Usuario usuario = (Usuario) sesion.getAttribute( "usuario" );
        if( usuario == null )
        {
            resp.sendRedirect( req.getContextPath( ) + "/Login.jsp" );
            return;
        }
        if( !permitidos.contains( usuario.getRol( ).getNombre( ) ) )
        {
            resp.sendError( 403, "No tienes permiso para acceder a esta sección." );
            return;
        }
        resp.setHeader( "Cache-Control", "no-store, no-cache, must-revalidate" );
        resp.setHeader( "Pragma", "no-cache" );
        chain.doFilter( rq, rs );
    }
}
