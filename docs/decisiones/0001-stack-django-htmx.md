# ADR 0001: Stack Django + HTMX
- Estado: Aceptada
- Fecha: 2026-11-25

## Contexto
La tienda es para una clienta no técnica que carga todo desde un panel. Hay un solo desarrollador. Se busca desarrollo rápido, Python por su valor para el portfolio y una dinámica tipo Livewire (ya usada con Laravel).

## Decisión
- Django 6.1 (actualizar a 6.2 LTS en abril de 2027).
- Panel de administración con django-unfold.
- Tienda con plantillas de Django + HTMX (django-htmx) + Alpine.js + Tailwind.
- Template partials de Django 6 para las respuestas HTMX.

## Alternativas descartadas
- **Laravel + Livewire:** ya conocido, no suma Python.
- **API con Django REST + SPA en React o Vue:** son dos proyectos, lleva más tiempo y tiene peor SEO por defecto.
- **FastAPI o Flask:** no traen panel de administración ni ORM integrados, habría que construirlos.

## Consecuencias
- El panel sale casi gratis.
- El renderizado en el servidor es liviano en celulares.
- La interactividad compleja queda limitada a lo que cubren HTMX y Alpine.
- Un solo proyecto y un solo lenguaje.
