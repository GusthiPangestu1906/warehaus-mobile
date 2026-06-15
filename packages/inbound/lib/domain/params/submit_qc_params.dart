class SubmitQcParams {
  const SubmitQcParams({
    required this.poItemId,
    required this.qtyReceived,
    required this.condition,
    required this.conditionNotes,
    required this.unreadableBarcode,
    required this.expiryDate,
    required this.photo,
  });

  final int poItemId;
  final int qtyReceived;
  final String condition;
  final String conditionNotes;
  final bool unreadableBarcode;
  final DateTime expiryDate;
  final String photo;

  Map<String, dynamic> toJson() {
    return {
      'POItemId': poItemId,
      'QtyReceived': qtyReceived,
      'Condition': condition,
      'ConditionNotes': conditionNotes,
      'UnreadableBarcode': unreadableBarcode,
      'ExpiryDate': _formatDate(expiryDate),
      'Photo': photo,
    };
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
