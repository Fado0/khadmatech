/// ==============================
/// 🛠️ تم إنشاء الصفحة بواسطة الفريق التالي:
///
///  شهد العتيبي:
/// - (شبكة الخدمات )إنشاء الشكل المبدئي للواجهة.
/// - إضافة جميع الخدمات التي يوفرها التطبيق في الصفحة الرئسية  .
/// -الخدمات: (الكهرباء، سباكة ،التنظيف، الدهان، غسيل سيارات، تصليح سيارات، تنسيق حدائق، رعاية كبار السن )
/// - اضافة الوضع الداكن
library;

///
///  زهراء آل طلاق:
/// - إضافة خدمة (جليس اطفال).
/// - تنسيق وترتيب مربعات الخدمات التي يحتاجها العميل.
/// - إضافة الأيقونات الخاصة بكل خدمة.
/// - إضافة شعار تطبيق "خدمتك".
/// - تصميم وتحريك السلايدر المتحرك للصور.
///
///  فاطمة اليامي:
/// - التصميم النهائي لخلفية التطبيق.
/// - تحسين وتنسيق واجهة العميل بالكامل.
/// - إضافة الترجمة للواجهة باستخدام `easy_localization`.
/// - إضافة الصور في السلايدر.
/// ==============================

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/client_background.dart';
import '../services/AllServicesPage.dart';
import '../services/babysitting.dart';
import '../services/cartech.dart';
import '../services/carwash.dart';
import '../services/clean.dart';
import '../services/elderly.dart';
import '../services/electrican.dart';
import '../services/gardener.dart';
import '../services/paint.dart';
import '../services/plumbing.dart';


class HomePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const HomePage({super.key, required this.userId, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<String> imagePaths = [
    'assets/Pictures/ourTime.jpg',
    'assets/Pictures/worker_garden.png',
    'assets/Pictures/tools.jpg',
    'assets/Pictures/price.jpg',
    'assets/Pictures/1.jpg', // ← تم التصحيح هنا
    'assets/Pictures/2.jpg',
  ];

  late final List<Map<String, String>> categories;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    categories = [
      {'name': tr('home.all_services'), 'image': 'assets/Pictures/all.png'},
      {
        'name': tr('home.electricity'),
        'image': 'assets/Pictures/electrician.png',
      },
      {'name': tr('home.plumbing'), 'image': 'assets/Pictures/technician.png'},
      {'name': tr('home.babysitting'), 'image': 'assets/Pictures/mother.png'},
      {'name': tr('home.cleaning'), 'image': 'assets/Pictures/janitor.png'},
      {'name': tr('home.painting'), 'image': 'assets/Pictures/painter.png'},
      {'name': tr('home.carwash'), 'image': 'assets/Pictures/carclean.png'},
      {'name': tr('home.car_repair'), 'image': 'assets/Pictures/cartech.png'},
      {
        'name': tr('home.elderly'),
        'image': 'assets/Pictures/geriatricians.png',
      },
      {'name': tr('home.gardening'), 'image': 'assets/Pictures/gardener.png'},
    ];
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        currentPage = (currentPage + 1) % imagePaths.length;
      });
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: Stack(
        children: [
          const ClientBackground(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 120,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double shrinkOffset = constraints.maxHeight;
                    double logoSize = shrinkOffset > 80 ? 90 : 40;
                    return FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.only(bottom: 12),
                      title: Image.asset(
                        'assets/Pictures/logo.png',
                        height: logoSize,
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (index) {
                          setState(() => currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              imagePaths[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(imagePaths.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.withOpacity(
                              index == currentPage ? 1 : 0.4,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildServiceGrid(),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        tr('home.description'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    final Map<String, Widget> servicePages = {
      tr('home.all_services'): AllServicesPage(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.electricity'): ElectriciansPage(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.plumbing'): Plumbing(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.cleaning'): Clean(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.babysitting'): BabysitterListPage(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.painting'): Painter(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.carwash'): CarWash(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.car_repair'): Cartech(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.elderly'): Elderly(
        userId: widget.userId,
        userData: widget.userData,
      ),
      tr('home.gardening'): Gardener(
        userId: widget.userId,
        userData: widget.userData,
      ),
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return GestureDetector(
          onTap: () {
            final serviceName = cat['name'];
            final destination = servicePages[serviceName!];
            if (destination != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  cat['image']!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name']!,
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
