
import os
from datetime import datetime, timedelta, timezone

from dotenv import load_dotenv
from jose import JWTError, jwt
from pwdlib import PasswordHash

from fastapi import (
    FastAPI,
    Depends,
    HTTPException,
    status,
)
from fastapi.security import (
    OAuth2PasswordBearer,
    OAuth2PasswordRequestForm,
)
from fastapi.middleware.cors import CORSMiddleware

from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from database import obtener_sesion
from models import Usuario, Blog, Comentario

from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    LoginRequest,
    LoginRespuesta,
    BlogCrear,
    BlogRespuesta,
    ComentarioCrear,
    ComentarioRespuesta,
)


# ---------- CONFIGURACION ----------

load_dotenv()

SECRET_KEY = os.getenv("SECRET_KEY")

if not SECRET_KEY:
    raise RuntimeError(
        "Falta configurar SECRET_KEY en el archivo .env"
    )

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

password_hash = PasswordHash.recommended()

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/token"
)

app = FastAPI(
    title="API de aplicación móvil",
    version="1.0.0",
    description="API para usuarios, publicaciones y comentarios",
)


# ---------- CORS ----------

app.add_middleware(
    CORSMiddleware,
    allow_origins=[],
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- AUTENTICACION JWT ----------

def crear_token(usuario: Usuario):
    fecha_expiracion = (
        datetime.now(timezone.utc)
        + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    datos_token = {
        "sub": str(usuario.id_usr),
        "exp": fecha_expiracion,
    }

    return jwt.encode(
        datos_token,
        SECRET_KEY,
        algorithm=ALGORITHM,
    )


def obtener_usuario_actual(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(obtener_sesion),
):
    error = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No autorizado. Inicia sesión nuevamente.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        contenido = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM],
        )

        usuario_id = contenido.get("sub")

        if usuario_id is None:
            raise error

        usuario_id = int(usuario_id)

    except (JWTError, ValueError):
        raise error

    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise error

    return usuario


def verificar_administrador(
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    if usuario.tip_usu != 1:
        raise HTTPException(
            status_code=403,
            detail="No tienes permisos de administrador",
        )

    return usuario


# ---------- INICIO ----------

@app.get("/")
def inicio():
    return {
        "mensaje": "API funcionando correctamente"
    }


# ---------- USUARIOS ----------

@app.get(
    "/usuarios",
    response_model=list[UsuarioRespuesta],
)
def listar_usuarios(
    db: Session = Depends(obtener_sesion),
    administrador: Usuario = Depends(verificar_administrador),
):
    return db.scalars(
        select(Usuario).order_by(Usuario.id_usr)
    ).all()


@app.post(
    "/usuarios",
    response_model=UsuarioRespuesta,
    status_code=201,
)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    nombre = datos.nom_usr.strip()
    correo = datos.mail.strip().lower()

    if not nombre or not correo or not datos.password:
        raise HTTPException(
            status_code=422,
            detail="Completa todos los campos obligatorios",
        )

    if len(datos.password) < 8:
        raise HTTPException(
            status_code=422,
            detail="La contraseña debe tener al menos 8 caracteres",
        )

    usuario = Usuario(
        nom_usr=nombre,
        mail=correo,
        pass_hash=password_hash.hash(datos.password),
        dir_usr=datos.dir_usr,
        tip_usu=2,
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


# ---------- INICIO DE SESION PARA FLUTTER ----------

@app.post(
    "/login",
    response_model=LoginRespuesta,
)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    if usuario is None or not password_hash.verify(
        datos.password,
        usuario.pass_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    token = crear_token(usuario)

    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "dir_usr": usuario.dir_usr,
        "tip_usu": usuario.tip_usu,
        "access_token": token,
        "token_type": "bearer",
    }


# ---------- TOKEN PARA SWAGGER ----------

@app.post("/token")
def obtener_token(
    datos: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(obtener_sesion),
):
    correo = datos.username.strip().lower()

    usuario = db.scalar(
        select(Usuario).where(Usuario.mail == correo)
    )

    if usuario is None or not password_hash.verify(
        datos.password,
        usuario.pass_hash,
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    token = crear_token(usuario)

    return {
        "access_token": token,
        "token_type": "bearer",
    }


# ---------- ACTUALIZAR USUARIO ----------

@app.put(
    "/usuarios/{usuario_id}",
    response_model=UsuarioRespuesta,
)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
    administrador: Usuario = Depends(verificar_administrador),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    nombre = datos.nom_usr.strip()
    correo = datos.mail.strip().lower()

    if not nombre or not correo:
        raise HTTPException(
            status_code=422,
            detail="El nombre y el correo son obligatorios",
        )

    usuario.nom_usr = nombre
    usuario.mail = correo
    usuario.dir_usr = datos.dir_usr
    usuario.tip_usu = datos.tip_usu

    try:
        db.commit()
        db.refresh(usuario)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return usuario


# ---------- ELIMINAR USUARIO ----------

@app.delete("/usuarios/{usuario_id}")
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
    administrador: Usuario = Depends(verificar_administrador),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    db.delete(usuario)
    db.commit()

    return {
        "mensaje": "Usuario eliminado correctamente"
    }


# ---------- PUBLICACIONES ----------

@app.get(
    "/blog",
    response_model=list[BlogRespuesta],
)
def listar_blog(
    db: Session = Depends(obtener_sesion),
):
    return db.scalars(
        select(Blog).order_by(Blog.id_blog)
    ).all()


@app.post(
    "/blog",
    response_model=BlogRespuesta,
    status_code=201,
)
def crear_blog(
    datos: BlogCrear,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(verificar_administrador),
):
    titulo = datos.titulo.strip()

    if not titulo:
        raise HTTPException(
            status_code=422,
            detail="El título no puede estar vacío",
        )

    nuevo = Blog(
        titulo=titulo,
        descripcion=(
            datos.descripcion.strip()
            if datos.descripcion and datos.descripcion.strip()
            else None
        ),
        img=(
            datos.img.strip()
            if datos.img and datos.img.strip()
            else None
        ),
        tags=(
            datos.tags.strip()
            if datos.tags and datos.tags.strip()
            else None
        ),
        usr_id=usuario.id_usr,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo


@app.get(
    "/blog/{blog_id}",
    response_model=BlogRespuesta,
)
def obtener_blog(
    blog_id: int,
    db: Session = Depends(obtener_sesion),
):
    publicacion = db.get(Blog, blog_id)

    if publicacion is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    return publicacion


# ---------- COMENTARIOS ----------

@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(
    db: Session = Depends(obtener_sesion),
):
    resultado = db.execute(
        select(
            Comentario,
            Usuario.nom_usr,
        )
        .outerjoin(
            Usuario,
            Comentario.usr_id == Usuario.id_usr,
        )
        .order_by(Comentario.id_com)
    ).all()

    comentarios = []

    for comentario, nombre_usuario in resultado:
        comentarios.append({
            "id_com": comentario.id_com,
            "comentario": comentario.comentario,
            "fecha": comentario.fecha,
            "estatus": comentario.estatus,
            "usr_id": comentario.usr_id,
            "blog_id": comentario.blog_id,
            "nombre_usuario": nombre_usuario or "Usuario eliminado",
        })

    return comentarios


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
    usuario: Usuario = Depends(obtener_usuario_actual),
):
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=usuario.id_usr,
        blog_id=datos.blog_id,
        estatus=1,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo
