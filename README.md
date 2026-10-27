# BaggageTrack · Practico 2 (G61)

Desarrollo de Aplicaciones Moviles · 2026-2

**Variante D (pareja):** Emmanuel Calad Correa · Jorge Steven Lopez Arenas
**Requisito de la variante:** indicador dinamico de equipaje demorado.

## Que hace la app

- El catalogo de equipajes (id, pasajero, vuelo, destino) sigue saliendo de
  `lib/data/baggage_seed.dart`. No se migra a Firebase ni a Drift.
- Firestore y Drift guardan solo los eventos de cada equipaje.
- El estado actual de cada equipaje sale de su evento mas reciente. Sin eventos
  se muestra `Sin eventos`.
- El detalle muestra el historial y permite registrar el siguiente evento valido:
  `CHECKED_IN -> SECURITY -> LOADED -> IN_TRANSIT -> DELIVERED`.

## Estructura

```
lib/
  main.dart                                   Firebase.initializeApp y composicion de dependencias
  firebase_options.dart                       Generado por FlutterFire (proyecto examen-movil2)
  models/
    baggage.dart, baggage_event.dart          Modelos de la shell (sin cambios)
    baggage_event_type.dart                   Secuencia de tipos de evento
    baggage_tracking.dart                     Estado actual, siguiente evento, validacion y demora
  database/
    baggage_events_table.dart                 Tabla Drift, @DataClassName('BaggageEventRow')
    app_database.dart (+ .g.dart)             @DriftDatabase, archivo baggage_track.sqlite
    baggage_event_local_data_source.dart      Consultas y upserts de Drift
  services/baggage_event_remote_service.dart  Coleccion baggage_events de Cloud Firestore
  repositories/baggage_event_repository.dart  Coordina Firestore (principal) y Drift (cache)
  pages/, widgets/                            UI: reciben el Repository por constructor
```

La UI no importa Drift ni Firestore. `BaggageEventRow` (fila de Drift) solo
existe dentro de `BaggageEventLocalDataSource`, que la convierte a
`BaggageEvent`.

## Datos

**Firestore:** coleccion `baggage_events`. Cada documento es un evento y su id
es el id del evento (`<baggageId>-<milisegundos>`):

```
baggage_events/BG-1003-1793066425662
  id:        "BG-1003-1793066425662"
  baggageId: "BG-1003"
  type:      "CHECKED_IN"
  createdAt: Timestamp
```

No se guardan `passenger`, `flight` ni `destination`. No hace falta crear la
coleccion a mano: la primera escritura la crea.

**Drift:** tabla `baggage_events` con las mismas cuatro columnas. La clave
primaria es `id` (no `baggageId`), asi cada equipaje conserva varios eventos.
Tiene un indice sobre `baggage_id` para consultar el historial de un equipaje.

## Flujo

**Lectura** (`BaggageEventRepository.getEventsForBaggage` / `getAllEvents`):

1. Consulta Firestore con `Source.server`, para que un fallo de red llegue a la
   app y Firestore no responda con su propia cache.
2. Si funciona, guarda los eventos en Drift (upsert) y los muestra.
3. Si falla (sin red, sin Firebase o mas de 10 s), lee Drift y la UI muestra el
   aviso *"Sin conexion con Firestore. Se muestran los ultimos datos guardados
   en este dispositivo."*

**Registro** (`BaggageEventRepository.registerEvent`):

1. Lee el historial actual del equipaje y valida la transicion. No se permite
   saltar, repetir ni retroceder estados, y despues de `DELIVERED` no hay
   siguiente evento.
2. Si es valida, escribe en Firestore dentro de una transaccion. Una
   transaccion solo se confirma con el servidor; un `set` normal sin red
   quedaria en cola y podria subir despues de haber informado el error.
3. Solo si Firestore confirma, guarda el evento en Drift.
4. Si Firestore falla, la app muestra el error y el evento no aparece en el
   historial.

## Variante D: Demorado

`BaggageTracking.isDelayed(now)` es verdadero cuando el equipaje:

- tiene al menos un evento,
- su ultimo evento no es `DELIVERED`, y
- su ultimo evento tiene mas de 30 minutos (`now - createdAt > 30 min`).

El valor se calcula, no se guarda en Firestore ni en Drift. Las pantallas
recalculan `now` cada 30 segundos, asi un equipaje pasa a Demorado sin
recargar. En la lista, la tarjeta demorada cambia de fondo y borde, muestra el
chip *Demorado · N min sin actualizar* y arriba aparece el total de demorados.
En el detalle aparece el mismo chip y la fecha de la ultima actualizacion.

**Como demostrarlo sin esperar 30 minutos:** registrar uno o dos eventos para
un equipaje y, en Firebase Console, cambiar el `createdAt` del ultimo evento a
una hora de hace mas de 30 minutos. Al tocar *Actualizar*, el equipaje aparece
como demorado. Si despues se registra el siguiente evento, el indicador
desaparece.

## Ejecutar

Toolchain usado: Flutter 3.41.9 (Dart 3.11.5), Android Emulator.

```bash
flutter pub get
flutter run
```

El codigo generado de Drift (`app_database.g.dart`) esta incluido. Si cambia la
tabla, regenerarlo con:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Pruebas:

```bash
flutter analyze
flutter test
```

`test/` cubre la logica de estado, transiciones y demora, las operaciones de
Drift (historial por `baggageId`, upsert sin duplicados) y el Repository con un
Firestore simulado (cache, fallback local, rechazo de transiciones y fallo de
escritura).

## Firebase

- Proyecto: `examen-movil2`. App Android: `co.edu.examen.examen_practico_2`.
- `lib/firebase_options.dart`, `android/app/google-services.json` y
  `firebase.json` los genero FlutterFire.
- Firestore en modo de prueba. Si las reglas vencen, la lectura cae a Drift y
  el registro muestra error (`permission-denied`).
