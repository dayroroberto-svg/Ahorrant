class Transaction {
  final int? id;
  final double amount;
  final DateTime date;
  final String type; // 'ingreso' o 'egreso'
  final String category; // 'gastos hormiga', 'transporte', 'alimentacion', etc.
  final String origin; // 'yape', 'manual', etc.
  final String? description;
  final bool synced; // Si ya se sincronizó con Supabase

  const Transaction({
    this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.origin,
    this.description,
    this.synced = false,
  });

  // Copiar la transaccion cambiando solo los campos indicados
  Transaction copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? type,
    String? category,
    String? origin,
    String? description,
    bool? synced,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      description: description ?? this.description,
      synced: synced ?? this.synced,
    );
  }

  // Convertir a Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'origin': origin,
      'description': description,
      'synced': synced ? 1 : 0,
    };
  }

  // Crear desde Map (al leer de SQLite)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
      category: map['category'] as String,
      origin: map['origin'] as String,
      description: map['description'] as String?,
      synced: map['synced'] == 1,
    );
  }

  // Igualdad para comparar transacciones
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        id == other.id &&
        amount == other.amount &&
        date == other.date &&
        type == other.type &&
        category == other.category &&
        origin == other.origin &&
        description == other.description &&
        synced == other.synced;
  }

  @override
  int get hashCode =>
      id.hashCode ^ amount.hashCode ^ date.hashCode ^ type.hashCode ^ category.hashCode ^ origin.hashCode ^ description.hashCode ^ synced.hashCode;
}