import 'package:get/get.dart';
import 'package:bonded_app/core/constants/app_endpoints.dart';

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
    this.bio =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
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
  final String? phoneNumber;
  final String? facebookLink;
  final String? twitterLink;
  final String? venueName;
  final String? virtualLink;
  final String? meetingLink;
  final String? hostId;
  final Map<String, dynamic>? hostDetails;
  final String? sourceType;

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
    this.phoneNumber,
    this.facebookLink,
    this.twitterLink,
    this.venueName,
    this.virtualLink,
    this.meetingLink,
    this.hostId,
    this.hostDetails,
    this.sourceType,
  });

  String get providerName {
    if (sourceType == 'viator') return 'Viator';
    if (sourceType == 'tripadvisor') return 'TripAdvisor';
    return sourceType?.capitalizeFirst ?? 'External';
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final eventData = json['event'] ?? json;
    final typeStr = eventData['type'] ?? 'in-person';
    EventCategory cat = EventCategory.inPerson;
    if (typeStr == 'virtual') cat = EventCategory.virtual;

    String? date = json['eventDate'] ?? eventData['eventDate'];
    String? time = json['eventTime'] ?? eventData['eventTime'];

    if (date == null && (json['startAt'] != null || json['startsAt'] != null || eventData['startsAt'] != null)) {
      try {
        final startAtStr = json['startAt'] ?? json['startsAt'] ?? eventData['startsAt'];
        final startAt = DateTime.parse(startAtStr).toLocal();
        date = "${startAt.day}/${startAt.month}/${startAt.year}";
        time = "${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}";
      } catch (_) {}
    }

    final coverImg = json['image'] ?? json['coverImage'] ?? eventData['coverImage'] ?? eventData['image'];
    
    // Handle external event price and rating
    final price = (eventData['price'] ?? eventData['ticketPrice'] ?? 0).toDouble();
    final rating = (eventData['rating'] ?? 0).toDouble();
    final reviewsCount = eventData['reviewCount'] ?? eventData['reviewsCount'] ?? 0;
    final city = json['location']?['city'] ?? eventData['location']?['city'] ?? eventData['city'] ?? eventData['destinationName'];

    return EventModel(
      id: json['id'] ?? json['_id'] ?? eventData['_id'] ?? eventData['id'] ?? '',
      title: json['title'] ?? eventData['title'] ?? '',
      imageUrl: AppUrls.imageUrl(coverImg),
      address: json['location']?['address'] ?? eventData['location']?['address'] ?? eventData['address'],
      city: city,
      country: json['location']?['country'] ?? eventData['location']?['country'] ?? eventData['country'],
      date: date,
      time: time,
      price: price,
      rating: rating,
      reviewsCount: reviewsCount,
      category: cat,
      description: eventData['description'] ?? eventData['raw']?['description'],
      isExternal: json['isExternal'] ?? eventData['isExternal'] ?? false,
      externalLink: json['externalLink'] ?? eventData['externalLink'] ?? eventData['productUrl'],
      totalSeats: eventData['totalSeats'],
      remainingSeats: eventData['remainingSeats'],
      phoneNumber: eventData['phoneNumber'],
      facebookLink: eventData['facebookLink'],
      twitterLink: eventData['twitterLink'],
      venueName: eventData['venueName'],
      virtualLink: eventData['virtualLink'],
      meetingLink: eventData['meetingLink'],
      hostId: eventData['host'] is String ? eventData['host'] : (eventData['host']?['_id'] ?? eventData['host']?['id']),
      hostDetails: eventData['hostDetails'] ?? json['hostDetails'],
      sourceType: json['sourceType'] ?? eventData['provider'],
    );
  }
}


class BookedEventModel {
  final String eventId;
  final String eventVisibility;
  final String title;
  final String eventDate;
  final String eventTime;
  final String? venueName;
  final String? address;
  final String? city;
  final String? country;
  final String coverImage;
  final int ticketCount;
  final int seatCount;
  final String paymentStatus;

  BookedEventModel({
    required this.eventId,
    required this.eventVisibility,
    required this.title,
    required this.eventDate,
    required this.eventTime,
    this.venueName,
    this.address,
    this.city,
    this.country,
    required this.coverImage,
    required this.ticketCount,
    required this.seatCount,
    required this.paymentStatus,
  });

  bool get isFree => paymentStatus == 'free';

  factory BookedEventModel.fromJson(Map<String, dynamic> json) {
    return BookedEventModel(
      eventId: json['eventId'] ?? '',
      eventVisibility: json['eventVisibility'] ?? 'public',
      title: json['title'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      venueName: json['venueName'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      coverImage: AppUrls.imageUrl(json['coverImage']),
      ticketCount: json['ticketCount'] ?? 0,
      seatCount: json['seatCount'] ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'free',
    );
  }
}

class TicketModel {
  final String id;
  final String ticketNumber;
  final String qrCodeValue;
  final String status;
  final String paymentStatus;
  final int seatCount;
  final String title;
  final String eventDate;
  final String eventTime;
  final String? venueName;
  final String? address;
  final String imageUrl;
  final double price;
  final bool isDownloaded;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.qrCodeValue,
    required this.status,
    required this.paymentStatus,
    required this.seatCount,
    required this.title,
    required this.eventDate,
    required this.eventTime,
    this.venueName,
    this.address,
    required this.imageUrl,
    required this.price,
    this.isDownloaded = false,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final event = json['eventSnapshot'] ?? {};
    return TicketModel(
      id: json['_id'] ?? json['id'] ?? '',
      ticketNumber: json['ticketNumber'] ?? '',
      qrCodeValue: json['qrCodeValue'] ?? json['qrPayload'] ?? '',
      status: json['status'] ?? 'active',
      paymentStatus: json['paymentStatus'] ?? 'free',
      seatCount: json['seatCount'] ?? json['quantity'] ?? 1,
      title: event['title'] ?? '',
      eventDate: event['eventDate'] ?? '',
      eventTime: event['eventTime'] ?? '',
      venueName: event['venueName'],
      address: event['address'],
      imageUrl: AppUrls.imageUrl(event['coverImage']),
      price: (json['total'] ?? 0).toDouble(),
    );
  }
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

class WalletModel {
  final String userId;
  final double availableBalance;
  final double pendingBalance;
  final double onHoldBalance;
  final String currency;

  WalletModel({
    required this.userId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.onHoldBalance,
    required this.currency,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'] ?? '',
      availableBalance: (json['availableBalance'] ?? 0).toDouble(),
      pendingBalance: (json['pendingBalance'] ?? 0).toDouble(),
      onHoldBalance: (json['onHoldBalance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }
}

