# Manzanitas: tienda online

Tienda online para un emprendimiento de marroquinería y costura creativa. La dueña (no técnica) administra todo desde el panel de Django. Respondé en español rioplatense.

## Stack
- Python 3.13, Django 6.1 (actualizar a 6.2 LTS cuando salga, abril 2027).
- Panel de administración: django-unfold.
- Tienda: plantillas de Django + HTMX (django-htmx) + Alpine.js + Tailwind. Para respuestas HTMX usar template partials de Django 6.
- Base de datos: PostgreSQL 17. Desarrollo: servicio `db` del docker-compose. Producción: Neon. La conexión siempre sale de `DATABASE_URL` (dj-database-url con `conn_health_checks=True`, porque Neon se apaga tras 5 min sin uso).
- Estáticos con WhiteNoise.
- Fotos de productos (media): en producción van a Cloudflare R2 con django-storages (backend S3); en desarrollo se guardan en disco local (`media/`). El backend se elige por variables de entorno: si está definida `R2_BUCKET` se usa R2; si no, disco local.
- Solo las fotos de productos van en el bucket público. Los comprobantes de pago van en un bucket privado y se ven con URL firmada.
- Fotos optimizadas: al subirlas se guarda una versión de máximo 1600 px de lado en WebP, para no servir fotos de celular de varios MB. Se implementa cuando armemos los modelos del catálogo.

## Cómo se trabaja
- Todo corre en Docker. Levantar: `docker compose up`. Comandos de Django: `docker compose run --rm web python manage.py <comando>`.
- No instalar paquetes en el sistema: agregarlos a `requirements.txt` y reconstruir con `docker compose build`.
- Los secretos van solo en `.env` (nunca al repo ni a la imagen). `.env.example` documenta las variables.
- Portabilidad: en producción nada puede depender del disco local ni de tareas programadas (cron), y toda la configuración sale de variables de entorno.
- Las decisiones de arquitectura están en docs/decisiones/. Si una tarea contradice un ADR, avisame antes de seguir.

## Flujo de trabajo
- Al empezar una sesión: correr `gh issue list` y proponer el próximo issue del milestone abierto.
- Una rama por issue: `feat/<número>-<descripcion-corta>` (o `fix/`, `docs/`).
- Commits con Conventional Commits en español, ej. `feat(catalogo): agregar variantes`.
- Al terminar: comentar en el issue qué se hizo, qué problemas aparecieron y cómo se resolvieron, y abrir el PR con `Closes #<número>`.
- No crear ni cerrar issues sin mostrarme antes el texto.

## Producción (todavía no armada)
- Máquina virtual e2-micro de Google Cloud (plan gratis, región us-east1) + Neon (PostgreSQL) + Cloudflare R2 (fotos). Descartamos Vercel: su plan gratis no permite uso comercial y su límite de 4,5 MB por request complica subir fotos desde el panel.
- En la VM, Docker Compose: `web` (Gunicorn, 2 workers) + `caddy` (solo proxy HTTPS hacia Gunicorn; no sirve /media).
- 1 GB de RAM: swap activado y la imagen se construye en GitHub Actions, no en el servidor.
- Dominio registrado en DonWeb, con el DNS en Cloudflare (en DonWeb solo se cambian los nameservers). El registro A de la VM va en "DNS only" (nube gris) para que Caddy saque el certificado sin problemas.
- Las fotos se sirven desde un subdominio propio conectado al bucket de R2 (ej. `img.<dominio>`, variable `R2_PUBLIC_DOMAIN`). Nunca usar la URL r2.dev en producción: tiene límite de tráfico y es solo para pruebas.
- Alerta de presupuesto de USD 1 en GCP para enterarnos si algo se sale del plan gratis.

## Modelo del negocio
- Categorías → productos (modelos) → variantes. Todo producto tiene al menos una variante.
- Atributos genéricos (Color, Tamaño, Material) con valores; los colores guardan un hex.
- Personalizaciones opcionales por producto (ej. "Bordado con nombre o inicial": precio extra, requiere texto de hasta 10 letras).
- Los ítems de un pedido guardan una copia del nombre, la variante y el precio del momento de la compra.
- Formas de pago:
  - Transferencia (principal, sin comisión): el pedido queda "pendiente de pago", el cliente manda el comprobante por WhatsApp o lo sube, la dueña lo confirma en el panel. Los pedidos sin pagar vencen a las 48 h, sin tareas programadas: el pedido guarda `vence_el` y uno pendiente de pago con `vence_el` en el pasado se considera vencido al consultarlo (método del modelo o del manager). Sin cron.
  - Efectivo (al retirar o al recibir).
  - Mercado Pago Checkout Pro: programado pero apagado con una opción de configuración. Un pago se da por aprobado solo cuando llega el webhook, nunca por la URL de retorno.
- La tabla de pagos está separada de la de pedidos: monto, comprobante, quién lo confirmó y cuándo, y `mp_payment_id` único cuando corresponde.
- Entrega: retiro en el taller (sin cargo) o envío a domicilio (costo a coordinar por WhatsApp).
- Aviso del pedido: link de WhatsApp (wa.me) con el resumen armado + pedido visible en el panel.
- Fase 2 (no implementar todavía, pero no bloquearla): disponibilidad por variante, materiales con unidad y stock, receta de consumo por variante y movimientos de stock.
- Devoluciones: los productos personalizados o hechos a pedido no tienen derecho de arrepentimiento (avisarlo en el checkout). Los productos estándar sí: 10 días y botón de arrepentimiento visible en el inicio.
- Plata en `DecimalField(max_digits=12, decimal_places=2)`, cantidades de material en `DecimalField(max_digits=10, decimal_places=3)`, estados con `TextChoices`, borrado lógico en el catálogo.

## Pendiente para el bootstrap de Django
Todavía no existe `config/settings.py`. Al crearlo:
- Almacenamiento (adaptar si hace falta):

```python
if os.environ.get("R2_BUCKET"):
    default_storage = {
        "BACKEND": "storages.backends.s3.S3Storage",
        "OPTIONS": {
            "bucket_name": os.environ["R2_BUCKET"],
            "endpoint_url": os.environ["R2_ENDPOINT_URL"],
            "access_key": os.environ["R2_ACCESS_KEY_ID"],
            "secret_key": os.environ["R2_SECRET_ACCESS_KEY"],
            "custom_domain": os.environ["R2_PUBLIC_DOMAIN"],
            "region_name": "auto",
            "signature_version": "s3v4",
            "querystring_auth": False,
            "file_overwrite": False,
        },
    }
else:
    default_storage = {"BACKEND": "django.core.files.storage.FileSystemStorage"}

STORAGES = {
    "default": default_storage,
    "staticfiles": {"BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"},
}
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"
```

- En `config/urls.py`, servir media con `static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)` solo cuando `DEBUG` esté activo.
- Borrar esta sección cuando esté aplicado.

## Diseño
- Prototipo aprobado por la clienta: `docs/prototipo.html` (abrirlo en el navegador). Es la referencia de pantallas, textos y comportamiento.
- Celular primero. Colores: fondo #FFF5F8, texto #2B1A20, botones #D6286A, precios y links #C91E5E, puntada #EE3875, rosa claro #FCE4EC, texto secundario #6E5560.
- Tipografías: Dancing Script (títulos de marca) y Nunito (todo lo demás). Detalle de marca: bordes punteados tipo costura.
