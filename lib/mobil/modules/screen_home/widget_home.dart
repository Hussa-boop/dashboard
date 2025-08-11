import 'dart:async';

import 'package:dashboard/mobil/modules/screen_home/home_cubit/home_cubit.dart';
import 'package:dashboard/mobil/modules/view_data_shipments/desgin_status_shipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParcelPromoSlider extends StatefulWidget {
  final List<PromoItem> promos;
  final Duration autoSlideDuration;
  final Duration animationDuration;
  final bool showIndicators;
  final bool showCloseButton;

  const ParcelPromoSlider({
    Key? key,
    required this.promos,
    this.autoSlideDuration = const Duration(seconds: 5),
    this.animationDuration = const Duration(milliseconds: 500),
    this.showIndicators = true,
    this.showCloseButton = false,
  }) : super(key: key);

  @override
  State<ParcelPromoSlider> createState() => _ParcelPromoSliderState();
}

class _ParcelPromoSliderState extends State<ParcelPromoSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(widget.autoSlideDuration, (timer) {
      if (_currentPage < widget.promos.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // إعادة تشغيل المؤقت عند التغيير اليدوي
    _autoSlideTimer?.cancel();
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promos.isEmpty) return const SizedBox.shrink();

    return Directionality(
     textDirection: TextDirection.rtl, child: Column(
        children: [
          SizedBox(
            height: 180, // ارتفاع ثابت للسلايدر
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.promos.length,
              itemBuilder: (context, index) {
                final promo = widget.promos[index];
                return _ParcelPromoItem(
                  promo: promo,
                  animationDuration: widget.animationDuration,
                  showCloseButton: widget.showCloseButton,
                );
              },
            ),
          ),
          if (widget.showIndicators && widget.promos.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.promos.length,
                      (index) => Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParcelPromoItem extends StatefulWidget {
  final PromoItem promo;
  final Duration animationDuration;
  final bool showCloseButton;

  const _ParcelPromoItem({
    required this.promo,
    required this.animationDuration,
    required this.showCloseButton,
  });

  @override
  State<_ParcelPromoItem> createState() => __ParcelPromoItemState();
}

class __ParcelPromoItemState extends State<_ParcelPromoItem> {
  bool _isHovered = false;
  bool _isClosed = false;

  @override
  Widget build(BuildContext context) {
    if (_isClosed) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: widget.animationDuration,
        scale: _isHovered ? 1.02 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: _isHovered ? 6 : 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: widget.promo.onTap,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.promo.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: widget.animationDuration,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  shadows: _isHovered
                                      ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                    )
                                  ]
                                      : null,
                                ),
                                child: Text(widget.promo.title),
                              ),
                              const SizedBox(height: 5),
                              AnimatedDefaultTextStyle(
                                duration: widget.animationDuration,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: _isHovered
                                      ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    )
                                  ]
                                      : null,
                                ),
                                child: Text(widget.promo.subtitle),
                              ),
                              const SizedBox(height: 10),
                              AnimatedContainer(
                                duration: widget.animationDuration,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.promo.actionText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedRotation(
                          duration: widget.animationDuration,
                          turns: _isHovered ? -0.05 : 0,
                          child: Icon(
                            widget.promo.icon,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.showCloseButton)
                    Positioned(
                      left:  8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.blue),
                        onPressed: () {
                          setState(() => _isClosed = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("تم إغلاق الإعلان"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PromoItem {
  final String title;
  final String subtitle;
  final String actionText;
  final List<Color> gradientColors;
  final IconData icon;
  final VoidCallback? onTap;

  PromoItem({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.gradientColors,
    required this.icon,
    this.onTap,
  });
}

// boulder widget to the home

Widget buildSearchResults(HomeCubit cubit, BuildContext context) {
  if (cubit.isSearching) {
    return const Center(child: CircularProgressIndicator());
  }

  if (cubit.searchResults.isEmpty) {
    if (cubit.hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('لا توجد نتائج لرقم التتبع هذا',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    return Container();
  }

  final shipment = cubit.searchResults.first;
  final statusInfo = ParcelStatusFormatter.getStatusInfo(shipment.status);

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Tracking Number and Status
          Row(
            children: [
              Text(
                'رقم التتبع:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                shipment.trackingNumber,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: shipment.trackingNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رقم التتبع')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // استبدل هذا الجزء باستدعاء الويدجت الجاهز من الكلاس
              ParcelStatusFormatter.buildStatusWidget(shipment.status),
            ],
          ),
          const SizedBox(height: 12),
          // Description and Sender Info
          Row(
            children: [
              Container(
                width: 6,
                height: 40,
                decoration: BoxDecoration(
                  color: statusInfo.color, // استخدام اللون من الكلاس
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.orderName.isNotEmpty
                          ? shipment.orderName
                          : 'شحنة ${shipment.trackingNumber}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: 'من : ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                            fontSize: 18),
                        children: [
                          TextSpan(
                            text: shipment.senderName,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: 'إلى : ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                            fontSize: 18),
                        children: [
                          TextSpan(
                            text: shipment.receiverName,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Icons Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTimelineIcon(Icons.inventory, statusInfo.color),
              buildDashedLine(statusInfo.color),
              buildTimelineIcon(Icons.local_shipping, statusInfo.color),
              buildDashedLine(statusInfo.color),
              buildTimelineIcon(
                  Icons.inventory_2_outlined, statusInfo.color),
              buildDashedLine(statusInfo.color),
              buildTimelineIcon(Icons.person, statusInfo.color),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildTimelineIcon(IconData icon, Color color) {
  return Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 1.5),
    ),
    child: Icon(icon, size: 18, color: color),
  );
}

Widget buildDashedLine(Color color) {
  return Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
      ),
    ),
  );
}