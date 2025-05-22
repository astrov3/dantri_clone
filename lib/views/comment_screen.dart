import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/video_viewmodel.dart';

class CommentScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final String channelTitle;
  final VideoViewModel viewModel; // Thêm tham số này

  const CommentScreen({
    Key? key,
    required this.videoId,
    required this.videoTitle,
    required this.channelTitle,
    required this.viewModel, // Yêu cầu truyền viewModel
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Provider.value để chia sẻ instance của VideoViewModel
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<VideoViewModel>(
        builder: (context, viewModel, child) {
          List<String> comments = viewModel.getComments(widget.videoId);

          return Scaffold(
            appBar: AppBar(
              title: Text('Bình luận (${comments.length})'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Thông tin video
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.videoTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${widget.channelTitle}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Phần nhập bình luận
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Thêm bình luận...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_commentController.text.trim().isNotEmpty) {
                            viewModel.addComment(
                              widget.videoId,
                              _commentController.text.trim(),
                            );
                            _commentController.clear();
                            _focusNode.unfocus();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Gửi'),
                      ),
                    ],
                  ),
                ),
                
                // Nút sắp xếp bình luận
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.sort),
                      const SizedBox(width: 8),
                      const Text(
                        'Sắp xếp theo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'newest',
                            child: Text('Mới nhất'),
                          ),
                          const PopupMenuItem(
                            value: 'popular',
                            child: Text('Phổ biến nhất'),
                          ),
                        ],
                        onSelected: (value) {
                          // Có thể thêm logic sắp xếp ở đây
                        },
                        child: const Text(
                          'Mới nhất',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Danh sách bình luận
                Expanded(
                  child: comments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa có bình luận nào.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Hãy là người đầu tiên bình luận về video này!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return FullCommentItem(
                              channelTitle: widget.channelTitle,
                              comment: comments[index],
                              onReply: (replyText) {
                                // Có thể thêm chức năng trả lời bình luận ở đây
                                viewModel.addComment(
                                  widget.videoId,
                                  '@${widget.channelTitle} $replyText',
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullCommentItem extends StatefulWidget {
  final String channelTitle;
  final String comment;
  final Function(String) onReply;

  const FullCommentItem({
    Key? key,
    required this.channelTitle,
    required this.comment,
    required this.onReply,
  }) : super(key: key);

  @override
  State<FullCommentItem> createState() => _FullCommentItemState();
}

class _FullCommentItemState extends State<FullCommentItem> {
  bool _isLiked = false;
  bool _isReplyVisible = false;
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '@${widget.channelTitle}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '2 phút trước',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.comment,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16,
                              color: _isLiked ? Colors.blue : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isLiked ? '1' : '0',
                              style: TextStyle(
                                color: _isLiked ? Colors.blue : Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isReplyVisible = !_isReplyVisible;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Trả lời',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_isReplyVisible)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Viết phản hồi...',
                      border: OutlineInputBorder(),
                       contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_replyController.text.trim().isNotEmpty) {
                      widget.onReply(_replyController.text.trim());
                      _replyController.clear();
                      setState(() {
                        _isReplyVisible = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}