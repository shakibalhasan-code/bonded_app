class MarketplaceProduct {
  final String id;
  final String interestSlug;
  final String amazonKeyword;
  final String amazonUrl;
  final String category;
  final String ctaLabel;
  final String imageUrl;
  final String interest;
  final bool isActive;
  final String priceRange;

  MarketplaceProduct({
    required this.id,
    required this.interestSlug,
    required this.amazonKeyword,
    required this.amazonUrl,
    required this.category,
    required this.ctaLabel,
    required this.imageUrl,
    required this.interest,
    required this.isActive,
    required this.priceRange,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['_id'] ?? '',
      interestSlug: json['interestSlug'] ?? '',
      amazonKeyword: json['amazonKeyword'] ?? '',
      amazonUrl: json['amazonUrl'] ?? '',
      category: json['category'] ?? '',
      ctaLabel: json['ctaLabel'] ?? 'Shop Now',
      imageUrl: json['imageUrl'] ?? '',
      interest: json['interest'] ?? '',
      isActive: json['isActive'] ?? false,
      priceRange: json['priceRange'] ?? 'Prices vary',
    );
  }
}

class MarketplaceResponse {
  final String circleId;
  final String circleName;
  final List<String> interests;
  final int totalProducts;
  final List<MarketplaceProduct> products;

  MarketplaceResponse({
    required this.circleId,
    required this.circleName,
    required this.interests,
    required this.totalProducts,
    required this.products,
  });

  factory MarketplaceResponse.fromJson(Map<String, dynamic> json) {
    return MarketplaceResponse(
      circleId: json['circleId'] ?? '',
      circleName: json['circleName'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      totalProducts: json['totalProducts'] ?? 0,
      products: (json['products'] as List?)
              ?.map((p) => MarketplaceProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}
