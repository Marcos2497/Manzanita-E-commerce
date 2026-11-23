# syntax=docker/dockerfile:1
# Imagen de la tienda Manzanitas (Django). La misma imagen sirve para desarrollo y producción:
# en desarrollo, docker-compose.yml monta el código y cambia el comando por runserver.
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Usuario sin privilegios con el mismo UID/GID que tu usuario de Linux,
# para que los archivos que cree Django (migraciones, startproject) queden a tu nombre.
ARG UID=1000
ARG GID=1000
RUN groupadd --gid ${GID} app \
    && useradd --uid ${UID} --gid ${GID} --create-home app

WORKDIR /app

# Primero las dependencias: así Docker reutiliza esta capa si solo cambia el código.
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY --chown=app:app . .

USER app

EXPOSE 8000

# Comando de producción. En desarrollo lo reemplaza docker-compose.yml.
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-"]
