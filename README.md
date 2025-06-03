# POO-BIBLIOTECA
# 📚 Sistema de Biblioteca - JSP + Servlets + MySQL

Este proyecto es una aplicación web de gestión de biblioteca desarrollada en Java usando JSP, Servlets y MySQL como base de datos. Fue creada con **NetBeans** y ejecutada sobre **Apache Tomcat**.

---

## 🚀 Tecnologías Usadas

- Java EE (JSP/Servlets)
- Apache Tomcat (v9 o superior)
- MySQL 8.0+
- JDBC (`mysql-connector-j-8.0.31.jar`)
- HTML/CSS
- NetBeans IDE

---

## 📂 Estructura del Proyecto

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
│ ├── context.xml
│ └── MANIFEST.MF
└── WEB-INF/
├── classes/
│ ├── dao/
│ ├── modelo/
│ ├── servlets/
│ └── utils/conexion.class
├── lib/mysql-connector-j-8.0.31.jar
└── web.xml


---

## 🛠️ Configuración e Instalación

### 1. Clonar o Abrir el Proyecto

Abre NetBeans y selecciona `Archivo > Abrir Proyecto`, luego elige la carpeta raíz del proyecto.

---

### 2. Configurar la Base de Datos

1. Crear la base de datos:

```sql
CREATE DATABASE biblioteca;```
### mportar el archivo biblioteca.sql
mysql -u TU_USUARIO -p biblioteca < biblioteca.sql

Configurar la Conexión JDBC
Revisa el archivo conexion.class en utils/ y asegúrate de que contiene algo como esto:

java
Copiar
Editar
String url = "jdbc:mysql://localhost:3306/biblioteca";
String user = "root";
String password = "";

 Agregar el Conector MySQL
Asegúrate de que mysql-connector-j-8.0.31.jar esté en la carpeta WEB-INF/lib.

Si NetBeans no lo detecta:

Click derecho en el proyecto > Propiedades > Bibliotecas > Agregar JAR/Carpeta.

5. Configurar y Ejecutar con Tomcat
En NetBeans, ir a Servicios > Servidores.

Agrega tu instalación de Apache Tomcat.

Click derecho sobre el proyecto > Propiedades > Ejecutar.

Selecciona Tomcat como servidor y asegúrate que el contexto base sea /.

Ejecutar el Proyecto
Click derecho en el proyecto > Limpiar y construir.

Luego haz click en Ejecutar.

El navegador debería abrir http://localhost:8080/.

🧪 Acceso de Prueba
Puedes ingresar usando usuarios precargados en la base de datos. Ejemplo:

Correo: santi@gmail.com

Contraseña: 1234

🔑 Funcionalidades del Sistema
📖 Registro y visualización de libros

🔁 Gestión de préstamos (activos y devueltos)

👤 Gestión de usuarios (registro, login)

🧾 Historial de préstamos

📉 Control de disponibilidad y multas

👨‍💻 Autor
Santiago Rueda Quintero
Eliecer Guevara Fuentes
