import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Get user profile with qualifications
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _supabase.functions.invoke('get-user-profile');
      return response.data['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String name,
    required DateTime dateOfBirth,
    required String city,
    required String state,
  }) async {
    try {
      await _supabase.from('users').update({
        'name': name,
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        'city': city,
        'state': state,
      }).eq('id', _supabase.auth.currentUser!.id);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Add qualification
  Future<bool> addQualification({
    required String level,
    String? stream,
    String? degree,
    double? marks,
    required String status,
    int? completionYear,
  }) async {
    try {
      final response = await _supabase.functions.invoke('add-qualification',
        body: {
          'level': level,
          'stream': stream,
          'degree': degree,
          'marks': marks,
          'status': status,
          'completion_year': completionYear,
        },
      );
      return response.data != null;
    } catch (e) {
      print('Error adding qualification: $e');
      return false;
    }
  }

  // Update qualification
  Future<bool> updateQualification(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase.functions.invoke('update-qualification',
        body: {'id': id, ...updates},
      );
      return response.data != null;
    } catch (e) {
      print('Error updating qualification: $e');
      return false;
    }
  }

  // Delete qualification
  Future<bool> deleteQualification(String id) async {
    try {
      final response = await _supabase.functions.invoke('delete-qualification',
        body: {'id': id},
      );
      return response.data != null;
    } catch (e) {
      print('Error deleting qualification: $e');
      return false;
    }
  }

  // Get matched jobs
  Future<Map<String, dynamic>?> getMatchedJobs() async {
    try {
      final response = await _supabase.functions.invoke('get-matched-jobs');
      return response.data['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting matched jobs: $e');
      return null;
    }
  }

  // Toggle important job
  Future<bool> toggleImportantJob(String jobId) async {
    try {
      final response = await _supabase.functions.invoke('toggle-important-job',
        body: {'job_id': jobId},
      );
      return response.data != null;
    } catch (e) {
      print('Error toggling important job: $e');
      return false;
    }
  }

  // Get comments for a job
  Future<List<dynamic>?> getComments(String jobId, {String sortBy = 'top'}) async {
    try {
      final response = await _supabase.functions.invoke('get-comments',
        body: {'job_id': jobId, 'sort_by': sortBy},
      );
      return response.data['data'] as List<dynamic>?;
    } catch (e) {
      print('Error getting comments: $e');
      return null;
    }
  }

  // Post comment
  Future<bool> postComment({
    required String jobId,
    required String commentText,
    String? parentCommentId,
  }) async {
    try {
      final response = await _supabase.functions.invoke('post-comment',
        body: {
          'job_id': jobId,
          'comment_text': commentText,
          'parent_comment_id': parentCommentId,
        },
      );
      return response.data != null;
    } catch (e) {
      print('Error posting comment: $e');
      return false;
    }
  }

  // Upvote comment
  Future<bool> upvoteComment(String commentId) async {
    try {
      final response = await _supabase.functions.invoke('upvote-comment',
        body: {'comment_id': commentId},
      );
      return response.data != null;
    } catch (e) {
      print('Error upvoting comment: $e');
      return false;
    }
  }

  // Report comment
  Future<bool> reportComment(String commentId) async {
    try {
      final response = await _supabase.functions.invoke('report-comment',
        body: {'comment_id': commentId},
      );
      return response.data != null;
    } catch (e) {
      print('Error reporting comment: $e');
      return false;
    }
  }

  // Get user's important jobs
  Future<List<dynamic>> getImportantJobs() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('user_important_jobs')
          .select('job_id, jobs(*)')
          .eq('user_id', userId);
      return response as List<dynamic>;
    } catch (e) {
      print('Error getting important jobs: $e');
      return [];
    }
  }
}
