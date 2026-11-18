# Blog - Aplicación Móvil

## Descripción del proyecto

Este proyecto consiste en una aplicación móvil de tipo blog desarrollada con Flutter, conectada a una API REST creada con FastAPI y una base de datos MySQL.

La aplicación permite a los usuarios consultar publicaciones, iniciar sesión, registrarse e interactuar mediante comentarios. También cuenta con funciones administrativas para gestionar el contenido.

## Tecnologías utilizadas

### Frontend
- Flutter
- Dart

### Backend
- Python
- FastAPI
- SQLAlchemy
- PyMySQL
- JWT para autenticación
- Argon2 para el cifrado de contraseñas

### Base de datos
- MySQL

## Funcionalidades principales

- Registro de usuarios.
- Inicio y cierre de sesión.
- Autenticación mediante tokens.
- Consulta de publicaciones.
- Visualización del detalle de cada publicación.
- Registro y consulta de comentarios.
- Identificación del usuario que realiza cada comentario.
- Control de permisos según el tipo de usuario.
- Gestión administrativa de usuarios y publicaciones.

## Estructura del proyecto

```text
blog_aplicacion_movil/
│
├── backend_API/
│   ├── database.py
│   ├── main.py
│   ├── models.py
│   ├── schemas.py
│   ├── requirements.txt
│   └── .env.example
│
├── database/
│   └── bd_aplicacion_movil.sql
│
├── flutter_application_1/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── windows/
│   └── pubspec.yaml
│
├── .gitignore
└── README.md
```

## Requisitos para ejecutar el proyecto

Antes de iniciar, es necesario contar con:

- Python instalado.
- Flutter instalado y configurado.
- MySQL o XAMPP.
- Git.
- Un editor de código, como Visual Studio Code.

## Configuración de la base de datos

1. Iniciar el servicio de MySQL.
2. Crear o importar la base de datos utilizando el archivo:

```text
database/bd_aplicacion_movil.sql
```

3. Verificar que la base de datos se llame:

```text
bd_aplicacion_movil
```

## Configuración de variables de entorno

Dentro de la carpeta principal del proyecto, copiar la plantilla de configuración:

```powershell
Copy-Item backend_API/.env.example backend_API/.env
```

Abrir el archivo `backend_API/.env` y configurar los datos de conexión:

```env
DB_USER=root
DB_PASSWORD=
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=bd_aplicacion_movil

SECRET_KEY=TU_CLAVE_SECRETA
```

**Importante:**

- Modificar los datos según la configuración de MySQL del equipo.
- Si se utiliza XAMPP con MySQL en el puerto 3307, cambiar `DB_PORT=3307`.
- Generar una clave secreta propia para `SECRET_KEY`.
- No compartir ni subir el archivo `.env` a GitHub.
- El archivo `.env.example` funciona como plantilla y sí puede compartirse.

## Instalación y ejecución del backend

Desde PowerShell, ubicarse en la carpeta principal del proyecto y ejecutar:

```powershell
cd backend_API
```

Crear el entorno virtual:

```powershell
python -m venv venv
```

Activar el entorno virtual:

```powershell
.\venv\Scripts\Activate.ps1
```

Instalar las dependencias:

```powershell
pip install -r requirements.txt
```

Iniciar el servidor:

```powershell
uvicorn main:app --reload
```

La API estará disponible en:

```text
http://127.0.0.1:8000
```

La documentación interactiva de los endpoints se encuentra en:

```text
http://127.0.0.1:8000/docs
```

## Instalación y ejecución del frontend

Abrir una nueva terminal de PowerShell y ubicarse en la carpeta principal del proyecto.

Entrar a la carpeta de Flutter:

```powershell
cd flutter_application_1
```

Instalar las dependencias:

```powershell
flutter pub get
```

Verificar la configuración de conexión con la API en:

```text
lib/services/api_config.dart
```

Asegurarse de utilizar la dirección IP o URL correspondiente al dispositivo donde se ejecutará la aplicación.

Iniciar la aplicación:

```powershell
flutter run
```

## Repositorio

El código fuente del proyecto se encuentra disponible en GitHub:

[https://github.com/023000526-cmd/blog_aplicacion_movil](https://github.com/023000526-cmd/blog_aplicacion_movil)

## Autor

Michell Vargas