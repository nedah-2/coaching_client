import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String? id;
  String title;
  String description;
  String deadline;
  bool isDone;
  List<Resource>? resources;
  String? duration;

  Task(
      {this.id,
      required this.title,
      required this.description,
      required this.deadline,
      required this.isDone,
      this.resources,
      this.duration});

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var resourcesFromFirestore = data['resources'] as List<dynamic>?;
    List<Resource>? resourceList;

    if (resourcesFromFirestore != null) {
      resourceList = resourcesFromFirestore
          .map((resourceData) => Resource.fromFirestore(resourceData))
          .toList();
    }

    return Task(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        deadline: data['deadline'] ?? '',
        isDone: data['isDone'] ?? false,
        resources: resourceList,
        duration: data['duration'] ?? '');
  }

  factory Task.fromJson(Map<String, dynamic> data) {
    var resourcesFromFirestore = data['resources'] as List<dynamic>?;
    List<Resource>? resourceList;

    if (resourcesFromFirestore != null) {
      resourceList = resourcesFromFirestore
          .map((resourceData) => Resource.fromFirestore(resourceData))
          .toList();
    }

    return Task(
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        deadline: data['deadline'] ?? '',
        isDone: data['isDone'] ?? false,
        resources: resourceList,
        duration: data['duration'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    List<Map<String, dynamic>>? resourcesToFirestore;

    if (resources != null) {
      resourcesToFirestore =
          resources!.map((resource) => resource.toFirestore()).toList();
    }

    return {
      'title': title,
      'description': description,
      'deadline': deadline,
      'isDone': isDone,
      'resources': resourcesToFirestore,
      'duration': duration
    };
  }
}

class Resource {
  String type;
  String title;
  int duration;
  String link;

  Resource(
      {required this.type,
      required this.title,
      required this.duration,
      required this.link});

  factory Resource.fromFirestore(Map<String, dynamic> data) {
    return Resource(
        type: data['type'] ?? '',
        title: data['title'] ?? '',
        duration: data['duration'] ?? 0,
        link: data['resource'] ?? '');
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'duration': duration,
      'resource': link
    };
  }
}
