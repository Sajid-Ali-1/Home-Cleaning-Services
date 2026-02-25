class ServiceValidators {
  /// Validate service title
  static String? validateServiceTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a service title';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters long';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validate service description
  static String? validateServiceDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a service description';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters long';
    }
    if (value.length > 1000) {
      return 'Description must be less than 1000 characters';
    }
    return null;
  }

  /// Validate price (for basePrice or pricing options)
  static String? validatePrice(double? price) {
    if (price == null) {
      return 'Price is required';
    }
    if (price <= 0) {
      return 'Price must be greater than 0';
    }
    if (price > 100000) {
      return 'Price must be less than \$100,000';
    }
    return null;
  }

  /// Validate duration (for pricing options)
  static String? validateDuration(int? duration) {
    if (duration == null) {
      return 'Duration is required';
    }
    if (duration <= 0) {
      return 'Duration must be greater than 0 hours';
    }
    if (duration > 48) {
      return 'Duration must be less than 48 hours';
    }
    return null;
  }

  /// Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a location';
    }
    if (value.length < 3) {
      return 'Location must be at least 3 characters long';
    }
    return null;
  }

  /// Validate materials needed
  static String? validateMaterials(String? value) {
    // Optional field, but if provided should have reasonable length
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Materials description must be at least 5 characters if provided';
    }
    return null;
  }

  /// Validate requirements
  static String? validateRequirements(String? value) {
    // Optional field, but if provided should have reasonable length
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Requirements description must be at least 5 characters if provided';
    }
    return null;
  }

  /// Validate images
  static String? validateImages(List<String>? images) {
    if (images == null || images.isEmpty) {
      return 'Please add at least one image';
    }
    if (images.length > 10) {
      return 'Maximum 10 images allowed';
    }
    return null;
  }

  /// Validate pricing options (for Cleaning or Standard Landscaping)
  // static String? validatePricingOptions(
  //   List<dynamic>? options,
  //   ServiceCategory category,
  // ) {
  //   if (category == ServiceCategory.cleaning) {
  //     if (options == null || options.isEmpty) {
  //       return 'Please add at least one pricing option';
  //     }
  //   }
  //   // For Standard Landscaping, pricingOptions OR basePrice is required
  //   // (handled separately)
  //   return null;
  // }

  /// Validate service for Cleaning category
  static String? validateCleaningService({
    required String? title,
    required String? description,
    required List<dynamic>? pricingOptions,
    required String? location,
    required List<String>? images,
  }) {
    String? error = validateServiceTitle(title);
    if (error != null) return error;

    error = validateServiceDescription(description);
    if (error != null) return error;

    // error = validatePricingOptions(pricingOptions, ServiceCategory.cleaning);
    // if (error != null) return error;

    error = validateLocation(location);
    if (error != null) return error;

    error = validateImages(images);
    if (error != null) return error;

    return null;
  }

  /// Validate service for Landscaping
  static String? validateLandscapingService({
    required String? title,
    required String? description,
    List<dynamic>? pricingOptions,
    double? basePrice,
    required String? location,
    required List<String>? images,
  }) {
    String? error = validateServiceTitle(title);
    if (error != null) return error;

    error = validateServiceDescription(description);
    if (error != null) return error;

    // Pricing options and base price are both optional for Landscaping
    // But if provided, validate them

    // Validate pricing options if provided
    // if (pricingOptions != null && pricingOptions.isNotEmpty) {
    //   error = validatePricingOptions(
    //     pricingOptions,
    //     ServiceCategory.landscaping,
    //   );
    //   if (error != null) return error;
    // }

    // Validate base price if provided
    if (basePrice != null) {
      error = validatePrice(basePrice);
      if (error != null) return error;
    }

    error = validateLocation(location);
    if (error != null) return error;

    error = validateImages(images);
    if (error != null) return error;

    return null;
  }
}
