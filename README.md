¡Absolutamente\! Insertaré las imágenes en la sección de "Capturas de Pantalla" y ajustaré sus tamaños para que se vean bien en el README.

Aquí tienes la versión actualizada de tu `README.md` con las imágenes incluidas y con un tamaño más manejable:

-----

# 🚀 Sports-Social-Media

Una **red social deportiva multiplataforma** que te permite gestionar perfiles, compartir publicaciones y realizar un seguimiento detallado de estadísticas de rendimiento deportivo en tiempo real.

-----

### ✨ **Visión General del Proyecto**

Esta aplicación está diseñada para conectar a deportistas y aficionados, ofreciendo un espacio dinámico para compartir experiencias y un robusto sistema para registrar y analizar el progreso deportivo.

  * **Frontend (Aplicación Móvil):** Desarrollada con **Flutter**. Ofrece una interfaz de usuario fluida y nativa para iOS y Android, permitiendo a los usuarios interactuar con la red social y visualizar sus datos deportivos.
  * **Backend (API):** Construido con **Node.js**. Proporciona la lógica de negocio, autenticación de usuarios, gestión de publicaciones y el procesamiento de todas las estadísticas deportivas.
  * **Base de Datos:** Utiliza **PostgreSQL** para un almacenamiento eficiente y seguro de datos relacionales, garantizando la integridad de perfiles, posts y métricas deportivas.

-----

### 📸 **Capturas de Pantalla**

<img width="375" height="667" alt="9_ PROFILE" src="https://github.com/user-attachments/assets/365397f2-d763-431d-972a-65d3f5f130d5" />
<img width="375" height="667" alt="9_Home" src="https://github.com/user-attachments/assets/962b5a88-c600-47c3-89bb-5e5411a94bc8" />


-----

### 🚀 **¿Cómo Ejecutar la Aplicación (Flutter)?**

Sigue estos pasos para poner en marcha la aplicación Flutter en tu entorno local:

#### **Prerequisitos**

Asegúrate de tener instalado:

  * **Flutter SDK:** [Instrucciones de instalación](https://flutter.dev/docs/get-started/install)
  * **Editor de Código:** Recomendado [VS Code](https://code.visualstudio.com/) con el plugin de Flutter, o Android Studio.
  * **Dispositivo/Emulador:** Un dispositivo físico o emulador/simulador configurado para Android o iOS.

#### **Pasos de Ejecución**

1.  **Clonar el repositorio:**

    ```bash
    git clone https://github.com/DevIDDiaz850/Sports-Social-Media.git
    cd Sports-Social-Media/flutter_app_folder # Reemplaza con la ruta real de tu app Flutter
    ```

2.  **Instalar dependencias:**

    ```bash
    flutter pub get
    ```

3.  **Verificar la configuración de Flutter:**

    ```bash
    flutter doctor
    ```

    Asegúrate de que no haya problemas reportados.

4.  **Ejecutar la aplicación:**

      * **Desde la línea de comandos:**
        Asegúrate de tener un dispositivo o emulador conectado y funcionando.
        ```bash
        flutter run
        ```
      * **Desde VS Code:**
        Abre la carpeta del proyecto en VS Code. Ve a `Run > Start Debugging` o presiona `F5`. Selecciona el dispositivo/emulador en la barra de estado inferior derecha.

-----

### ⚙️ **Configuración del Backend (API - Node.js)**

Para que la aplicación Flutter funcione correctamente, necesitarás configurar y levantar el API de Node.js.

1.  **Clonar el repositorio del backend (si está separado):**

    ```bash
    git clone https://github.com/DevIDDiaz850/Sports-Social-Media-API.git # Ejemplo: si tu API está en otro repo
    cd Sports-Social-Media-API # Navega a la carpeta de tu API
    ```

    *(Si tu API está dentro del mismo repositorio principal, ajusta la ruta `cd` accordingly.)*

2.  **Instalar dependencias de Node.js:**

    ```bash
    npm install
    ```

3.  **Configurar variables de entorno:**
    Crea un archivo `.env` en la raíz del proyecto y añade las siguientes variables (ajusta según las que realmente necesite tu API):

    ```
    # Ejemplo de .env
    PORT=3000
    DATABASE_URL=postgres://user:password@host:port/database_name
    JWT_SECRET=supersecretkey
    ```

4.  **Ejecutar migraciones de base de datos (si aplica con PostgreSQL):**

    ```bash
    npm run migrate # O el comando que uses para tus migraciones (ej. npx sequelize-cli db:migrate)
    ```

5.  **Iniciar el servidor Node.js:**

    ```bash
    npm start # O node server.js, dependiendo de tu script de inicio
