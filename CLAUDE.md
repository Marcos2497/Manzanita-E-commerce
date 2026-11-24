# Manzanitas: tienda online

Tienda online para un emprendimiento de marroquinería y costura creativa. La dueña (no técnica) administra todo desde el panel de Django. Respondé en español rioplatense.

## Stack
- Python 3.13, Django 6.1 (actualizar a 6.2 LTS cuando salga, abril 2027).
- Panel de administración: django-unfold.
- Tienda: plantillas de Django + HTMX (django-htmx) + Alpine.js + Tailwind. Para respuestas HTMX usar template partials de Django 6.
- Base de datos: PostgreSQL 17. Desarrollo: servicio `db` del docker-compose. Producción: Neon. La conexión siempre sale de `DATABASE_URL` (dj-database-url con `conn_health_checks=True`, porque Neon se apaga tras 5 min sin uso).
- Estáticos con WhiteNoise. Fotos de productos (media) en el disco del servidor.

## Cómo se trabaja
- Todo corre en Docker. Levantar: `docker compose up`. Comandos de Django: `docker compose run --rm web python manage.py <comando>`.
- No instalar paquetes en el sistema: agregarlos a `requirements.txt` y reconstruir con `docker compose build`.
- Los secretos van solo en `.env` (nunca al repo ni a la imagen). `.env.example` documenta las variables.

## Producción (todavía no armada)
- Máquina virtual e2-micro de Google Cloud (plan gratis, región us-east1) con Docker Compose: `web` (Gunicorn, 2 workers) + `caddy` (HTTPS automático, sirve /media).
- 1 GB de RAM: swap activado y la imagen se construye en GitHub Actions, no en el servidor.
- Dominio comprado en DonWeb, con un registro A apuntando a la IP de la máquina virtual.

## Modelo del negocio
- Categorías → productos (modelos) → variantes. Todo producto tiene al menos una variante.
- Atributos genéricos (Color, Tamaño, Material) con valores; los colores guardan un hex.
- Personalizaciones opcionales por producto (ej. "Bordado con nombre o inicial": precio extra, requiere texto de hasta 10 letras).
- Los ítems de un pedido guardan una copia del nombre, la variante y el precio del momento de la compra.
- Formas de pago:
  - Transferencia (principal, sin comisión): el pedido queda "pendiente de pago", el cliente manda el comprobante por WhatsApp o lo sube, la dueña lo confirma en el panel. Los pedidos sin pagar vencen a las 48 h.
  - Efectivo (al retirar o al recibir).
  - Mercado Pago Checkout Pro: programado pero apagado con una opción de configuración. Un pago se da por aprobado solo cuando llega el webhook, nunca por la URL de retorno.
- La tabla de pagos está separada de la de pedidos: monto, comprobante, quién lo confirmó y cuándo, y `mp_payment_id` único cuando corresponde.
- Entrega: retiro en el taller (sin cargo) o envío a domicilio (costo a coordinar por WhatsApp).
- Aviso del pedido: link de WhatsApp (wa.me) con el resumen armado + pedido visible en el panel.
- Fase 2 (no implementar todavía, pero no bloquearla): disponibilidad por variante, materiales con unidad y stock, receta de consumo por variante y movimientos de stock.
- Devoluciones: los productos personalizados o hechos a pedido no tienen derecho de arrepentimiento (avisarlo en el checkout). Los productos estándar sí: 10 días y botón de arrepentimiento visible en el inicio.
- Plata en `DecimalField(max_digits=12, decimal_places=2)`, cantidades de material en `DecimalField(max_digits=10, decimal_places=3)`, estados con `TextChoices`, borrado lógico en el catálogo.

## Diseño
- Prototipo aprobado por la clienta: `docs/prototipo.html` (abrirlo en el navegador). Es la referencia de pantallas, textos y comportamiento.
- Celular primero. Colores: fondo #FFF5F8, texto #2B1A20, botones #D6286A, precios y links #C91E5E, puntada #EE3875, rosa claro #FCE4EC, texto secundario #6E5560.
- Tipografías: Dancing Script (títulos de marca) y Nunito (todo lo demás). Detalle de marca: bordes punteados tipo costura.
