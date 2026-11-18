# Blog - Aplicación Móvil



## Descripción

Proyecto de una aplicación móvil de blog desarrollada con Flutter, FastAPI y MySQL. Permite gestionar usuarios, iniciar sesión y consultar publicaciones y comentarios.



## Tecnologías utilizadas



- **Flutter:** desarrollo de la aplicación móvil.

- **Dart:** lenguaje de programación del frontend.

- **FastAPI:** desarrollo de la API REST.

- **Python:** lenguaje de programación del backend.

- **MySQL:** gestión de la base de datos.

- **SQLAlchemy:** conexión y manejo de datos.

- **JWT:** autenticación de usuarios.



## Funcionalidades principales



- Registro de usuarios.

- Inicio y cierre de sesión.

- Autenticación mediante token.

- Consulta de publicaciones.

- Visualización de detalles de publicaciones.

- Registro y consulta de comentarios.

- Identificación de usuarios administradores.

- Restricción de funciones administrativas mediante permisos.



## Estructura del proyecto



```text

blog_aplicacion_movil/

├── backend_API/

│   ├── database.py

│   ├── main.py

│   ├── models.py

│   ├── schemas.py

│   └── requirements.txt

├── database/

│   └── bd_aplicacion_movil.sql

├── flutter_application_1/

│   ├── lib/

│   ├── android/

│   ├── ios/

│   ├── web/

│   └── pubspec.yaml

├── .gitignore

└── README.md

```



## Requisitos



- Python instalado.

- Flutter instalado.

- MySQL instalado.

- Git instalado.



## Configuración de la base de datos



1\. Iniciar el servicio de MySQL.

2\. Crear o importar la base de datos utilizando el archivo `database/bd_aplicacion_movil.sql`.

3\. Configurar las credenciales de conexión en un archivo `.env` dentro de `backend_API`.



Ejemplo de configuración:



```env

DB_HOST=127.0.0.1

DB_PORT=3307

DB_USER=root

DB_PASSWORD=

DB_NAME=bd_aplicacion_movil

SECRET_KEY=coloca_una_clave_segura

```



No compartir el archivo `.env` ni subirlo a GitHub.



## Instalación del backend



Desde PowerShell:



```powershell

cd backend_API

python -m venv venv

.\\venv\\Scripts\\Activate.ps1

pip install -r requirements.txt

uvicorn main:app --reload

```



La documentación de la API estará disponible en:



http://127.0.0.1:8000/docs



## Instalación del frontend



Desde otra terminal:



```powershell

cd flutter_application_1

flutter pub get

flutter run

```



Antes de ejecutar la aplicación, configurar la dirección de la API en el archivo correspondiente de `lib/services/api_config.dart`.



## Repositorio



GitHub: https://github.com/023000526-cmd/blog_aplicacion_movil



## Autor



michell Vargas
