enum EventCategory { inPerson, virtual, highlights }

class HostModel {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String firstName;
  final int hostedEventsCount;
  final String bio;
  final String phoneNumber;
  final String facebookUrl;
  final String twitterUrl;
  final bool isPhoneVerified;
  final bool isIdVerified;
  final bool isSocialVerified;

  HostModel({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    this.firstName = 'Maria T.',
    this.hostedEventsCount = 12,
    this.bio = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    this.phoneNumber = '+49-5410-81030619',
    this.facebookUrl = 'https://www.facebook.com/bondedapp',
    this.twitterUrl = 'https://www.twitter.com/bondedapp',
    this.isPhoneVerified = true,
    this.isIdVerified = true,
    this.isSocialVerified = true,
  });
}

class ReviewModel {
  final String id;
  final String userName;
  final String userEmail;
  final String userImageUrl;
  final double rating;
  final String date;
  final String comment;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class VenueModel {
  final String name;
  final String location;

  VenueModel({required this.name, required this.location});
}

class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? address;
  final String? date;
  final String? time;
  final double? price;
  final double? rating;
  final int? reviewsCount;
  final int? highlightsCount;
  final EventCategory category;
  final bool isMyEvent;
  final String? description;
  final HostModel? host;
  final List<ReviewModel>? reviews;
  final List<VenueModel>? suggestedVenues;
  final Map<String, String>? socialMedia;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.address,
    this.date,
    this.time,
    this.price,
    this.rating,
    this.reviewsCount,
    this.highlightsCount,
    required this.category,
    this.isMyEvent = false,
    this.description,
    this.host,
    this.reviews,
    this.suggestedVenues,
    this.socialMedia,
  });
}


class HighlightModel {
  final String id;
  final String eventName;
  final String circleName;
  final List<String> videoUrls;
  final List<String> imageUrls;
  final String description;

  HighlightModel({
    required this.id,
    required this.eventName,
    required this.circleName,
    required this.videoUrls,
    required this.imageUrls,
    required this.description,
  });
}

class TicketModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int seats;
  final bool isDownloaded;

  TicketModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.seats,
    this.isDownloaded = false,
  });
}

class TransactionModel {
  final String id;
  final String title;
  final String transactionId;
  final String date;
  final double amount;
  final bool isCredit;

  TransactionModel({
    required this.id,
    required this.title,
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}
