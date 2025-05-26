import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/video_viewmodel.dart';

class CommentScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final String channelTitle;
  final VideoViewModel viewModel;
  final String currentUserName;

  const CommentScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.channelTitle,
    required this.viewModel,
    required this.currentUserName,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  bool _isInitialized = false;
  bool _isSendingComment = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    Future.microtask(() {
      if (!_isInitialized) {
        widget.viewModel.fetchComments(widget.videoId);
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () {
                      _animationController.reverse().then((_) {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${widget.channelTitle}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.videoTitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Comments List
            Expanded(
              child: Consumer<VideoViewModel>(
                builder: (context, viewModel, _) {
                  final comments = viewModel.getComments(widget.videoId);

                  if (viewModel.isLoadingComments[widget.videoId] == true) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }

                  if (comments.isEmpty) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Không có bình luận',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: Colors.green,
                    onRefresh: () async {
                      await viewModel.fetchComments(widget.videoId);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final snippet =
                            comment['snippet']['topLevelComment']['snippet']
                                as Map<String, dynamic>;

                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                index / comments.length,
                                (index + 1) / comments.length,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[200],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      snippet['authorProfileImageUrl']
                                              as String? ??
                                          'https://via.placeholder.com/40',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Icon(
                                            Icons.person,
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Comment content
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Username and time
                                        Row(
                                          children: [
                                            Text(
                                              snippet['authorDisplayName']
                                                  as String,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(
                                                snippet['publishedAt'] as String,
                                              ),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Comment text
                                        Text(
                                          snippet['textDisplay'] as String,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Like button
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.favorite_border,
                                                color: Colors.grey[600],
                                                size: 20,
                                              ),
                                              onPressed: () {},
                                            ),
                                            Text(
                                              '0',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSendingComment ? Colors.grey : Colors.green,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSendingComment ? Colors.grey : Colors.green)
                              .withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: _isSendingComment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSendingComment ? null : () async {
                        final comment = _commentController.text.trim();
                        if (comment.isNotEmpty) {
                          setState(() {
                            _isSendingComment = true;
                          });

                          try {
                            // Gửi comment lên YouTube (đã bao gồm refresh trong method)
                            await widget.viewModel.addCommentFromApi(widget.videoId, comment);

                            // Thêm bình luận mới vào danh sách tạm thời để hiển thị ngay
                            widget.viewModel.addLocalComment(widget.videoId, {
                              "snippet": {
                                "topLevelComment": {
                                  "snippet": {
                                    "authorDisplayName": widget.currentUserName,
                                    "authorProfileImageUrl": "https://via.placeholder.com/40",
                                    "publishedAt": DateTime.now().toIso8601String(),
                                    "textDisplay": comment,
                                  }
                                }
                              }
                            });

                            // Clear input
                            _commentController.clear();
                            FocusScope.of(context).unfocus();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bình luận đã được gửi'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }

                            // KHÔNG fetch lại comments ở đây!
                            // Nếu muốn đồng bộ, chỉ fetch khi người dùng kéo để refresh.
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi khi gửi bình luận: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSendingComment = false;
                              });
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return isoDate;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}