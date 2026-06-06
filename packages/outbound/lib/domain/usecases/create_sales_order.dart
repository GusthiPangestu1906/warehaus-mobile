import 'package:outbound/domain/repositories/sales_order_repository.dart';

class CreateSalesOrder {
  final SalesOrderRepository repository;
  const CreateSalesOrder(this.repository);

  Future<void> call({
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
      repository.createSalesOrder(
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
