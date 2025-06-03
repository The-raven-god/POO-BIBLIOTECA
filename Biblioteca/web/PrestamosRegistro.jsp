<%@page import="java.sql.*"%>
<%@page import="utils.conexion"%>
<%@page import="java.util.*"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String mensaje = "";
    String tipoMensaje = "";
    
    if (request.getMethod().equals("POST")) {
        String documento = request.getParameter("documento");
        String libroId = request.getParameter("libro");
        String fechaPrestamo = request.getParameter("fecha");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmtUpdate = null;
        ResultSet rs = null;
        
        try {
            conn = conexion.getConnection();
            conn.setAutoCommit(false);
            
            String sqlUsuario = "SELECT id FROM usuario WHERE cedula = ? AND activo = 1";
            pstmt = conn.prepareStatement(sqlUsuario);
            pstmt.setString(1, documento);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                mensaje = "Usuario no encontrado o inactivo";
                tipoMensaje = "error";
            } else {
                int usuarioId = rs.getInt("id");
                rs.close();
                pstmt.close();
                
                String sqlLibro = "SELECT cantidadDisponible FROM libro WHERE id = ?";
                pstmt = conn.prepareStatement(sqlLibro);
                pstmt.setInt(1, Integer.parseInt(libroId));
                rs = pstmt.executeQuery();
                
                if (!rs.next()) {
                    mensaje = "Libro no encontrado";
                    tipoMensaje = "error";
                } else {
                    int cantidadDisponible = rs.getInt("cantidadDisponible");
                    
                    if (cantidadDisponible <= 0) {
                        mensaje = "No hay ejemplares disponibles de este libro";
                        tipoMensaje = "error";
                    } else {
                        rs.close();
                        pstmt.close();
                        
                        LocalDate fechaPrestamoDate = LocalDate.parse(fechaPrestamo);
                        LocalDate fechaLimite = fechaPrestamoDate.plusDays(7);
                        
                        String sqlPrestamo = "INSERT INTO prestamo (idUsuario, idLibro, fechaPrestamo, fechaLimite, estado) VALUES (?, ?, ?, ?, 'pendiente')";
                        pstmt = conn.prepareStatement(sqlPrestamo);
                        pstmt.setInt(1, usuarioId);
                        pstmt.setInt(2, Integer.parseInt(libroId));
                        pstmt.setString(3, fechaPrestamo);
                        pstmt.setString(4, fechaLimite.toString());
                        
                        int filasAfectadas = pstmt.executeUpdate();
                        
                        if (filasAfectadas > 0) {
                            String sqlUpdateLibro = "UPDATE libro SET cantidadDisponible = cantidadDisponible - 1 WHERE id = ?";
                            pstmtUpdate = conn.prepareStatement(sqlUpdateLibro);
                            pstmtUpdate.setInt(1, Integer.parseInt(libroId));
                            pstmtUpdate.executeUpdate();
                            
                            conn.commit();
                            mensaje = "Préstamo registrado exitosamente. Fecha límite de devolución: " + fechaLimite.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                            tipoMensaje = "success";
                        } else {
                            conn.rollback();
                            mensaje = "Error al registrar el préstamo";
                            tipoMensaje = "error";
                        }
                    }
                }
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            mensaje = "Error de base de datos: " + e.getMessage();
            tipoMensaje = "error";
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {}
            mensaje = "Error inesperado: " + e.getMessage();
            tipoMensaje = "error";
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (pstmtUpdate != null) pstmtUpdate.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.out.println("Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
    
    // Cargar libros disponibles
    List<Map<String, Object>> librosDisponibles = new ArrayList<>();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = conexion.getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT id, titulo, autor, cantidadDisponible FROM libro WHERE cantidadDisponible > 0 ORDER BY titulo");
        
        while (rs.next()) {
            Map<String, Object> libro = new HashMap<>();
            libro.put("id", rs.getInt("id"));
            libro.put("titulo", rs.getString("titulo"));
            libro.put("autor", rs.getString("autor"));
            libro.put("cantidadDisponible", rs.getInt("cantidadDisponible"));
            librosDisponibles.add(libro);
        }
    } catch (Exception e) {
        System.out.println("Error al cargar libros: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar recursos: " + e.getMessage());
        }
    }
    
    // Cargar usuarios activos para autocompletado
    List<Map<String, Object>> usuariosActivos = new ArrayList<>();
    try {
        conn = conexion.getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT cedula, nombre, apellido FROM usuario WHERE activo = 1 ORDER BY nombre, apellido");
        
        while (rs.next()) {
            Map<String, Object> usuario = new HashMap<>();
            usuario.put("cedula", rs.getString("cedula"));
            usuario.put("nombre", rs.getString("nombre"));
            usuario.put("apellido", rs.getString("apellido"));
            usuariosActivos.add(usuario);
        }
    } catch (Exception e) {
        System.out.println("Error al cargar usuarios: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.out.println("Error al cerrar recursos: " + e.getMessage());
        }
    }
    
    String fechaActual = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
%>

<%@ include file="navbar.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registrar Préstamo - Biblioteca</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .mensaje {
            padding: 15px;
            margin: 20px 0;
            border-radius: 6px;
            font-weight: bold;
            border: 1px solid;
        }
        .mensaje.success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }
        .mensaje.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            box-sizing: border-box;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }
        .disponibles {
            color: #28a745;
            font-weight: bold;
            font-size: 0.9em;
        }
        .form-info {
            background-color: #e7f3ff;
            border: 1px solid #b3d9ff;
            border-radius: 6px;
            padding: 15px;
            margin-bottom: 20px;
        }
        .form-info h4 {
            margin: 0 0 10px 0;
            color: #0066cc;
        }
        .form-info ul {
            margin: 10px 0 0 20px;
            color: #666;
        }
        .btn-disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        /* Estilos para selector de usuario */
        .usuario-selector {
            position: relative;
            margin-bottom: 10px;
        }
        
        .usuario-select {
            display: block;
        }
        
        .usuario-search {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            z-index: 10;
            background: white;
        }
        
        .usuario-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 5px;
        }
        
        .btn-search, .btn-clear {
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: background-color 0.3s;
        }
        
        .btn-search:hover {
            background: #0056b3;
        }
        
        .btn-clear {
            background: #6c757d;
        }
        
        .btn-clear:hover {
            background: #545b62;
        }
        
        .usuario-filtered {
            background-color: #fff3cd;
            border-color: #ffeaa7;
        }
        
        .no-results {
            color: #dc3545;
            font-style: italic;
            padding: 8px 12px;
            background-color: #f8f9fa;
            border-radius: 4px;
            margin-top: 5px;
            display: none;
        }
    </style>
</head>
<body>
<div class="main-content">
    <div class="container">
        <div class="card">
            <div class="card-header">
                <h1><i class="fas fa-plus-circle"></i> Registrar Nuevo Préstamo</h1>
                <p>Complete el formulario para registrar un nuevo préstamo de libro</p>
            </div>
            
            <div class="form-info">
                <h4><i class="fas fa-info-circle"></i> Información del Préstamo</h4>
                <ul>
                    <li>Los préstamos tienen una duración de <strong>7 días</strong></li>
                    <li>Verifique que el usuario esté registrado y activo en el sistema</li>
                    <li>Solo se pueden prestar libros con disponibilidad mayor a 0</li>
                    <li>Se calculará automáticamente la fecha límite de devolución</li>
                </ul>
            </div>
            
            <% if (!mensaje.equals("")) { %>
                <div class="mensaje <%= tipoMensaje %>">
                    <i class="fas fa-<%= tipoMensaje.equals("success") ? "check-circle" : "exclamation-triangle" %>"></i>
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="post" style="max-width: 700px; margin: 0 auto;">
                <div class="form-group">
                    <label for="usuario-select">
                        <i class="fas fa-id-card"></i> Usuario:
                    </label>
                    <div class="usuario-selector">
                        <select id="usuario-select" name="documento" class="form-control usuario-select" required>
                            <option value="">Seleccione un usuario...</option>
                            <% for (Map<String, Object> usuario : usuariosActivos) { %>
                                <option value="<%= usuario.get("cedula") %>">
                                    <%= usuario.get("cedula") %> - <%= usuario.get("nombre") %> <%= usuario.get("apellido") %>
                                </option>
                            <% } %>
                            <% if (usuariosActivos.isEmpty()) { %>
                                <option value="" disabled>No hay usuarios disponibles</option>
                            <% } %>
                        </select>
                        <input type="text" id="usuario-search" class="form-control usuario-search" 
                               placeholder="Escriba para buscar usuario por documento o nombre..." 
                               style="display: none;">
                    </div>
                    <div class="usuario-actions">
                        <button type="button" id="toggle-search" class="btn-search">
                            <i class="fas fa-search"></i> Buscar
                        </button>
                        <button type="button" id="clear-search" class="btn-clear" style="display: none;">
                            <i class="fas fa-times"></i> Limpiar
                        </button>
                    </div>
                    <small style="color: #666; font-size: 12px;">
                        <i class="fas fa-info"></i> Seleccione de la lista o use "Buscar" para filtrar usuarios.
                    </small>
                </div>
                
                <div class="form-group">
                    <label for="libro">
                        <i class="fas fa-book"></i> Libro a Prestar:
                    </label>
                    <select id="libro" name="libro" class="form-control" required>
                        <option value="">Seleccione un libro...</option>
                        <% for (Map<String, Object> libro : librosDisponibles) { %>
                            <option value="<%= libro.get("id") %>">
                                <%= libro.get("titulo") %> - <%= libro.get("autor") != null ? libro.get("autor") : "Sin autor" %>
                                <span class="disponibles">(Disponibles: <%= libro.get("cantidadDisponible") %>)</span>
                            </option>
                        <% } %>
                        <% if (librosDisponibles.isEmpty()) { %>
                            <option value="" disabled>No hay libros disponibles</option>
                        <% } %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="fecha">
                        <i class="fas fa-calendar-alt"></i> Fecha de Préstamo:
                    </label>
                    <input type="date" id="fecha" name="fecha" class="form-control" 
                           value="<%= fechaActual %>" required max="<%= fechaActual %>">
                    <small style="color: #666; font-size: 12px;">
                        <i class="fas fa-info"></i> La fecha límite de devolución será automáticamente 7 días después
                    </small>
                </div>
                
                <div style="text-align: center; margin-top: 30px;">
                    <button type="submit" class="btn btn-block <%= librosDisponibles.isEmpty() ? "btn-disabled" : "" %>" 
                            <%= librosDisponibles.isEmpty() ? "disabled" : "" %>>
                        <i class="fas fa-check"></i> Registrar Préstamo
                    </button>
                    
                    <% if (librosDisponibles.isEmpty()) { %>
                        <p style="color: var(--accent-color); margin-top: 15px;">
                            <i class="fas fa-exclamation-triangle"></i> 
                            No hay libros disponibles para préstamo en este momento
                        </p>
                    <% } %>
                    
                    <a href="PrestamosActivos.jsp" class="btn" style="background-color: #6c757d; margin-left: 10px;">
                        <i class="fas fa-list"></i> Ver Préstamos Activos
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
// Variables para manejo del selector de usuario
const usuarioSelect = document.getElementById('usuario-select');
const usuarioSearch = document.getElementById('usuario-search');
const toggleSearchBtn = document.getElementById('toggle-search');
const clearSearchBtn = document.getElementById('clear-search');
let originalOptions = [];
let isSearchMode = false;

// Guardar opciones originales al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    for (let i = 0; i < usuarioSelect.options.length; i++) {
        originalOptions.push({
            value: usuarioSelect.options[i].value,
            text: usuarioSelect.options[i].text
        });
    }
});

// Función para alternar entre modo select y modo búsqueda
toggleSearchBtn.addEventListener('click', function() {
    if (!isSearchMode) {
        // Cambiar a modo búsqueda
        usuarioSelect.style.display = 'none';
        usuarioSearch.style.display = 'block';
        usuarioSearch.focus();
        toggleSearchBtn.style.display = 'none';
        clearSearchBtn.style.display = 'inline-block';
        isSearchMode = true;
        
        // Si había una selección, ponerla en el campo de búsqueda
        if (usuarioSelect.value) {
            const selectedText = usuarioSelect.options[usuarioSelect.selectedIndex].text;
            usuarioSearch.value = selectedText;
        }
    }
});

// Función para limpiar búsqueda y volver al select
clearSearchBtn.addEventListener('click', function() {
    usuarioSearch.style.display = 'none';
    usuarioSelect.style.display = 'block';
    toggleSearchBtn.style.display = 'inline-block';
    clearSearchBtn.style.display = 'none';
    usuarioSearch.value = '';
    isSearchMode = false;
    
    // Restaurar todas las opciones
    restoreAllOptions();
    usuarioSelect.classList.remove('usuario-filtered');
});

// Función para filtrar opciones mientras escribes en modo búsqueda
usuarioSearch.addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase().trim();
    
    if (searchTerm === '') {
        restoreAllOptions();
        usuarioSelect.classList.remove('usuario-filtered');
        return;
    }
    
    // Limpiar select
    usuarioSelect.innerHTML = '<option value="">Seleccione un usuario...</option>';
    
    // Filtrar y agregar opciones que coincidan
    let hasResults = false;
    originalOptions.forEach(option => {
        if (option.value && option.text.toLowerCase().includes(searchTerm)) {
            const newOption = document.createElement('option');
            newOption.value = option.value;
            newOption.text = option.text;
            usuarioSelect.appendChild(newOption);
            hasResults = true;
        }
    });
    
    if (hasResults) {
        usuarioSelect.classList.add('usuario-filtered');
        // Si solo hay una opción que coincide exactamente, seleccionarla
        if (usuarioSelect.options.length === 2) { // 1 opción + la opción vacía
            usuarioSelect.selectedIndex = 1;
        }
    } else {
        usuarioSelect.classList.add('usuario-filtered');
    }
});

// Permitir selección con Enter en modo búsqueda
usuarioSearch.addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        if (usuarioSelect.options.length === 2) { // Si solo hay una opción disponible
            usuarioSelect.selectedIndex = 1;
            clearSearchBtn.click(); // Volver al modo select
        }
    }
});

// Función para restaurar todas las opciones
function restoreAllOptions() {
    usuarioSelect.innerHTML = '';
    originalOptions.forEach(option => {
        const newOption = document.createElement('option');
        newOption.value = option.value;
        newOption.text = option.text;
        usuarioSelect.appendChild(newOption);
    });
}

// Al enviar el formulario, asegurar que el valor esté en el select
document.querySelector('form').addEventListener('submit', function(e) {
    if (isSearchMode) {
        // Si estamos en modo búsqueda, verificar si hay una selección válida
        if (usuarioSelect.selectedIndex > 0) {
            // Hay una selección válida, continuar
        } else {
            alert('Por favor seleccione un usuario válido de la lista filtrada.');
            e.preventDefault();
            return;
        }
    }
    
    var documento = usuarioSelect.value;
    var usuarioTexto = usuarioSelect.options[usuarioSelect.selectedIndex].text;
    var libro = document.getElementById('libro').options[document.getElementById('libro').selectedIndex].text;
    
    if (!confirm('¿Confirma el registro del préstamo?\n\nUsuario: ' + usuarioTexto + '\nLibro: ' + libro)) {
        e.preventDefault();
    }
});

// Event listeners para validación de libro
document.getElementById('libro').addEventListener('change', function() {
    var selectedOption = this.options[this.selectedIndex];
    if (selectedOption.value) {
        console.log('Libro seleccionado: ' + selectedOption.text);
    }
});
</script>

</body>
</html>