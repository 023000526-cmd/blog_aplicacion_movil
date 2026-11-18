
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class UsuarioCrear(BaseModel):
    nom_usr: str
    mail: str
    password: str
    dir_usr: str | None = None
    tip_usu: int = 2

class UsuarioActualizar(BaseModel):
    nom_usr: str
    mail: str
    dir_usr: str | None = None
    tip_usu: int = 2

class UsuarioRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_usr: int
    nom_usr: str
    mail: str
    dir_usr: str | None = None
    tip_usu: int

class LoginRequest(BaseModel):
    mail: str
    password: str

class LoginRespuesta(UsuarioRespuesta):
    access_token: str
    token_type: str = "bearer"

class BlogCrear(BaseModel):
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None

class BlogRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None
    usr_id: int | None = None

class ComentarioCrear(BaseModel):
    comentario: str
    blog_id: int


class ComentarioRespuesta(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id_com: int
    comentario: str
    fecha: datetime
    estatus: int
    usr_id: int | None = None
    blog_id: int
    nombre_usuario: str | None = None
