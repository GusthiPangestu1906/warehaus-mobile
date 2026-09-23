/// Konstanta permission string yang digunakan di seluruh aplikasi WareHaus.
///
/// Gunakan kelas ini untuk memeriksa izin user daripada menggunakan
/// string literal langsung, sehingga menghindari typo dan memudahkan
/// refactoring di masa depan.
class AppPermissions {
  AppPermissions._();

  // ---------------------------------------------------------------------------
  // DASHBOARD
  // ---------------------------------------------------------------------------
  static const String dashboardView = 'dashboard:view';

  // ---------------------------------------------------------------------------
  // ZONE
  // ---------------------------------------------------------------------------
  static const String zoneView = 'zone:view';
  static const String zoneCreate = 'zone:create';
  static const String zoneEdit = 'zone:edit';
  static const String zoneDelete = 'zone:delete';

  // ---------------------------------------------------------------------------
  // PRODUCT
  // ---------------------------------------------------------------------------
  static const String productView = 'product:view';
  static const String productCreate = 'product:create';
  static const String productEdit = 'product:edit';
  static const String productDelete = 'product:delete';

  // ---------------------------------------------------------------------------
  // INBOUND (Purchase Order / QC / Put-Away)
  // ---------------------------------------------------------------------------
  static const String poView = 'po:view';
  static const String poCreate = 'po:create';
  static const String poEdit = 'po:edit';
  static const String poDelete = 'po:delete';
  static const String poAssign = 'po:assign';
  static const String poTracking = 'po:tracking';
  static const String qcExecute = 'qc:execute';
  static const String putExecute = 'put:execute';

  // ---------------------------------------------------------------------------
  // OUTBOUND (Sales Order / Picking / Packing)
  // ---------------------------------------------------------------------------
  static const String soView = 'so:view';
  static const String soCreate = 'so:create';
  static const String soEdit = 'so:edit';
  static const String soDelete = 'so:delete';
  static const String soAssign = 'so:assign';
  static const String soInvoice = 'so:invoice';
  static const String pickExecute = 'pick:execute';
  static const String packExecute = 'pack:execute';
}
