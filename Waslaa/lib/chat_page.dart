import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Waslla/const/app_dimensions.dart';
import 'package:Waslla/const/color.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "type": "text",
      "content": "مرحباً بك يا طالب، هل بدأت في كتابة التقرير؟",
      "isMe": false,
      "time": "10:30",
    },
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _messages.add({
          "type": "image",
          "content": image.path,
          "isMe": true,
          "time": _formattedTime(),
        });
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _messages.add({
          "type": "file",
          "content": result.files.single.name,
          "isMe": true,
          "time": _formattedTime(),
        });
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "type": "text",
          "content": _messageController.text.trim(),
          "isMe": true,
          "time": _formattedTime(),
        });
      });

      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _formattedTime() {
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
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

  void _showFullScreenImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(child: Image.file(File(path))),
            ),
      ),
    );
  }

  Widget _renderMessageContent(Map<String, dynamic> msg) {
    if (msg['type'] == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(msg['content']),
          fit: BoxFit.cover,
          width: 220,
          height: 180,
        ),
      );
    } else if (msg['type'] == 'file') {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_rounded,
              color: msg['isMe'] ? Colors.white : primarycolor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                msg['content'],
                style: TextStyle(
                  color: msg['isMe'] ? Colors.white : Colors.black87,
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
        msg['content'],
        textAlign: TextAlign.right,
        style: TextStyle(
          color: msg['isMe'] ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (msg['type'] == 'image') {
            _showFullScreenImage(msg['content']);
          }
        },
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
                  msg['time'] ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black45,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
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
            onTap: _sendMessage,
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
            onTap: _showAttachmentOptions,
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
            onTap: () => _callPhone("0915004645"),
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
            onTap: () => _openWhatsApp("0915004645"),
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
            children: const [
              Text(
                "Nabil Kamal",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "المشرف المباشر",
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
              child: ListView.builder(
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
