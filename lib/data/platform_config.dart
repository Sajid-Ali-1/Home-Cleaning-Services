class PlatformConfig {
  // Platform fee percentage (default: 10%)
  static const double defaultPlatformFeePercentage = 10.0;

  // QR code expiration days after booking start time (default: 7 days)
  static const int defaultQrCodeExpirationDays = 7;

  // Payout holding period in hours (default: 24 hours)
  static const int defaultPayoutHoldingHours = 24;

  // Get platform fee percentage from environment or use default
  static double getPlatformFeePercentage() {
    // In production, this could read from Firestore config collection
    // For now, return default
    return defaultPlatformFeePercentage;
  }

  // Calculate platform fee from total amount
  static double calculatePlatformFee(double total) {
    final feePercentage = getPlatformFeePercentage();
    return (total * feePercentage) / 100;
  }

  // Calculate payout amount (total - platform fee)
  static double calculatePayoutAmount(double total) {
    return total - calculatePlatformFee(total);
  }
}
