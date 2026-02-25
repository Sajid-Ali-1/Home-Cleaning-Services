import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/data/pricing_units.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/models/unit_price_option.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/create_service/pricing_input_field.dart';
import 'package:home_cleaning_app/views/widgets/create_service/pricing_unit_selector.dart';

class PricingOptionCard extends StatefulWidget {
  const PricingOptionCard({
    super.key,
    required this.index,
    required this.option,
    required this.category,
    this.showDelete = true,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  final int index;
  final UnitPriceOption option;
  final ServiceCategory? category;
  final bool showDelete;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;

  @override
  State<PricingOptionCard> createState() => _PricingOptionCardState();
}

class _PricingOptionCardState extends State<PricingOptionCard> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController minQuantityController;
  late TextEditingController descriptionController;
  late TextEditingController customUnitController;

  String selectedUnitId = PricingUnitPreset.customPreset.id;
  bool allowDecimal = true;
  bool get isLandscaping => widget.category == ServiceCategory.landscaping;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CreateServiceFormController>();
    nameController = TextEditingController(text: widget.option.name);
    priceController = TextEditingController(
      text: widget.option.pricePerUnit > 0
          ? widget.option.pricePerUnit.toStringAsFixed(2)
          : '',
    );
    minQuantityController = TextEditingController(
      text: widget.option.minQuantity > 0
          ? widget.option.minQuantity.toString()
          : '1',
    );
    descriptionController = TextEditingController(
      text: widget.option.description ?? '',
    );
    customUnitController = TextEditingController(text: widget.option.unitName);
    selectedUnitId = _findPresetId(widget.option.unitName);
    allowDecimal = widget.option.allowDecimal;
    if (!isLandscaping && nameController.text.isEmpty) {
      nameController.text = 'Cleaning';
    }

    nameController.addListener(() => _pushUpdate(controller));
    priceController.addListener(() => _pushUpdate(controller));
    minQuantityController.addListener(() => _pushUpdate(controller));
    descriptionController.addListener(() => _pushUpdate(controller));
    customUnitController.addListener(() => _pushUpdate(controller));
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    minQuantityController.dispose();
    descriptionController.dispose();
    customUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();
    final isValid =
        widget.option.pricePerUnit > 0 &&
        nameController.text.trim().isNotEmpty &&
        widget.option.unitName.isNotEmpty;
    final summary = isValid
        ? '\$${widget.option.pricePerUnit.toStringAsFixed(2)}/${widget.option.unitDisplay}'
        : 'Add pricing details';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isValid
              ? AppTheme.of(context).accent1.withOpacity(0.4)
              : AppTheme.of(context).error.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            index: widget.index,
            summary: summary,
            isExpanded: widget.isExpanded,
            onToggleExpansion: widget.onToggleExpansion,
            onDelete: widget.showDelete
                ? () => controller.removePricingOption(widget.index)
                : null,
            category: widget.category,
            subServiceName: nameController.text.trim(),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      if (isLandscaping)
                        PricingInputField(
                          controller: nameController,
                          label: 'Sub-service or task',
                          hint: 'e.g., Lawn mowing, Grass trimming',
                          icon: Icons.handyman_outlined,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      // else
                      //   Container(
                      //     width: double.infinity,
                      //     padding: EdgeInsets.all(14.w),
                      //     decoration: BoxDecoration(
                      //       color: AppTheme.of(context).textFieldColor,
                      //       borderRadius: BorderRadius.circular(8.r),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Icon(
                      //           Icons.cleaning_services_outlined,
                      //           color: AppTheme.of(context).accent1,
                      //           size: 20.sp,
                      //         ),
                      //         SizedBox(width: 8.w),
                      //         Text(
                      //           'Cleaning rate',
                      //           style: AppTheme.of(context).bodyMedium.copyWith(
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //         ),
                      //       ],
                      //     ),
                      //   )
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: PricingInputField(
                              controller: priceController,
                              label: 'Price per unit',
                              hint: '50.00',
                              prefix: '\$',
                              icon: Icons.attach_money,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                final parsed = double.tryParse(value ?? '');
                                if (parsed == null || parsed <= 0)
                                  return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: PricingInputField(
                              controller: minQuantityController,
                              label: 'Minimum qty',
                              hint: '1',
                              suffix: widget.option.unitDisplay,
                              icon: Icons.numbers,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                final parsed = double.tryParse(value ?? '');
                                if (parsed == null || parsed <= 0)
                                  return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      PricingUnitSelector(
                        selectedUnitId: selectedUnitId,
                        onUnitSelected: (preset) =>
                            _handleUnitSelected(preset, controller),
                        category: widget.category,
                      ),
                      if (selectedUnitId ==
                          PricingUnitPreset.customPreset.id) ...[
                        SizedBox(height: 12.h),
                        PricingInputField(
                          controller: customUnitController,
                          label: 'Custom unit label',
                          hint: 'e.g., square yards, shrubs',
                          icon: Icons.edit_outlined,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ],
                      SizedBox(height: 12.h),
                      SwitchListTile.adaptive(
                        value: allowDecimal,
                        onChanged: (value) {
                          setState(() {
                            allowDecimal = value;
                          });
                          _pushUpdate(controller);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.of(context).accent1,
                        title: Text(
                          'Allow decimal quantities',
                          style: AppTheme.of(context).bodyMedium,
                        ),
                        subtitle: Text(
                          'Enable when customers can book partial units (e.g., 2.5 sq m).',
                          style: AppTheme.of(context).bodySmall.copyWith(
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      PricingInputField(
                        controller: descriptionController,
                        label: 'Notes for customers (optional)',
                        hint: 'Describe what is included for this unit',
                        icon: Icons.notes_outlined,
                        validator: (_) => null,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _handleUnitSelected(
    PricingUnitPreset preset,
    CreateServiceFormController controller,
  ) {
    setState(() {
      selectedUnitId = preset.id;
      if (preset.id != PricingUnitPreset.customPreset.id) {
        customUnitController.text = preset.label.toLowerCase();
      } else {
        customUnitController.clear();
      }
      allowDecimal = preset.allowDecimal;
    });
    _pushUpdate(controller);
  }

  void _pushUpdate(CreateServiceFormController controller) {
    final parsedPrice = double.tryParse(priceController.text) ?? 0.0;
    final parsedMinQty = double.tryParse(minQuantityController.text) ?? 1;
    final preset = PricingUnitPreset.findById(selectedUnitId);
    final customLabel = customUnitController.text.trim();
    final optionName = isLandscaping ? nameController.text.trim() : 'Cleaning';
    final unitLabel = selectedUnitId == PricingUnitPreset.customPreset.id
        ? (customLabel.isEmpty ? 'unit' : customLabel)
        : preset.label.toLowerCase();
    final unitShort = selectedUnitId == PricingUnitPreset.customPreset.id
        ? (customLabel.isEmpty ? 'unit' : customLabel)
        : preset.shortLabel;
    final updated = widget.option.copyWith(
      name: optionName,
      pricePerUnit: parsedPrice,
      unitName: unitLabel,
      unitShortLabel: unitShort,
      minQuantity: parsedMinQty <= 0 ? 1 : parsedMinQty,
      allowDecimal: allowDecimal,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    );
    controller.updatePricingOption(widget.index, updated);
  }

  String _findPresetId(String unitName) {
    final normalized = unitName.toLowerCase();
    for (final preset in PricingUnitPreset.presets) {
      if (preset.label.toLowerCase() == normalized ||
          preset.shortLabel.toLowerCase() == normalized) {
        return preset.id;
      }
    }
    return PricingUnitPreset.customPreset.id;
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.index,
    required this.summary,
    required this.isExpanded,
    required this.onToggleExpansion,
    required this.onDelete,
    required this.category,
    required this.subServiceName,
  });

  final int index;
  final String summary;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;
  final VoidCallback? onDelete;
  final ServiceCategory? category;
  final String subServiceName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: onToggleExpansion,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).accent1.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTheme.of(context).bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.of(context).accent1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category == ServiceCategory.landscaping &&
                                  subServiceName.isNotEmpty
                              ? subServiceName
                              : 'Option ${index + 1}',
                          style: AppTheme.of(
                            context,
                          ).bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          summary,
                          style: AppTheme.of(context).bodySmall.copyWith(
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.of(context).secondaryText,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onDelete != null)
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppTheme.of(context).error,
              size: 22.sp,
            ),
            tooltip: 'Remove option',
            onPressed: onDelete,
          ),
      ],
    );
  }
}
