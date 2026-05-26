import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:mobile_app/src/core/data/remote/services/groq_service.dart';
import 'package:mobile_app/src/core/data/remote/services/user_profile_service.dart';
import 'package:mobile_app/src/common/utils/getit_utils.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _healthConditions = [];
  late List<Map<String, String>> _messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHealthConditions();
  }

  Future<void> _loadHealthConditions() async {
    final conditions = await getIt<UserProfileService>().getHealthConditions();
    setState(() {
      _healthConditions = conditions;
      _initMessages();
    });
  }

  void _initMessages() {
    final conditionsText = _healthConditions.isEmpty
        ? "Người dùng khỏe mạnh."
        : "Người dùng có các vấn đề sức khỏe: ${_healthConditions.join(', ')}.";

    _messages = [
      {"role": "system", "content": "Bạn là trợ lý AI SafeBite, chuyên gia về dinh dưỡng và an toàn thực phẩm. $conditionsText CHỈ trả lời các câu hỏi về: dinh dưỡng, thành phần thực phẩm, an toàn thực phẩm, sức khỏe, ăn uống lành mạnh. Trả lời ngắn gọn thôi. Nếu câu hỏi không liên quan đến các chủ đề này, hãy nói: 'Tôi chỉ có thể hỗ trợ về dinh dưỡng và an toàn thực phẩm. Bạn có thể hỏi tôi về các chủ đề này nhé!' trả lời bằng tiếng Việt."},
      {"role": "user", "content": "Xin chào! Tôi có thể hỏi về dinh dưỡng và an toàn thực phẩm không?"},
      {"role": "assistant", "content": "Xin chào! Tôi là trợ lý AI của SafeBite, chuyên về dinh dưỡng và an toàn thực phẩm. Bạn có thể hỏi tôi bất kỳ câu hỏi nào về thành phần dinh dưỡng, an toàn thực phẩm, hoặc lời khuyên ăn uống lành mạnh. Tôi sẽ trả lời bằng tiếng Việt. Hãy hỏi thôi!"},
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await getIt<GroqService>().chat(_messages);

    setState(() {
      _isLoading = false;
      if (response != null) {
        _messages.add({"role": "assistant", "content": response});
      } else {
        _messages.add({"role": "assistant", "content": "Xin lỗi, tôi gặp lỗi kết nối. Vui lòng thử lại sau."});
      }
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.scaffoldBackgroundLight),
      child: SafeArea(
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: AppColors.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('AI Assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length - 1,
                itemBuilder: (context, index) {

                  if (index == 0 && _messages[0]["role"] == "system") {
                    return const SizedBox.shrink();
                  }
                  final message = _messages[index + 1];
                  final isUser = message["role"] == "user";
                  return _ChatBubble(message: message["content"] ?? "", isUser: isUser);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen)),
                    SizedBox(width: 12),
                    Text('AI đang trả lời...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  const _ChatBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 48, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
