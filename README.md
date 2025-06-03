# 📚 POO-BIBLIOTECA - Sistema de Gestión de Biblioteca

Proyecto desarrollado en Java utilizando JSP, Servlets y MySQL. Permite la gestión de libros, usuarios y préstamos en una biblioteca. Implementado en **NetBeans IDE** y desplegado con **Apache Tomcat**.

---

## 🚀 Tecnologías Usadas

- Java EE (JSP/Servlets)
- Apache Tomcat (v9 o superior)
- MySQL 8.0+
- JDBC (`mysql-connector-j-8.0.31.jar`)
- HTML5 / CSS3
- NetBeans IDE

---

## 📂 Estructura del Proyecto

```plaintext
build/
└── web/
    ├── css/style.css
    ├── index.jsp
    ├── inicio.jsp
    ├── inventario.jsp
    ├── registrarLibro.jsp
    ├── PrestamosActivos.jsp
    ├── PrestamosRegistro.jsp
    ├── usuarios.jsp
    ├── navbar.jsp
    ├── META-INF/
    │   ├── context.xml
    │   └── MANIFEST.MF
    └── WEB-INF/
        ├── classes/
        │   ├── dao/
        │   ├── modelo/
        │   ├── servlets/
        │   └── utils/
        │       └── conexion.class
        ├── lib/
        │   └── mysql-connector-j-8.0.31.jar
        └── web.xml
```

---

## ⚙️ Configuración e Instalación

### 1. Clonar o Abrir el Proyecto

- Abre NetBeans y selecciona: `Archivo > Abrir Proyecto`.
- Navega a la carpeta raíz del proyecto y selecciónala.

---

### 2. Configurar la Base de Datos

1. Crear la base de datos:

```sql
CREATE DATABASE biblioteca;
```

2. Importar el archivo SQL:

```bash
mysql -u TU_USUARIO -p biblioteca < biblioteca.sql
```

---

### 3. Configurar la Conexión JDBC

Edita el archivo `conexion.class` dentro de la carpeta `utils/` para que contenga lo siguiente:

```java
String url = "jdbc:mysql://localhost:3306/biblioteca";
String user = "root";
String password = "";
```

> Asegúrate de que el usuario y contraseña coincidan con los de tu servidor MySQL.

---

### 4. Agregar el Conector MySQL

- Asegúrate de que el archivo `mysql-connector-j-8.0.31.jar` esté dentro de `WEB-INF/lib`.
- Si NetBeans no lo reconoce:
  - Click derecho sobre el proyecto > `Propiedades > Bibliotecas > Agregar JAR/Carpeta` > Selecciona el conector.

---

### 5. Configurar Tomcat

1. Ve a `Servicios > Servidores` en NetBeans.
2. Agrega tu instalación de **Apache Tomcat**.
3. Click derecho sobre el proyecto > `Propiedades > Ejecutar`.
4. Selecciona Tomcat como servidor y asegúrate que el contexto sea `/`.

---

### 6. Ejecutar el Proyecto

1. Click derecho sobre el proyecto > `Limpiar y construir`.
2. Luego haz click en `Ejecutar`.
3. Se abrirá en el navegador: `http://localhost:8080/`.

---

## 🧪 Acceso de Prueba

Puedes ingresar usando los siguientes datos de prueba precargados:

- **Correo:** `santi@gmail.com`
- **Contraseña:** `1234`

---

## 🔑 Funcionalidades del Sistema

- 📖 Registro y visualización de libros.
- 🔁 Gestión de préstamos (activos y devueltos).
- 👤 Gestión de usuarios (registro, login).
- 🧾 Historial de préstamos por usuario.
- 📉 Control de disponibilidad de libros y aplicación de multas.

---

## 👨‍💻 Autores

- Santiago Rueda Quintero  
- Eliecer Guevara Fuentes
