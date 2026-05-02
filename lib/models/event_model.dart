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
  final String? city;
  final String? country;
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
  final bool isExternal;
  final String? externalLink;
  final int? totalSeats;
  final int? remainingSeats;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.address,
    this.city,
    this.country,
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
    this.isExternal = false,
    this.externalLink,
    this.totalSeats,
    this.remainingSeats,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Determine category from type
    final eventData = json['event'] ?? {};
    final typeStr = eventData['type'] ?? 'in-person';
    EventCategory cat = EventCategory.inPerson;
    if (typeStr == 'virtual') cat = EventCategory.virtual;
    
    // Parse startAt for date and time
    String? date;
    String? time;
    if (json['startAt'] != null) {
      final startAt = DateTime.parse(json['startAt']).toLocal();
      date = "${startAt.day}/${startAt.month}/${startAt.year}";
      time = "${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}";
    }

    return EventModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? eventData['title'] ?? '',
      imageUrl: json['image'] ?? eventData['coverImage'] ?? '',
      address: json['location']?['address'] ?? eventData['location']?['address'] ?? eventData['address'],
      city: json['location']?['city'] ?? eventData['location']?['city'] ?? eventData['city'],
      country: json['location']?['country'] ?? eventData['location']?['country'] ?? eventData['country'],
      date: date,
      time: time,
      price: (eventData['ticketPrice'] ?? 0).toDouble(),
      category: cat,
      description: eventData['description'],
      isExternal: json['isExternal'] ?? false,
      externalLink: json['externalLink'],
      totalSeats: eventData['totalSeats'],
      remainingSeats: eventData['remainingSeats'],
    );
  }
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
