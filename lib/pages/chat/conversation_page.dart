import 'dart:async';
import 'dart:io';

import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationPage extends StatefulWidget {
  final String barberId;
  final String barberName;
  final String? barberImageUrl;

  const ConversationPage({
    super.key,
    required this.barberId,
    required this.barberName,
    this.barberImageUrl,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  final List<ChatMessage> _messages = [];
  Timer? _pollingTimer;
  bool _isLoading = true;
  bool _isPolling = false;
  String? _userId;
  String? _barberImageUrl;
  String? _myImagePath;
  bool _isSending = false;
  bool _showEmojiPicker = false;
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _isAppInForeground = true;
  int _consecutiveEmptyPolls = 0;
  static const int _maxEmptyPollsBeforeSlowdown = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadUserAndConversation();
    _barberImageUrl = _resolveInitialBarberImage();
    if (_barberImageUrl == null || _barberImageUrl!.isEmpty) {
      _loadBarberImage();
    }
    _loadMyImagePath();
  }

  String? _resolveInitialBarberImage() {
    final img = widget.barberImageUrl ?? '';
    if (img.isEmpty) return null;
    return img.startsWith('http') ? img : '${Constants.imageBaseUrl}$img';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isAppInForeground = state == AppLifecycleState.resumed;

    if (_isAppInForeground) {
      _consecutiveEmptyPolls = 0;
      if (!_isPolling && _userId != null && widget.barberId.isNotEmpty) {
        _startLongPolling();
      }
    } else {
      _stopPolling();
    }
  }

  Future<void> _loadUserAndConversation() async {
    final storage = getIt<LocalStorage>();
    final userId = await storage.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = userId;
    });
    if (_userId != null && widget.barberId.isNotEmpty) {
      _startLongPolling();
    }
  }

  Future<void> _loadBarberImage() async {
    final useCase = getIt<GetBarberShopsUseCase>();
    final result = await useCase(const BarberShopQuery(limit: 100, page: 1));
    if (!mounted) return;
    result.fold(
          (_) {},
          (shops) {
        if (shops.isEmpty) return;
        final match = shops.firstWhere(
              (shop) => shop.id == widget.barberId,
          orElse: () => shops.first,
        );
        final img = match.img;
        final resolved = img.isEmpty
            ? ''
            : (img.startsWith('http') ? img : '${Constants.imageBaseUrl}$img');
        if (resolved.isNotEmpty && mounted) {
          setState(() {
            _barberImageUrl = resolved;
          });
        }
      },
    );
  }

  Future<void> _loadMyImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (!mounted) return;
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _myImagePath = imagePath;
      });
    }
  }

  void _startLongPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollingTimer?.cancel();
    _pollingTimer = Timer(const Duration(milliseconds: 100), _pollOnce);
  }

  void _stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
  }

  int _getPollingInterval() {
    if (_consecutiveEmptyPolls < _maxEmptyPollsBeforeSlowdown) {
      return 2000;
    } else if (_consecutiveEmptyPolls < _maxEmptyPollsBeforeSlowdown * 2) {
      return 4000;
    } else {
      return 6000;
    }
  }

  Future<void> _pollOnce() async {
    if (!mounted ||
        _userId == null ||
        widget.barberId.isEmpty ||
        !_isAppInForeground) {
      _isPolling = false;
      return;
    }

    final repository = getIt<ChatRepository>();
    final previousMessageCount = _messages.length;

    final result = await repository.getConversation(
      userId: _userId!,
      barberId: widget.barberId,
    );

    if (!mounted) return;

    result.fold(
          (failure) {
        _consecutiveEmptyPolls++;
      },
          (messages) {
        final hasNewMessages = messages.length > previousMessageCount;
        final isInitialLoad =
            previousMessageCount == 0 && messages.isNotEmpty;

        if (mounted) {
          setState(() {
            _isLoading = false;
            _messages
              ..clear()
              ..addAll(messages);
          });
        }

        if (isInitialLoad) {
          _consecutiveEmptyPolls = 0;
          _scrollToBottom(animated: false);
        } else if (hasNewMessages) {
          _consecutiveEmptyPolls = 0;
          _scrollToBottom();
        } else {
          _consecutiveEmptyPolls++;
        }
      },
    );

    if (_isPolling) {
      final interval = _getPollingInterval();
      _pollingTimer = Timer(Duration(milliseconds: interval), _pollOnce);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(position);
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _stopPolling();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedImagePath == null) return;
    if (_isSending) return;
    if (_userId == null || widget.barberId.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final repository = getIt<ChatRepository>();
    final result = await repository.sendMessage(
      message: text,
      barberId: widget.barberId,
      imagePath: _selectedImagePath,
    );

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
          (_) {
        _messageController.clear();
        setState(() {
          _selectedImagePath = null;
        });
        _consecutiveEmptyPolls = 0;
        _pollOnce();
      },
    );
  }

  Future<void> _sendImageMessages(List<String> paths) async {
    if (paths.isEmpty || _isSending) return;
    if (_userId == null || widget.barberId.isEmpty) return;

    final text = _messageController.text.trim();
    setState(() {
      _isSending = true;
    });

    final repository = getIt<ChatRepository>();
    for (var i = 0; i < paths.length; i++) {
      final message = i == 0 ? text : '';
      final result = await repository.sendMessage(
        message: message,
        barberId: widget.barberId,
        imagePath: paths[i],
      );
      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (_) {},
      );
    }

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });
    _messageController.clear();
    _consecutiveEmptyPolls = 0;
    _pollOnce();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(child: _buildMessageList(isDark)),
            if (_selectedImagePath != null) _buildImagePreview(isDark),
            _buildInputArea(isDark),
            if (_showEmojiPicker) _buildEmojiPicker(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDark : AppColors.containerLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildBarberAvatar(
                title: widget.barberName,
                size: 48.w,
                fontSize: 16.sp,
                radius: 12.r,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    widget.barberName,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: Colors.grey),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDark : AppColors.containerLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  File(_selectedImagePath!),
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4.h,
                right: 4.w,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Rasm tanlandi'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryDark,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.yellow),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.sp,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'Xabar yo\'q'.tr(),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      );
    }
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: child,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: _messages.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.containerDark
                      : AppColors.containerLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'Bugun'.tr(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          final message = _messages[index - 1];
          return _buildMessageBubble(message, index - 1, isDark);
        },
      ),
    );
  }

  bool _isSent(ChatMessage message) {
    if (_userId == null) return false;
    if (message.senderRole.isNotEmpty) {
      return message.senderRole == 'user';
    }
    return message.userId == _userId;
  }

  String _formatMessageTime(String raw) {
    if (raw.isEmpty) return '';
    final millis = int.tryParse(raw);
    DateTime? date;
    if (millis != null) {
      date = DateTime.fromMillisecondsSinceEpoch(millis);
    } else {
      date = DateTime.tryParse(raw);
    }
    if (date == null) return raw;
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _avatarText(String title) {
    final parts = title.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final letters = parts.map((part) => part[0]).take(2).join();
    return letters.toUpperCase();
  }

  Widget _buildBarberAvatar({
    required String title,
    required double size,
    required double fontSize,
    required double radius,
  }) {
    if (_barberImageUrl == null || _barberImageUrl!.isEmpty) {
      return Text(
        _avatarText(title),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        _barberImageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Text(
          _avatarText(title),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }

  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index, bool isDark) {
    final isSent = _isSent(message);
    final delay = index * 50;
    final imageUrl = message.imageUrl;
    final resolvedImageUrl = imageUrl.isEmpty
        ? ''
        : (imageUrl.startsWith('http')
        ? imageUrl
        : '${Constants.imageBaseUrl}$imageUrl');
    final hasImage = resolvedImageUrl.isNotEmpty;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          mainAxisAlignment:
          isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSent) ...[
              Container(
                width: 32.w,
                height: 32.h,
                margin: EdgeInsets.only(right: 8.w, bottom: 20.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradient1, AppColors.gradient2],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _buildBarberAvatar(
                    title: widget.barberName,
                    size: 32.w,
                    fontSize: 12.sp,
                    radius: 10.r,
                  ),
                ),
              ),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isSent
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: hasImage ? 4.w : 16.w,
                      vertical: hasImage ? 4.h : 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSent
                          ? AppColors.yellow
                          : (isDark
                          ? AppColors.containerDark
                          : AppColors.containerLight),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18.r),
                        topRight: Radius.circular(18.r),
                        bottomLeft:
                        isSent ? Radius.circular(18.r) : Radius.circular(4.r),
                        bottomRight:
                        isSent ? Radius.circular(4.r) : Radius.circular(18.r),
                      ),
                      border: isSent
                          ? null
                          : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      boxShadow: isSent
                          ? [
                        BoxShadow(
                          color: AppColors.yellow.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasImage) ...[
                          GestureDetector(
                            onTap: () => _openFullScreenImage(resolvedImageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: Image.network(
                                resolvedImageUrl,
                                width: 200.w,
                                height: 200.h,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 200.w,
                                    height: 200.h,
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes !=
                                            null
                                            ? loadingProgress
                                            .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: AppColors.yellow,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  width: 200.w,
                                  height: 200.h,
                                  color: Colors.black.withValues(alpha: 0.2),
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 48.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (message.message.isNotEmpty) ...[
                          if (hasImage) SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: hasImage ? 12.w : 0,
                              vertical: hasImage ? 8.h : 0,
                            ),
                            child: Text(
                              message.message,
                              style: TextStyle(
                                color: isSent
                                    ? Colors.white
                                    : (isDark
                                    ? Colors.white
                                    : AppColors.primaryDark),
                                fontSize: 15.sp,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 8.w, right: 8.w),
                    child: Text(
                      _formatMessageTime(message.createdAt),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSent) ...[
              Container(
                width: 32.w,
                height: 32.h,
                margin: EdgeInsets.only(left: 8.w, bottom: 20.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradient1, AppColors.gradient2],
                  ),
                  shape: BoxShape.circle,
                ),
                child: _buildMyAvatar(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyAvatar() {
    final path = _myImagePath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }
    }
    return Center(
      child: Text(
        'MEN'.tr(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerDark : AppColors.containerLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: _showImageSourceSheet,
                    ),
                    Expanded(
                      child: TextField(
                        focusNode: _messageFocusNode,
                        controller: _messageController,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Xabar yozing...'.tr(),
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        onTap: () {
                          if (_showEmojiPicker) {
                            setState(() {
                              _showEmojiPicker = false;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                        if (_showEmojiPicker) {
                          _messageFocusNode.unfocus();
                        } else {
                          _messageFocusNode.requestFocus();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradient1, AppColors.gradient2],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: _isSending ? null : _sendMessage,
                  child: Center(
                    child: _isSending
                        ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.containerDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: AppColors.yellow,
                    ),
                  ),
                  title: Text(
                    'Galereyadan'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickMultipleImages();
                  },
                ),
                SizedBox(height: 8.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      color: AppColors.yellow,
                    ),
                  ),
                  title: Text(
                    'Kameradan'.tr(),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickSingleImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickSingleImage(ImageSource source) async {
    final image =
        await _imagePicker.pickImage(source: source, imageQuality: 80);
    if (!mounted || image == null) return;
    setState(() {
      _selectedImagePath = image.path;
    });
  }

  Future<void> _pickMultipleImages() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 80);
    if (!mounted || images.isEmpty) return;
    final paths = images.map((item) => item.path).toList();
    await _sendImageMessages(paths);
  }

  Widget _buildEmojiPicker(bool isDark) {
    return SizedBox(
      height: 260.h,
      child: EmojiPicker(
        textEditingController: _messageController,
        onEmojiSelected: (_, __) {},
        config: Config(
          height: 260.h,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            backgroundColor:
            isDark ? AppColors.backgroundDark : Colors.white,
            columns: 7,
            emojiSizeMax: 32,
          ),
          skinToneConfig: SkinToneConfig(
            enabled: true,
            dialogBackgroundColor:
            isDark ? AppColors.containerDark : Colors.white,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor:
            isDark ? AppColors.containerDark : AppColors.containerLight,
            iconColorSelected: AppColors.yellow,
            indicatorColor: AppColors.yellow,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor:
            isDark ? AppColors.containerDark : AppColors.containerLight,
            buttonColor:
            isDark ? AppColors.backgroundDark : Colors.white,
            buttonIconColor: AppColors.yellow,
          ),
        ),
      ),
    );
  }
}

// Full Screen Image Viewer
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppColors.yellow,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
