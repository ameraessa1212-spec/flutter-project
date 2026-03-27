import 'dart:async';
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
  final int? receiverId;
  final String? receiverName;

  const ChatPage({
    super.key,
    this.threadId,
    this.internshipId,
    this.receiverId,
    this.receiverName,
  });

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
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _initChat();

    // Start polling for new messages if in support chat mode
    if (widget.receiverId != null) {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _pollChatifyMessages();
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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

      // If receiverId is explicitly provided (Support Chat)
      if (widget.receiverId != null) {
        _activeThreadId = null; // We are in Chatify mode
        final msgs = await repo.getChatifyMessages(widget.receiverId!);
        if (mounted) {
          setState(() {
            _messages
              ..clear()
              ..addAll(msgs);
            _isLoading = false;
          });
          _scrollToBottom();
        }
        return;
      }

      // Legacy/Thread-based logic (can still map to Chatify if we want)
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

        // Ensure Pusher is initialized before subscribing
        await PusherService().initPusher();

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

  Future<void> _pollChatifyMessages() async {
    if (widget.receiverId == null || _isSending) return;

    try {
      final repo = context.read<ChatRepository>();
      final msgs = await repo.getChatifyMessages(widget.receiverId!);

      // Only update if there are new messages or anything changed
      if (mounted && msgs.length != _messages.length) {
        setState(() {
          _messages
            ..clear()
            ..addAll(msgs);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Polling error: $e');
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
    final receiverId = widget.receiverId;
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    if (threadId == null && receiverId == null) return;

    setState(() {
      _isSending = true;
    });
    _messageController.clear();

    try {
      final repo = context.read<ChatRepository>();
      ChatMessage message;
      if (receiverId != null) {
        message = await repo.sendChatifyMessage(receiverId, text);
        // For UI feedback, set current user as sender
        message = ChatMessage(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          senderId: _currentUserId ?? 0,
          body: text,
          messageType: 'text',
          createdAt: DateTime.now().toIso8601String(),
        );
      } else {
        message = await repo.sendMessage(threadId!, body: text);
      }

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
    final isImage = msg.messageType == 'image';
    final isFile = msg.messageType == 'file' || msg.messageType == 'attachment';
    final isMe = _isMyMessage(msg);
    final firstAttachment =
        msg.attachments.isNotEmpty ? msg.attachments.first : null;

    if (isImage && firstAttachment?.fileUrl != null) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            firstAttachment!.fileUrl!,
            fit: BoxFit.cover,
            width: 200,
            errorBuilder:
                (_, __, ___) => const Icon(Icons.broken_image, size: 40),
          ),
        ),
      );
    }

    if (isFile) {
      final attachmentLabel = firstAttachment?.fileName ?? msg.body ?? 'مرفق';
      return Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap:
              () =>
                  firstAttachment?.fileUrl != null
                      ? launchUrl(Uri.parse(firstAttachment!.fileUrl!))
                      : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white24 : primarycolor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  size: 20,
                  color: isMe ? Colors.white : primarycolor,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  attachmentLabel,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        msg.body ?? '',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 14.5,
          height: 1.4,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 16, color: Colors.grey),
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                decoration: BoxDecoration(
                  color: isMe ? primarycolor : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _renderMessageContent(msg),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              right: isMe ? 4 : 42,
              left: isMe ? 4 : 4,
            ),
            child: Text(
              _parseTime(msg.sentAt ?? msg.createdAt ?? ''),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isEnabled =
        (_activeThreadId != null || widget.receiverId != null) && !_isLoading;

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
    final supervisorName =
        widget.receiverId != null
            ? (widget.receiverName ?? 'الدعم الفني')
            : (thread?.supervisorName ?? 'المشرف غير متاح');
    final companyName =
        thread?.companyName ?? (widget.receiverId != null ? 'نظام وصلة' : '');
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
                      : (_activeThreadId == null && widget.receiverId == null)
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
