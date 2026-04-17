enum EventCategory { inPerson, virtual, highlights }

class EventModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? address;
  final String? date;
  final String? time;
  final int? highlightsCount;
  final EventCategory category;
  final bool isMyEvent;

  EventModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.address,
    this.date,
    this.time,
    this.highlightsCount,
    required this.category,
    this.isMyEvent = false,
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
