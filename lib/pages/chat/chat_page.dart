import 'dart:async';

import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';
import 'package:bar_bros_user/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:bar_bros_user/features/chat/presentation/bloc/chat_event.dart';
import 'package:bar_bros_user/features/chat/presentation/bloc/chat_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'conversation_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final ChatBloc _chatBloc;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, BarberShopItem> _barberIndex = {};
  bool _hasLoadedBarbers = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _chatBloc = getIt<ChatBloc>();
    _chatBloc.add(const GetMyChatsEvent());
    _searchController.addListener(_onSearchChanged);
    _loadBarbershops();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  Future<void> _loadBarbershops() async {
    if (_hasLoadedBarbers) return;

    final useCase = getIt<GetBarberShopsUseCase>();
    final result = await useCase(const BarberShopQuery(limit: 100, page: 1));

    if (!mounted) return;

    result.fold(
          (_) {},
          (shops) {
        if (mounted) {
          setState(() {
            _barberIndex
              ..clear()
              ..addEntries(shops.map((item) => MapEntry(item.id, item)));
            _hasLoadedBarbers = true;
          });
        }
      },
    );
  }

  List<ChatThread> _filteredChats(List<ChatThread> chats) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return chats;

    final terms = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return chats;

    return chats.where((chat) {
      final name = _threadTitle(chat).toLowerCase();
      return terms.every(name.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocProvider.value(
      value: _chatBloc,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(isDark),
              Expanded(child: _buildChatList(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.containerDark : AppColors.containerLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.8),
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
          decoration: InputDecoration(
            hintText: 'suhbatlarni_qidirish'.tr(),
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.yellow),
          );
        }
        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }
        if (state is ChatThreadsLoaded) {
          final merged = _mergeThreadsByBarber(state.threads);
          final filtered = _filteredChats(merged);

          if (filtered.isEmpty) {
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
                    _searchQuery.isEmpty ? 'Suhbatlar yo\'q'.tr() : 'Natija topilmadi'.tr(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _chatBloc.add(const GetMyChatsEvent());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final chat = filtered[index];
                return _buildChatItem(chat, isDark, index);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<ChatThread> _mergeThreadsByBarber(List<ChatThread> threads) {
    if (threads.isEmpty) return threads;

    final Map<String, ChatThread> latestByBarber = {};
    for (final thread in threads) {
      final key = thread.barberId.isNotEmpty ? thread.barberId : thread.id;
      final existing = latestByBarber[key];

      if (existing == null) {
        latestByBarber[key] = thread;
        continue;
      }

      if (_parseThreadTime(thread.updatedAt)
          .isAfter(_parseThreadTime(existing.updatedAt))) {
        latestByBarber[key] = thread;
      }
    }
    return latestByBarber.values.toList();
  }

  DateTime _parseThreadTime(String raw) {
    if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
    final millis = int.tryParse(raw);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _threadTitle(ChatThread chat) {
    final barber = _barberIndex[chat.barberId];
    if (barber != null && barber.name.isNotEmpty) {
      return barber.name;
    }
    if (chat.barberId.isNotEmpty) {
      return 'Barber #${chat.barberId}';
    }
    return 'Chat ${chat.id}';
  }

  String _avatarText(String title) {
    final parts = title.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    final letters = parts.map((part) => part[0]).take(2).join();
    return letters.toUpperCase();
  }

  Widget _buildAvatar(String barberId, String title) {
    final barber = _barberIndex[barberId];
    final img = barber?.img ?? '';
    final resolvedUrl = img.isEmpty
        ? ''
        : (img.startsWith('http') ? img : '${Constants.imageBaseUrl}$img');
    if (resolvedUrl.isEmpty) {
      return Center(
        child: Text(
          _avatarText(title),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: Image.network(
        resolvedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            _avatarText(title),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    final millis = int.tryParse(raw);
    DateTime? date;
    if (millis != null) {
      date = DateTime.fromMillisecondsSinceEpoch(millis);
    } else {
      date = DateTime.tryParse(raw);
    }
    if (date == null) return raw;
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  Widget _buildChatItem(ChatThread chat, bool isDark, int index) {
    final title = _threadTitle(chat);
    final delay = (index * 0.1).clamp(0.0, 1.0);
    final barber = _barberIndex[chat.barberId];
    final barberImage = barber?.img ?? '';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (_animationController.value - delay).clamp(0.0, 1.0),
        );

        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
        child: Material(
          elevation: isDark ? 0 : 4,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.containerDark : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationPage(
                      barberId: chat.barberId,
                      barberName: title,
                      barberImageUrl: barberImage,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 56.w,
                    height: 56.h,
                    child: _buildAvatar(chat.barberId, title),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatTime(chat.updatedAt),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
