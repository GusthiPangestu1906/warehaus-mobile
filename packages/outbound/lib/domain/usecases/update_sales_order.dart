import 'package:outbound/domain/repositories/sales_order_repository.dart';

class UpdateSalesOrder {
  final SalesOrderRepository repository;
  const UpdateSalesOrder(this.repository);

  Future<void> call({
    required int id,
    required String customerName,
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
    required String shippingAddress,
    required String provinceCode,
    required String cityCode,
    required String districtCode,
    required String postalCode,
    required int courierId,
    required String requiredDeliveryDate,
    required List<Map<String, dynamic>> items,
  }) =>
      repository.updateSalesOrder(
        id: id,
        customerName: customerName,
        companyName: companyName,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
        shippingAddress: shippingAddress,
        provinceCode: provinceCode,
        cityCode: cityCode,
        districtCode: districtCode,
        postalCode: postalCode,
        courierId: courierId,
        requiredDeliveryDate: requiredDeliveryDate,
        items: items,
      );
}
