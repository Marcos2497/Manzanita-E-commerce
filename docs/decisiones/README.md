# Decisiones de arquitectura (ADR)

Un ADR (Architecture Decision Record, registro de decisión de arquitectura) es un documento corto que registra una decisión técnica importante: el contexto en que se tomó, qué se decidió, qué alternativas se descartaron y qué consecuencias tiene. Sirve para que cualquiera que llegue al proyecto entienda por qué las cosas son como son.

Cada ADR tiene un número correlativo y no se reescribe: si una decisión cambia, se crea un ADR nuevo que la reemplaza y el anterior pasa a estado "Reemplazada por ADR XXXX".

> Las ADR 0001 a 0005 se registraron después de tomar las decisiones (noviembre de 2026).

## Índice

| Número | Decisión | Estado |
|---|---|---|
| [0001](0001-stack-django-htmx.md) | Stack Django + HTMX | Aceptada |
| [0002](0002-postgresql-neon.md) | PostgreSQL en Neon | Aceptada |
| [0003](0003-hosting-vm-gcp.md) | Hosting en una VM de Google Cloud | Aceptada |
| [0004](0004-imagenes-cloudflare-r2.md) | Imágenes en Cloudflare R2 | Aceptada |
| [0005](0005-logica-en-python-triggers-auditoria.md) | Lógica de negocio en Python, triggers solo para auditoría | Aceptada |

## Plantilla

Cada ADR ocupa como máximo una página.

```markdown
# ADR 0000: Título
- Estado: Propuesta | Aceptada | Reemplazada por ADR XXXX
- Fecha: AAAA-MM-DD
## Contexto
## Decisión
## Alternativas descartadas
## Consecuencias
```
