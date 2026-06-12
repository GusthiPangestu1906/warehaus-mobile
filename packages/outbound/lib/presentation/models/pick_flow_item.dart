class PickItem {
  const PickItem({
    required this.sku,
    required this.productName,
    required this.expectedQty,
    this.unitOfMeasure = 'Box',
    this.locations = const [],
  });

  final String sku;
  final String productName;
  final int expectedQty;
  final String unitOfMeasure;
  final List<PickLocation> locations;
}

class PickLocation {
  const PickLocation({
    required this.zone,
    required this.aisle,
    required this.shelf,
    required this.requiredQty,
    this.unit = 'Box',
  });

  final String zone;
  final String aisle;
  final String shelf;
  final int requiredQty;
  final String unit;

  String get label => '$zone - $aisle - $shelf';
}
