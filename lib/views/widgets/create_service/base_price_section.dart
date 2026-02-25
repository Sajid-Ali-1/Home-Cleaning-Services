import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/create_service_form_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/utils/service_validators.dart';
import 'package:home_cleaning_app/views/widgets/custom_text_form_field.dart';

class BasePriceSection extends StatelessWidget {
  const BasePriceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateServiceFormController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Base Price (Optional)',
          style: AppTheme.of(
            context,
          ).bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        Text(
          'A fixed base price if you prefer not to use duration-based pricing options.',
          style: AppTheme.of(context).bodySmall.copyWith(
            color: AppTheme.of(context).secondaryText,
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        CustomTextFormField(
          controller: controller.basePriceController,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final price = double.tryParse(value);
              if (price == null) {
                return 'Please enter a valid price';
              }
              return ServiceValidators.validatePrice(price);
            }
            return null;
          },
          labelText: 'Base Price (\$)',
          hintText: '0.00',
          prefixIcon: Icons.attach_money,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => controller.validateStep2(),
        ),
      ],
    );
  }
}
