import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/models.dart';

class CommunityScreen extends StatefulWidget {
  final String jobId;

  const CommunityScreen({super.key, required this.jobId});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Comment> _comments = [];
  bool _isLoading = true;
  String _sortBy = 'top';
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    final supabaseService = context.read<SupabaseService>();
    final result = await supabaseService.getComments(widget.jobId, sortBy: _sortBy);

    if (result != null) {
      setState(() {
        _comments = result.map((c) => Comment.fromJson(c)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postComment({String? parentId}) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final supabaseService = context.read<SupabaseService>();
    final success = await supabaseService.postComment(
      jobId: widget.jobId,
      commentText: text,
      parentCommentId: parentId,
    );

    if (success) {
      _commentController.clear();
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Discussion'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (value) {
              setState(() => _sortBy = value);
              _loadComments();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'top', child: Text('Top Comments')),
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to start the discussion!',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _CommentCard(
                            comment: _comments[index],
                            onUpvote: () async {
                              final supabaseService = context.read<SupabaseService>();
                              await supabaseService.upvoteComment(_comments[index].id);
                              _loadComments();
                            },
                            onReport: () async {
                              final supabaseService = context.read<SupabaseService>();
                              await supabaseService.reportComment(_comments[index].id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Comment reported')),
                              );
                            },
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _postComment,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final VoidCallback onUpvote;
  final VoidCallback onReport;

  const _CommentCard({
    required this.comment,
    required this.onUpvote,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(comment.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    comment.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') onReport();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(comment.commentText),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: onUpvote,
                ),
                Text('${comment.upvotes}'),
                const SizedBox(width: 16),
                if (comment.replies.isNotEmpty) ...[
                  Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${comment.replies.length} replies',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            if (comment.replies.isNotEmpty) ...[
              const Divider(),
              ...comment.replies.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 24, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reply.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(reply.commentText, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
