// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../theme/app_theme.dart';

//  صفحه حول التطبيق
class AboutDeveloperPage extends StatefulWidget {
  const AboutDeveloperPage({super.key});

  @override
  State<AboutDeveloperPage> createState() => _AboutDeveloperPageState();
}

class _AboutDeveloperPageState extends State<AboutDeveloperPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchURL() async {
    const String url = 'https://mahmoud29hany.blogspot.com/2025/03/blog-post.html';
    try {
      final launched = await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.35,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
                StretchMode.blurBackground,
              ],
              titlePadding: EdgeInsets.only(bottom: size.height * 0.02),
              centerTitle: true,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _scrollOffset > 140 ? 1.0 : 0.0,
                child: Text(
                  'حول التطبيق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.05,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // خلفية متحركة مع تأثير التمويج
                  ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          themeProvider.cardGradientStart,
                          themeProvider.cardGradientEnd.withOpacity(0.9),
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeProvider.cardGradientStart.withOpacity(0.8),
                            themeProvider.cardGradientEnd,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // نمط الخلفية
                  CustomPaint(
                    painter: CirclePatternPainter(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  // محتوى المقدمة
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedLogo(),
                        SizedBox(height: size.height * 0.02),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _scrollOffset < 140 ? 1.0 : 0.0,
                          child: Column(
                            children: [
                              Text(
                                'حول التطبيق',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * 0.08,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'إدارة مالية ذكية',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.04,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.02,
              ),
              child: Column(
                children: [
                  _buildDeveloperCard(themeProvider, size),
                  SizedBox(height: size.height * 0.02),
                  _buildAppInfoCard(themeProvider, size),
                  SizedBox(height: size.height * 0.02),
                  _buildFeaturesCard(themeProvider, size),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              height: 120,
              width: 120,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeveloperCard(ThemeProvider themeProvider, Size size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.05)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(size.width * 0.05),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size.width * 0.05),
            gradient: LinearGradient(
              colors: [
                themeProvider.cardGradientStart.withOpacity(0.3),
                themeProvider.cardGradientEnd.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Hero(
                tag: 'developer_avatar',
                child: Container(
                  width: size.width * 0.25,
                  height: size.width * 0.25,
                  padding: EdgeInsets.all(size.width * 0.01),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.cardGradientStart,
                        themeProvider.cardGradientEnd,
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: size.width * 0.12,
                    child: Icon(
                      Icons.person,
                      size: size.width * 0.12,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Mahmoud Hany',
                style: TextStyle(
                  fontSize: size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size.width * 0.04),
                ),
                child: Text(
                  'App Developer',
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _launchURL,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.cardGradientStart,
                        themeProvider.cardGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'موقع التطبيق',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(ThemeProvider themeProvider, Size size) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          gradient: LinearGradient(
            colors: [
              themeProvider.cardGradientStart.withOpacity(0.3),
              themeProvider.cardGradientEnd.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'تطبيق المصاريف',
              style: TextStyle(
                fontSize: size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.04),
              ),
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              'تطبيق متكامل لإدارة مصاريفك وديونك وحساب صدقاتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.04,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(ThemeProvider themeProvider, Size size) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(size.width * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.05),
          gradient: LinearGradient(
            colors: [
              themeProvider.cardGradientStart.withOpacity(0.3),
              themeProvider.cardGradientEnd.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              'المميزات',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            ..._buildFeatureItems(size),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureItems(Size size) {
    final features = [
      {'icon': Icons.money, 'text': 'إدارة المصروفات'},
      {'icon': Icons.calculate, 'text': 'حاسبة الصدقة'},
      {'icon': Icons.account_balance, 'text': 'إدارة الديون'},
      {'icon': Icons.savings, 'text': 'صناديق الادخار'},
    ];

    return features.map((feature) => Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.02),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.02),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: Colors.green,
              size: size.width * 0.06,
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Text(
            feature['text'] as String,
            style: TextStyle(
              fontSize: size.width * 0.04,
              height: 1.5,
            ),
          ),
        ],
      ),
    )).toList();
  }
}

// إضافة رسام النمط الدائري
class CirclePatternPainter extends CustomPainter {
  final Color color;

  CirclePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double circleSize = size.width * 0.1;
    for (double x = -circleSize; x < size.width + circleSize; x += circleSize) {
      for (double y = -circleSize; y < size.height + circleSize; y += circleSize) {
        canvas.drawCircle(Offset(x, y), circleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
