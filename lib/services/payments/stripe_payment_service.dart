import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:home_cleaning_app/controllers/confirm_booking_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:http/http.dart' as http;

class StripePaymentResult {
  StripePaymentResult({
    required this.paymentIntentId,
    this.clientSecret,
    this.paymentMethodId,
  });

  final String paymentIntentId;
  final String? clientSecret;
  final String? paymentMethodId;
}

class StripePaymentService {
  static final http.Client _client = http.Client();

  static Future<StripePaymentResult> payWithTestKey({
    required double amount,
    required String currency,
    required String description,
    required BuildContext context,
    required BookingPaymentMethod paymentMethod,
  }) async {
    final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
    if (secretKey == null || secretKey.isEmpty) {
      throw Exception(
        'Stripe secret key missing. Add STRIPE_SECRET_KEY in your .env file.',
      );
    }

    // Note: Google Pay and Apple Pay are not payment_method_types.
    // They are handled automatically by the Payment Sheet UI when configured.
    // The payment intent only needs 'card' as the payment method type.
    final intent = await _createPaymentIntent(
      secretKey: secretKey,
      amount: amount,
      currency: currency,
      description: description,
      paymentMethodTypes: ['card'],
    );
    final merchantName =
        dotenv.env['STRIPE_MERCHANT_DISPLAY_NAME'] ?? 'Home Services';

    // Get country code from currency or default to US
    final countryCode = _getCountryCodeFromCurrency(currency);
    final upperCurrency = currency.toUpperCase();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: intent['client_secret'] as String,
        merchantDisplayName: merchantName,
        customFlow: false,
        googlePay: PaymentSheetGooglePay(
          merchantCountryCode: countryCode,
          currencyCode: upperCurrency,
          testEnv: true, // Set to false for production
        ),
        applePay: PaymentSheetApplePay(merchantCountryCode: countryCode),
        appearance: PaymentSheetAppearance(
          // 1. Customize general colors
          colors: PaymentSheetAppearanceColors(
            primary: AppTheme.of(context).accent1,
            background: AppTheme.of(context).primaryBackground,
            componentText: AppTheme.of(context).primaryText,
            placeholderText: AppTheme.of(context).secondaryText,
            primaryText: AppTheme.of(context).primaryText,
            secondaryText: AppTheme.of(context).secondaryText,
            componentDivider: AppTheme.of(context).dividerColor,
            error: AppTheme.of(context).error,
          ),
          // 2. Customize the main "Pay" button specifically (optional, overrides 'primary')
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              light: PaymentSheetPrimaryButtonThemeColors(
                background: AppTheme.of(context).accent1,
                text: Colors.white,
              ),
              dark: PaymentSheetPrimaryButtonThemeColors(
                background: AppTheme.of(context).accent1,
                text: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
    await Stripe.instance.presentPaymentSheet();
    final paymentIntentId = intent['id'] as String;
    return StripePaymentResult(
      paymentIntentId: paymentIntentId,
      clientSecret: intent['client_secret'] as String,
      paymentMethodId: intent['payment_method'] as String?,
    );
  }

  static String _getCountryCodeFromCurrency(String currency) {
    // Map common currencies to country codes
    final currencyToCountry = {
      'usd': 'US',
      'eur': 'DE', // Default to Germany for EUR
      'gbp': 'GB',
      'cad': 'CA',
      'aud': 'AU',
    };
    return currencyToCountry[currency.toLowerCase()] ?? 'US';
  }

  static Future<Map<String, dynamic>> _createPaymentIntent({
    required String secretKey,
    required double amount,
    required String currency,
    required String description,
    required List<String> paymentMethodTypes,
  }) async {
    final body = <String, String>{
      'amount': _toStripeAmount(amount).toString(),
      'currency': currency,
      'description': description,
    };

    // Add payment method types (only 'card' is needed - Google Pay/Apple Pay are handled by Payment Sheet)
    for (var i = 0; i < paymentMethodTypes.length; i++) {
      body['payment_method_types[$i]'] = paymentMethodTypes[i];
    }
    final response = await _client.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
    if (response.statusCode >= 400) {
      throw Exception('Stripe error: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static int _toStripeAmount(double amount) {
    return (amount * 100).round();
  }

  /// Refunds a payment using the payment intent ID
  /// Returns the refund ID if successful
  static Future<String> refundPayment({
    required String paymentIntentId,
    String? reason,
  }) async {
    final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
    if (secretKey == null || secretKey.isEmpty) {
      throw Exception(
        'Stripe secret key missing. Add STRIPE_SECRET_KEY in your .env file.',
      );
    }

    // First, retrieve the payment intent with expanded charges to get the charge ID
    final paymentIntentResponse = await _client.get(
      Uri.parse(
        'https://api.stripe.com/v1/payment_intents/$paymentIntentId?expand[]=charges.data',
      ),
      headers: {
        'Authorization': 'Bearer $secretKey',
      },
    );

    if (paymentIntentResponse.statusCode >= 400) {
      throw Exception(
        'Failed to retrieve payment intent: ${paymentIntentResponse.body}',
      );
    }

    final paymentIntentData =
        jsonDecode(paymentIntentResponse.body) as Map<String, dynamic>;
    
    // Try to get charge ID from latest_charge first (simpler)
    String? chargeId = paymentIntentData['latest_charge'] as String?;
    
    // If latest_charge is not available, try to get from charges list
    if (chargeId == null) {
      final charges = paymentIntentData['charges'];
      if (charges is Map<String, dynamic>) {
        final chargesData = charges['data'] as List<dynamic>?;
        if (chargesData != null && chargesData.isNotEmpty) {
          chargeId = (chargesData.first as Map<String, dynamic>)['id'] as String;
        }
      } else if (charges is List && charges.isNotEmpty) {
        chargeId = (charges.first as Map<String, dynamic>)['id'] as String;
      }
    }

    if (chargeId == null || chargeId.isEmpty) {
      throw Exception('No charges found for payment intent');
    }

    // Create refund
    final body = <String, String>{
      'charge': chargeId,
      if (reason != null) 'reason': reason,
    };

    final refundResponse = await _client.post(
      Uri.parse('https://api.stripe.com/v1/refunds'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (refundResponse.statusCode >= 400) {
      throw Exception('Stripe refund error: ${refundResponse.body}');
    }

    final refundData = jsonDecode(refundResponse.body) as Map<String, dynamic>;
    return refundData['id'] as String;
  }
}
