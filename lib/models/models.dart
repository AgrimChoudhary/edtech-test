class Job {
  final String id;
  final String title;
  final String organization;
  final Map<String, dynamic> detailsJson;
  final DateTime applicationStartDate;
  final DateTime applicationEndDate;
  final int? vacancies;
  final String? officialWebsiteUrl;

  Job({
    required this.id,
    required this.title,
    required this.organization,
    required this.detailsJson,
    required this.applicationStartDate,
    required this.applicationEndDate,
    this.vacancies,
    this.officialWebsiteUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      organization: json['organization'],
      detailsJson: json['details_json'],
      applicationStartDate: DateTime.parse(json['application_start_date']),
      applicationEndDate: DateTime.parse(json['application_end_date']),
      vacancies: json['vacancies'],
      officialWebsiteUrl: json['official_website_url'],
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String city;
  final String state;

  UserProfile({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.city,
    required this.state,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      city: json['city'],
      state: json['state'],
    );
  }
}

class Qualification {
  final String id;
  final String userId;
  final String level;
  final String? stream;
  final String? degree;
  final double? marks;
  final String status;
  final int? completionYear;

  Qualification({
    required this.id,
    required this.userId,
    required this.level,
    this.stream,
    this.degree,
    this.marks,
    required this.status,
    this.completionYear,
  });

  factory Qualification.fromJson(Map<String, dynamic> json) {
    return Qualification(
      id: json['id'],
      userId: json['user_id'],
      level: json['level'],
      stream: json['stream'],
      degree: json['degree'],
      marks: json['marks']?.toDouble(),
      status: json['status'],
      completionYear: json['completion_year'],
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String jobId;
  final String? parentCommentId;
  final String commentText;
  final int upvotes;
  final bool isDeleted;
  final bool isPinned;
  final String userName;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.jobId,
    this.parentCommentId,
    required this.commentText,
    required this.upvotes,
    required this.isDeleted,
    required this.isPinned,
    required this.userName,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      jobId: json['job_id'],
      parentCommentId: json['parent_comment_id'],
      commentText: json['comment_text'],
      upvotes: json['upvotes'] ?? 0,
      isDeleted: json['is_deleted'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      userName: json['user_name'] ?? 'Anonymous',
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => Comment.fromJson(r))
              .toList() ??
          [],
    );
  }
}
