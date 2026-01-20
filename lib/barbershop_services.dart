import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_bloc.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_event.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_state.dart';
import 'package:bar_bros_user/pages/berbers_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarbershopServices extends StatelessWidget {
  final String? categoryId;
  final String? categoryName;
  final String? categoryType;

  const BarbershopServices({
    Key? key,
    this.categoryId,
    this.categoryName,
    this.categoryType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ServiceBloc>()..add(const GetAllServicesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('services_title'.tr()),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<ServiceBloc, ServiceState>(
                        builder: (context, state) {
                          final title = categoryName == null
                              ? ''
                              : '$categoryName';
                          return Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                    ),
                    // TextButton.icon(
                    //   onPressed: () {},
                    //   icon: const Icon(Icons.tune, size: 18),
                    //   label: const Text('Filter'),
                    //   style: TextButton.styleFrom(
                    //     foregroundColor: AppColors.yellow,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ServiceBloc, ServiceState>(
                    builder: (context, state) {
                      if (state is ServiceLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.yellow,
                          ),
                        );
                      }
                      if (state is ServiceError) {
                        return Center(
                          child: Text(state.message),
                        );
                      }
                      final services = _resolveServices(state);
                      if (services.isEmpty) {
                        return Center(
                          child: Text(
                            "Servislar yo'q hozirgi paytda",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        );
                      }
                      final children = <Widget>[];
                      for (var i = 0; i < services.length; i++) {
                        final service = services[i];
                        final imageUrl = _resolveServiceImageUrl(service);
                        final isAsset = !imageUrl.startsWith('http');
                        children.add(
                          ServiceCard(
                            imagePath: imageUrl,
                            isAssetImage: isAsset,
                            title: service.name,
                            description: service.description,
                            onTap: () => _openBarbers(context, service.id),
                          ),
                        );
                      }
                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                        children: children,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBarbers(BuildContext context, String serviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarbersPage(serviceId: serviceId),
      ),
    );
  }

  List<Service> _resolveServices(ServiceState state) {
    if (state is ServiceLoaded) {
      final services = state.services.where((s) => !s.isDeleted).toList();
      if (categoryId == null || categoryId!.isEmpty) {
        if (categoryType == null || categoryType!.isEmpty) {
          return services;
        }
        return services
            .where((s) => s.category.categoryType == categoryType)
            .toList();
      }
      return services.where((s) => s.category.id == categoryId).toList();
    }
    return const [];
  }

  String _resolveServiceImageUrl(Service service) {
    final img = service.serviceImages.isNotEmpty
        ? service.serviceImages.first
        : service.image;
    if (img.isEmpty) {
      return '';
    }
    return img.startsWith('http') ? img : '${Constants.imageBaseUrl}$img';
  }
}

class ServiceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isAssetImage;

  const ServiceCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.description,
    this.onTap,
    this.isAssetImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath.isNotEmpty;
    final isSvg = imagePath.toLowerCase().endsWith('.svg');
    return Card(
      elevation: 1,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: !hasImage
                    ? _buildImagePlaceholder()
                    : isAssetImage
                        ? isSvg
                            ? SvgPicture.asset(
                                imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                        : isSvg
                            ? SvgPicture.network(
                                imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholderBuilder: (_) =>
                                    _buildImagePlaceholder(),
                              )
                            : Image.network(
                                imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return _buildImagePlaceholder();
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(),
                              ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.content_cut,
          color: Colors.grey.withValues(alpha: 0.5),
          size: 28,
        ),
      ),
    );
  }
}
