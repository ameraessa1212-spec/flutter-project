import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/core/services/pusher_service.dart';
import 'package:Waslaa/features/chat/models/chat_models.dart';
import 'package:Waslaa/features/chat/repositories/chat_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final int? threadId;
  final int? internshipId;

  const ChatPage({super.key, this.threadId, this.internshipId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  ChatThread? _activeThread;
  int? _activeThreadId;
  int? _currentUserId;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    if (_activeThreadId != null) {
      PusherService().unsubscribeFromChat(_activeThreadId!);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    try {
      _currentUserId = context.read<AppSessionController>().currentUser?.id;
      final repo = context.read<ChatRepository>();
      final explicitThreadId = widget.threadId;
      final explicitInternshipId = widget.internshipId;
      if (explicitThreadId != null) {
        _activeThreadId = explicitThreadId;
        _activeThread = await repo.getThread(explicitThreadId);
      } else {
        final threads = await repo.getThreads();
        if (threads.isNotEmpty) {
          ChatThread? matchedThread;
          if (explicitInternshipId != null) {
            for (final thread in threads) {
              if (thread.internshipId == explicitInternshipId) {
                matchedThread = thread;
                break;
              }
            }
          } else {
            matchedThread = threads.first;
          }
          if (matchedThread != null) {
            _activeThreadId = matchedThread.id;
            _activeThread = matchedThread;
          }
        }
      }

      if (_activeThreadId != null) {
        final msgs = await repo.getMessages(_activeThreadId!);
        if (!mounted) return;
        setState(() {
          _messages.clear();
          _messages.addAll(msgs.reversed);
          _isLoading = false;
        });
        _scrollToBottom();
        await repo.markRead(_activeThreadId!);

        // Subscribe to Pusher channel
        PusherService().subscribeToChat(_activeThreadId!, (messageData) {
          final newMessage = ChatMessage.fromJson(messageData);
          if (mounted && newMessage.senderId != _currentUserId) {
            setState(() {
              _messages.add(newMessage);
            });
            _scrollToBottom();
          }
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message ?? 'تعذر تحميل المحادثة';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMessages() async {
    final threadId = _activeThreadId;
    if (threadId == null) {
      return;
    }

    try {
      final repo = context.read<ChatRepository>();
      final msgs = await repo.getMessages(threadId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(msgs.reversed);
      });
      await repo.markRead(threadId);
      _scrollToBottom();
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'تعذر تحديث الرسائل')),
      );
    }
  }

  String _parseTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _sendAttachment(
        filePath: image.path,
        fileName: image.name,
        messageType: 'image',
      );
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;
      if (file.path != null) {
        await _sendAttachment(filePath: file.path!, fileName: file.name);
      }
    }
  }

  Future<void> _sendAttachment({
    required String filePath,
    String? fileName,
    String messageType = 'file',
  }) async {
    final threadId = _activeThreadId;
    if (threadId == null || _isSending) return;

    setState(() => _isSending = true);
    try {
      final repo = context.read<ChatRepository>();
      final message = await repo.sendAttachment(
        threadId,
        filePath: filePath,
        fileName: fileName,
        messageType: messageType,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'تعذر إرسال المرفق')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendMessage() async {
    final threadId = _activeThreadId;
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || threadId == null) return;

    setState(() {
      _isSending = true;
    });
    _messageController.clear();

    try {
      final repo = context.read<ChatRepository>();
      final message = await repo.sendMessage(threadId, body: text);
      if (!mounted) return;
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'تعذر إرسال الرسالة')),
      );
    }

    if (mounted) setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "إرفاق ملف",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOption(
                      Icons.insert_drive_file_rounded,
                      "ملف",
                      Colors.orange,
                      _pickFile,
                    ),
                    _buildOption(
                      Icons.image_outlined,
                      "صورة",
                      Colors.pink,
                      _pickImage,
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _callPhone(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _renderMessageContent(ChatMessage msg) {
    final isFile =
        msg.messageType == 'file' ||
        msg.messageType == 'attachment' ||
        msg.messageType == 'image';
    final firstAttachment =
        msg.attachments.isNotEmpty ? msg.attachments.first : null;

    if (isFile) {
      final attachmentLabel = firstAttachment?.fileName ?? msg.body ?? 'مرفق';
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_rounded,
              color: _isMyMessage(msg) ? Colors.white : primarycolor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                attachmentLabel,
                style: TextStyle(
                  color: _isMyMessage(msg) ? Colors.white : Colors.black87,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(
        msg.body ?? '',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: _isMyMessage(msg) ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  bool _isMyMessage(ChatMessage msg) {
    final currentUserId = _currentUserId;
    return currentUserId != null && msg.senderId == currentUserId;
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final bool isMe = _isMyMessage(msg);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        decoration: BoxDecoration(
          color: isMe ? primarycolor : const Color(0xFFF0ECEC),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 6),
            bottomRight: Radius.circular(isMe ? 6 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderMessageContent(msg),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                _parseTime(msg.sentAt ?? msg.createdAt ?? ''),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black45,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isEnabled = _activeThreadId != null && !_isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primarycolor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: isEnabled ? _sendMessage : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: AppDimensions.screenWidth * 0.08,
              height: AppDimensions.screenHeight * 0.050,
              decoration: BoxDecoration(
                color: primarycolor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: primarycolor, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: isEnabled,
              textAlign: TextAlign.right,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "اكتب رسالتك هنا...",
                hintStyle: TextStyle(fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: isEnabled ? _showAttachmentOptions : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: AppDimensions.screenWidth * 0.08,
              height: AppDimensions.screenHeight * 0.050,
              decoration: BoxDecoration(
                color: primarycolor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: primarycolor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final thread = _activeThread;
    final supervisorName = thread?.supervisorName ?? 'المشرف غير متاح';
    final companyName = thread?.companyName ?? '';
    final supervisorPhone = thread?.supervisorPhone;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap:
                supervisorPhone != null && supervisorPhone.isNotEmpty
                    ? () => _callPhone(supervisorPhone)
                    : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: AppDimensions.screenWidth * 0.08,
              height: AppDimensions.screenHeight * 0.050,
              decoration: BoxDecoration(
                color: primarycolor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_outlined, color: primarycolor, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap:
                supervisorPhone != null && supervisorPhone.isNotEmpty
                    ? () => _openWhatsApp(supervisorPhone)
                    : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: AppDimensions.screenWidth * 0.08,
              height: AppDimensions.screenHeight * 0.050,
              decoration: BoxDecoration(
                color: primarycolor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.message_outlined,
                color: primarycolor,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                supervisorName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                companyName.isNotEmpty ? companyName : 'المشرف المباشر',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8E8E8),
            child: Icon(Icons.person, color: primarycolor, size: 24),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 44,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 10),
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _initChat,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _activeThreadId == null
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا توجد محادثات متاحة حالياً لهذا التدريب.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: _refreshMessages,
                        child:
                            _messages.isEmpty
                                ? ListView(
                                  padding: const EdgeInsets.all(24),
                                  children: const [
                                    SizedBox(height: 120),
                                    Text(
                                      'ابدأ المحادثة مع المشرف بإرسال أول رسالة.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    return _buildMessageItem(_messages[index]);
                                  },
                                ),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: _buildInputArea(),
            ),
          ],
        ),
      ),
    );
  }
}
