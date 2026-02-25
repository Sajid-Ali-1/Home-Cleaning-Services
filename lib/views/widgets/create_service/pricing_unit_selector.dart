import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_cleaning_app/data/pricing_units.dart';
import 'package:home_cleaning_app/models/service_model.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class PricingUnitSelector extends StatelessWidget {
  const PricingUnitSelector({
    super.key,
    required this.selectedUnitId,
    required this.onUnitSelected,
    this.category,
  });

  final String selectedUnitId;
  final ValueChanged<PricingUnitPreset> onUnitSelected;
  final ServiceCategory? category;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Unit of measurement',
              style: AppTheme.of(context).bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.of(context).primaryText,
              ),
            ),
            // SizedBox(width: 6.w),
            // Tooltip(
            //   message:
            //       'Double tap a chip to lock it in.\nUse the pencil icon to type your own unit.',
            //   triggerMode: TooltipTriggerMode.tap,
            //   child: Icon(
            //     Icons.info_outline,
            //     size: 16.sp,
            //     color: AppTheme.of(context).secondaryText,
            //   ),
            // ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: PricingUnitPreset.presetsFor(category).map((preset) {
            final isSelected = preset.id == selectedUnitId;
            return GestureDetector(
              onDoubleTap: () => onUnitSelected(preset),
              child: ChoiceChip(
                label: Text(
                  preset.label,
                  style: AppTheme.of(context).bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppTheme.of(context).primaryText,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onUnitSelected(preset),
                selectedColor: AppTheme.of(context).accent1,
                backgroundColor: AppTheme.of(context).textFieldColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
