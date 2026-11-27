# ADR 0002: PostgreSQL en Neon
- Estado: Aceptada
- Fecha: 2026-11-25

## Contexto
Se busca costo cero. El modelo tiene que escalar a la fase 2 (stock y materiales) y se quieren usar restricciones, triggers y vistas.

## Decisión
- PostgreSQL 17.
- En desarrollo: el contenedor `db` del docker-compose.
- En producción: el plan gratis de Neon (1 GB por proyecto, 100 CU-horas por mes, se apaga a los 5 minutos sin uso y guarda 6 horas de historial para restaurar).
- La conexión sale siempre de `DATABASE_URL`, con `conn_health_checks`.

## Alternativas descartadas
- **SQLite:** no tiene las funciones de PostgreSQL y migrar después cuesta.
- **Supabase gratis:** 500 MB; pausa el proyecto tras una semana de poca actividad; no tiene backups en el plan gratis; la conexión directa es solo por IPv6.
- **PostgreSQL dentro de la VM:** compite por 1 GB de RAM y los backups quedan a cargo propio.

## Consecuencias
- La primera consulta después de un rato sin uso es más lenta.
- Tope de 1 GB de almacenamiento.
- Con solo 6 horas de historial hace falta un backup propio periódico (`pg_dump`), que queda pendiente.
