# ADR 0003: Hosting en una VM de Google Cloud
- Estado: Aceptada
- Fecha: 2026-11-25

## Contexto
Se busca costo cero para un sitio comercial. El dominio está registrado en DonWeb y el proyecto corre en Docker.

## Decisión
- VM e2-micro del plan gratis de GCP en us-east1 (1 GB de RAM, 30 GB de disco, 1 GB de salida por mes).
- Docker Compose con `web` (Gunicorn, 2 workers) + `caddy` (HTTPS automático).
- La imagen se construye en GitHub Actions, no en el servidor.
- Swap activado.
- Alerta de presupuesto de USD 1.
- DNS en Cloudflare, con el registro A en "DNS only".

## Alternativas descartadas
- **Vercel:** el plan Hobby es solo para uso personal no comercial y el Pro cuesta USD 20 por miembro por mes. Además, el límite de 4,5 MB por request complica subir fotos, el cron del plan Hobby corre una vez por día y producción no usaría Docker.
- **Render gratis:** se duerme a los 15 minutos, el disco es efímero y el Postgres gratis vence a los 30 días.
- **Cloud Run:** el dominio propio está en preview; la alternativa es un balanceador de unos USD 18 por mes.
- **Oracle Always Free:** recupera las instancias inactivas.

## Consecuencias
- El mantenimiento del servidor queda a nuestro cargo (actualizaciones, firewall).
- Solo hay 1 GB de RAM.
- Regla de portabilidad: nada depende del disco local ni de tareas programadas, para poder migrar si la clienta paga un hosting.
