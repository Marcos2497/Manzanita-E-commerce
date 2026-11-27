# ADR 0004: Imágenes en Cloudflare R2
- Estado: Aceptada
- Fecha: 2026-11-25

## Contexto
Las fotos de producto son lo que más tráfico genera, la VM tiene 1 GB de salida por mes y las fotos de celular pesan varios MB.

## Decisión
- Cloudflare R2 con django-storages (backend S3). El plan gratis da 10 GB, 1 millón de operaciones clase A y 10 millones clase B por mes, sin costo de salida.
- Las fotos se sirven públicas desde un subdominio propio (`img.<dominio>`) conectado al bucket. El DNS pasa a Cloudflare y el dominio sigue registrado en DonWeb.
- En desarrollo se usa el disco local (sin `R2_BUCKET`).
- Las fotos se optimizan a WebP de hasta 1600 px.
- Los comprobantes de pago van en un bucket privado y se ven con URL firmada.

## Alternativas descartadas
- **Disco de la VM:** consume la salida mensual y ata los archivos al servidor.
- **URL r2.dev:** tiene límite de tráfico y es solo para pruebas.
- **AWS S3:** cobra la transferencia de salida.

## Consecuencias
- Una cuenta más (Cloudflare), que puede pedir un medio de pago para activar R2.
- Hay que mover los nameservers a Cloudflare.
