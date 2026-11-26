# ADR 0005: Lógica de negocio en Python, triggers solo para auditoría
- Estado: Aceptada
- Fecha: 2026-11-25

## Contexto
Hay un solo desarrollador. El código se tiene que poder testear y leer en un solo lugar. Hay interés en usar triggers y procedimientos, pero con criterio.

## Decisión
- La lógica (armar pedidos, precios, pagos) va en Python y se testea con los tests de Django.
- La integridad se asegura con `CheckConstraint` y `UniqueConstraint`.
- Un trigger de PostgreSQL llena el historial de estados del pedido.
- Los reportes salen de vistas SQL, leídas con modelos `managed = False`.
- Todo el SQL va en migraciones con `RunSQL` y `reverse_sql`.
- Los pedidos vencen de forma perezosa (campo `vence_el`), sin tareas programadas.

## Alternativas descartadas
- **Lógica en procedimientos almacenados:** dos lenguajes y más difícil de testear.
- **Señales de Django para la auditoría:** no se ejecutan con `QuerySet.update()` ni con `bulk_create`.
- **Cron para el vencimiento:** contradice la regla de no depender de tareas programadas.

## Consecuencias
- El SQL de las migraciones necesita sus propios tests.
- El estado "vencido" se calcula al consultar, no se guarda.
