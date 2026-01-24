import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_event.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Set<String> _locallyReadIds = {};

  String _formatModifiedAt(String raw, BuildContext context) {
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw.trim();
    final locale = context.locale.languageCode;
    return DateFormat('dd MMM, HH:mm', locale).format(parsed.toLocal());
  }

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const GetMyNotificationsEvent());
    _loadLocalReadIds();
  }

  Future<void> _loadLocalReadIds() async {
    final ids = await getIt<LocalStorage>().getNotificationsReadIds();
    if (!mounted) return;
    setState(() {
      _locallyReadIds = ids.toSet();
    });
  }

  Future<void> _markAllAsRead(List<NotificationItem> items) async {
    final allIds = items.map((item) => item.id).toSet();
    if (allIds.difference(_locallyReadIds).isEmpty) return;
    setState(() {
      _locallyReadIds = allIds;
    });
    await getIt<LocalStorage>().saveNotificationsReadIds(
          allIds.toList(),
        );
  }

  DateTime _parseNotificationDate(String value) {
    final trimmed = value.trim();
    final millis = int.tryParse(trimmed);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return DateTime.tryParse(trimmed) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime _resolveSortDate(NotificationItem item) {
    final source = item.modifiedAt.isNotEmpty ? item.modifiedAt : item.createdAt;
    return _parseNotificationDate(source);
  }

  Future<void> _refreshNotifications() async {
    context.read<NotificationBloc>().add(const GetMyNotificationsEvent());
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Widget _buildStateBody(NotificationState state, BuildContext context) {
    if (state is NotificationLoading || state is NotificationInitial) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (state is NotificationError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          const SizedBox(height: 200),
          Center(child: Text(state.message)),
        ],
      );
    }
    if (state is NotificationLoaded) {
      if (state.items.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          children: [
            const SizedBox(height: 200),
            Center(child: Text('no_notifications'.tr())),
          ],
        );
      }
      final items = [...state.items];
      items.sort((a, b) => _resolveSortDate(b).compareTo(
            _resolveSortDate(a),
          ));
      final barberNames = state.barberNames;
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final item = items[index];
          final isRead =
              item.isRead || _locallyReadIds.contains(item.id);
          final barberName = item.barberId != null
              ? barberNames[item.barberId]
              : null;
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isRead
                    ? Colors.transparent
                    : AppColors.yellow.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(top: 6.h, right: 10.w),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.grey : AppColors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (barberName != null &&
                          barberName.isNotEmpty) ...[
                        Text(
                          barberName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                      Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _formatModifiedAt(item.modifiedAt, context),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'notifications'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
      ),
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationLoaded) {
            _markAllAsRead(state.items);
          }
        },
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: _buildStateBody(state, context),
            );
          },
        ),
      ),
    );
  }
}
