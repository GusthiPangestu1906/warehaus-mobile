import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product/product.dart';
import 'package:zone/domain/params/create_zone_param.dart';
import 'package:zone/presentation/bloc/zone_bloc.dart';
import 'package:zone/presentation/bloc/zone_event.dart';
import 'package:zone/presentation/bloc/zone_state.dart';

class CreateZonePage extends StatefulWidget {
  const CreateZonePage({super.key});

  @override
  State<CreateZonePage> createState() => _CreateZonePageState();
}

class _CreateZonePageState extends State<CreateZonePage> {
  final _formKey = GlobalKey<FormState>();
  final _zoneNameController = TextEditingController();
  final _zoneCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;

  // ✅ Replaced TextEditingControllers with int state variables
  int _totalAisle = 0;
  int _shelfPerAisle = 0;
  int _capacityPerShelf = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _zoneNameController.dispose();
    _zoneCodeController.dispose();
    _descriptionController.dispose();
    // ✅ No controllers to dispose for stepper fields
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadCategoriesEvent());
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    context.read<ZoneBloc>().add(
      CreateZoneEvent(
        new CreateZoneParam(
          zoneName: _zoneNameController.text.trim(),
          zoneCode: _zoneCodeController.text.trim(),
          categoryId: _selectedCategoryId!,
          totalAisle: _totalAisle,
          shelfPerAisle: _shelfPerAisle,
          capacityPerShelf: _capacityPerShelf,
          description: _descriptionController.text.trim(),
        )
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: WHStyles.hint, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: WHStyles.inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(WHStyles.inputRadius),
      borderSide: BorderSide(color: WHStyles.border, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(WHStyles.inputRadius),
      borderSide: BorderSide(color: WHStyles.border, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(WHStyles.inputRadius),
      borderSide: BorderSide(color: WHStyles.primary, width: 1.5),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: WHColors.textPrimary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ZoneBloc, ZoneState>(
      listener: (context, state) {
        if (state is ZoneOperationSuccess) {
          WHSnackBar.showSuccess(context, 'Zone berhasil disimpan!');
          Navigator.of(context).pop(true);
        } else if (state is ZoneError) {
          setState(() => _isSubmitting = false);
          WHSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ZoneLoading || _isSubmitting;

        return Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(title: 'Add Zone'),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WHTextField(
                          label: 'Zone Code',
                          controller: _zoneCodeController,
                          hintText: 'e.g., ELC',
                        ),
                        const SizedBox(height: 16),
                        WHTextField(
                          label: 'Zone Name',
                          controller: _zoneNameController,
                          hintText: 'e.g., Electronic',
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<ProductBloc, ProductState>(
                          buildWhen: (prev, curr) => curr is CategoriesLoaded || curr is CategoriesLoading,
                          builder: (context, state) {
                            // FIX: Added explicit List<Category> type so cat.id is recognized
                            final List<Category> categories = state is CategoriesLoaded ? state.categories : <Category>[];

                            return WHDropdownField<int>(
                              label: 'Category',
                              hintText: state is CategoriesLoading ? 'Loading categories...' : 'Select Category',
                              selectedValue: _selectedCategoryId,
                              // Now cat.id and cat.name will be recognized perfectly
                              items: categories.map((cat) => WHDropdownItem<int>(
                                value: cat.id,
                                label: cat.name,
                              )).toList(),
                              onChanged: (val) {
                                setState(() => _selectedCategoryId = val);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // ✅ WHStepperField replaces _numericInput(...)
                        WHStepperField(
                          label: 'Total Aisle',
                          value: _totalAisle,
                          onChanged: (v) => setState(() => _totalAisle = v),
                          minValue: 0,
                        ),
                        const SizedBox(height: 16),

                        WHStepperField(
                          label: 'Shelf Per Aisle',
                          value: _shelfPerAisle,
                          onChanged: (v) => setState(() => _shelfPerAisle = v),
                          minValue: 0,
                        ),
                        const SizedBox(height: 16),

                        WHStepperField(
                          label: 'Capacity Per Shelf',
                          value: _capacityPerShelf,
                          onChanged: (v) => setState(() => _capacityPerShelf = v),
                          minValue: 0,
                        ),
                        const SizedBox(height: 16),

                        WHDescriptionField(
                          label: 'Description',
                          controller: _descriptionController,
                          hintText: 'Add description here ....',
                          maxLength: 150,
                          isOptional: true,
                        )
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _submit,
                    icon: isLoading
                        ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.check_circle_outline,
                      size: 17,
                      color: Colors.white,
                    ),
                    label: Text(
                      isLoading ? 'Saving...' : 'Save Zone',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading
                          ? WHStyles.primaryFaded
                          : WHStyles.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(WHStyles.buttonRadius),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}