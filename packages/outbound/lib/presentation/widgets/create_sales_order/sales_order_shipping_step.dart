import 'package:flutter/material.dart';
import 'package:outbound/presentation/widgets/create_sales_order/sales_order_form_fields.dart';

class SalesOrderShippingStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController companyNameController;
  final TextEditingController contactPersonController;
  final TextEditingController phoneNumberController;
  final TextEditingController addressController;
  final TextEditingController postalCodeController;
  final TextEditingController noteController;
  final int noteLength;

  final List<Map<String, dynamic>> couriers;
  final List<Map<String, dynamic>> provinces;
  final List<Map<String, dynamic>> cities;
  final List<Map<String, dynamic>> districts;

  final int? selectedCourierId;
  final String? selectedProvinceCode;
  final String? selectedCityCode;
  final String? selectedDistrictCode;

  final bool loadingCouriers;
  final bool loadingProvinces;
  final bool loadingCities;
  final bool loadingDistricts;

  final ValueChanged<int?> onCourierChanged;
  final ValueChanged<String?> onProvinceChanged;
  final ValueChanged<String?> onCityChanged;
  final ValueChanged<String?> onDistrictChanged;

  const SalesOrderShippingStep({
    super.key,
    required this.formKey,
    required this.companyNameController,
    required this.contactPersonController,
    required this.phoneNumberController,
    required this.addressController,
    required this.postalCodeController,
    required this.noteController,
    required this.noteLength,
    required this.couriers,
    required this.provinces,
    required this.cities,
    required this.districts,
    required this.selectedCourierId,
    required this.selectedProvinceCode,
    required this.selectedCityCode,
    required this.selectedDistrictCode,
    required this.loadingCouriers,
    required this.loadingProvinces,
    required this.loadingCities,
    required this.loadingDistricts,
    required this.onCourierChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
    required this.onDistrictChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(34, 20, 34, 96),
        children: [
          SalesOrderFieldCard(
            label: 'Courier Name',
            child: SalesOrderSelectField<int>(
              value: selectedCourierId,
              hint: 'Select Courier',
              emptyHint: 'No couriers available',
              isLoading: loadingCouriers,
              items: couriers
                  .map(_courierItem)
                  .whereType<DropdownMenuItem<int>>()
                  .toList(),
              onChanged: onCourierChanged,
            ),
          ),
          SalesOrderFieldCard(
            label: 'Company Name',
            optionalLabel: 'optional',
            child: SalesOrderTextInput(
              controller: companyNameController,
              hint: 'e.g., Mayora',
            ),
          ),
          SalesOrderFieldCard(
            label: 'Contact Person',
            child: SalesOrderTextInput(
              controller: contactPersonController,
              hint: 'e.g., Joe Doe',
              validator: requiredSalesOrderField('Contact person'),
            ),
          ),
          SalesOrderFieldCard(
            label: 'Phone Number',
            child: SalesOrderTextInput(
              controller: phoneNumberController,
              hint: 'e.g., 081234567',
              keyboardType: TextInputType.phone,
              validator: requiredSalesOrderField('Phone number'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Shipping Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                SalesOrderFieldCard(
                  label: 'Address',
                  isNested: true,
                  child: SalesOrderTextInput(
                    controller: addressController,
                    hint: 'e.g., Jl. Raya ITS, Gedung D4, Keputih',
                    validator: requiredSalesOrderField('Address'),
                  ),
                ),
                SalesOrderFieldCard(
                  label: 'Province',
                  isNested: true,
                  child: SalesOrderSelectField<String>(
                    value: selectedProvinceCode,
                    hint: 'Select Province',
                    emptyHint: 'No provinces available',
                    isLoading: loadingProvinces,
                    items: provinces
                        .map(_regionItem)
                        .whereType<DropdownMenuItem<String>>()
                        .toList(),
                    onChanged: onProvinceChanged,
                  ),
                ),
                SalesOrderFieldCard(
                  label: 'City',
                  isNested: true,
                  child: SalesOrderSelectField<String>(
                    value: selectedCityCode,
                    hint: 'Select City',
                    emptyHint: selectedProvinceCode == null
                        ? 'Select province first'
                        : 'No cities available',
                    isLoading: loadingCities,
                    items: cities
                        .map(_regionItem)
                        .whereType<DropdownMenuItem<String>>()
                        .toList(),
                    onChanged: selectedProvinceCode == null
                        ? null
                        : onCityChanged,
                  ),
                ),
                SalesOrderFieldCard(
                  label: 'District',
                  isNested: true,
                  child: SalesOrderSelectField<String>(
                    value: selectedDistrictCode,
                    hint: 'Select District',
                    emptyHint: selectedCityCode == null
                        ? 'Select city first'
                        : 'No districts available',
                    isLoading: loadingDistricts,
                    items: districts
                        .map(_regionItem)
                        .whereType<DropdownMenuItem<String>>()
                        .toList(),
                    onChanged: selectedCityCode == null
                        ? null
                        : onDistrictChanged,
                  ),
                ),
                SalesOrderFieldCard(
                  label: 'Postal Code',
                  isNested: true,
                  child: SalesOrderTextInput(
                    controller: postalCodeController,
                    hint: 'e.g., 0123',
                    keyboardType: TextInputType.number,
                    validator: requiredSalesOrderField('Postal code'),
                  ),
                ),
                SalesOrderFieldCard(
                  label: 'Note',
                  optionalLabel: 'Optional',
                  isNested: true,
                  child: SalesOrderNoteInput(
                    controller: noteController,
                    count: noteLength,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<int>? _courierItem(Map<String, dynamic> courier) {
    final id = _intValue(courier, ['id', 'courierId', 'Id']);
    if (id == null) return null;
    final name =
        _stringValue(courier, [
          'name',
          'courierName',
          'serviceName',
          'Name',
          'CourierName',
        ]) ??
        'Courier #$id';

    return DropdownMenuItem<int>(
      value: id,
      child: Text(name, overflow: TextOverflow.ellipsis),
    );
  }

  DropdownMenuItem<String>? _regionItem(Map<String, dynamic> region) {
    final code = _stringValue(region, [
      'code',
      'Code',
      'provinceCode',
      'cityCode',
      'districtCode',
      'province_code',
      'city_code',
      'district_code',
    ]);
    if (code == null || code.isEmpty) return null;
    final name =
        _stringValue(region, [
          'name',
          'Name',
          'provinceName',
          'cityName',
          'districtName',
          'province_name',
          'city_name',
          'district_name',
        ]) ??
        code;

    return DropdownMenuItem<String>(
      value: code,
      child: Text(_cleanRegionName(name), overflow: TextOverflow.ellipsis),
    );
  }
}

int? _intValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

String? _stringValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value != null) return value.toString();
  }
  return null;
}

String _cleanRegionName(String value) {
  return value
      .replaceFirst(RegExp(r'^Kabupaten\s+', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^Kota\s+', caseSensitive: false), '')
      .trim();
}
