import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baggage_event.dart';

/// Fuente remota: coleccion `baggage_events` de Cloud Firestore.
///
/// Cada documento es un evento y su id es el id del evento. Solo guarda
/// id, baggageId, type y createdAt; los datos del equipaje siguen en la shell.
class BaggageEventRemoteService {
  BaggageEventRemoteService(this.firestore);

  static const collectionName = 'baggage_events';

  /// Sin red, Firestore puede dejar el `Future` sin completar. El limite
  /// convierte esa espera en un error para poder usar la cache local.
  static const _timeout = Duration(seconds: 10);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(collectionName);

  Map<String, dynamic> _toDocument(BaggageEvent event) {
    return {
      'id': event.id,
      'baggageId': event.baggageId,
      'type': event.type,
      'createdAt': Timestamp.fromDate(event.createdAt),
    };
  }

  BaggageEvent _fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return BaggageEvent(
      id: data['id'] as String? ?? doc.id,
      baggageId: data['baggageId'] as String,
      type: data['type'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// `Source.server` evita que Firestore responda con su propia cache
  /// cuando no hay red; asi el fallo llega al Repository y este usa Drift.
  Future<List<BaggageEvent>> _read(Query<Map<String, dynamic>> query) async {
    final snapshot = await query
        .get(const GetOptions(source: Source.server))
        .timeout(_timeout);
    return snapshot.docs.map(_fromDocument).toList();
  }

  Future<List<BaggageEvent>> getEvents() => _read(_collection);

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) =>
      _read(_collection.where('baggageId', isEqualTo: baggageId));

  /// Se escribe dentro de una transaccion porque esta solo se confirma con
  /// el servidor. Un `set` normal sin red quedaria en cola y podria subir
  /// despues, aunque la app ya hubiera informado que el registro fallo.
  Future<void> saveEvent(BaggageEvent event) async {
    final doc = _collection.doc(event.id);
    await firestore.runTransaction<void>(
      (transaction) async {
        transaction.set(doc, _toDocument(event));
      },
      timeout: _timeout,
      maxAttempts: 1,
    );
  }
}
