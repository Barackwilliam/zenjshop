import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textWhite : AppColors.textDark, size: 16),
          ),
        ),
        title: Text(Lang.isSwahili ? 'Kuhusu ZenjShop' : 'About ZenjShop',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Column(children: [
              Container(width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 52)),
              const SizedBox(height: 16),
              Text('ZenjShop', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(Lang.isSwahili ? 'Soko Bora la Tanzania' : 'Tanzania\'s Premier Marketplace',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50)),
                child: Text('Version 1.0.0', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Mission
              _buildSection(isDark,
                icon: Icons.flag_rounded, color: AppColors.primary,
                title: Lang.isSwahili ? 'Dhamira Yetu' : 'Our Mission',
                content: Lang.isSwahili
                    ? 'ZenjShop imejengwa kuunganisha wafanyabiashara wa Tanzania na wateja wao kwa njia rahisi, ya haraka na ya kuaminika. Tunaamini kila mtu anastahili upatikanaji rahisi wa bidhaa bora.'
                    : 'ZenjShop is built to connect Tanzanian businesses with their customers in an easy, fast and reliable way. We believe everyone deserves easy access to quality products.'),

              _buildSection(isDark,
                icon: Icons.visibility_rounded, color: AppColors.secondary,
                title: Lang.isSwahili ? 'Maono Yetu' : 'Our Vision',
                content: Lang.isSwahili
                    ? 'Kuwa jukwaa kubwa la biashara la kidijitali katika Afrika Mashariki, linalosaidia wafanyabiashara wadogo kukua na kufanikiwa katika uchumi wa kisasa.'
                    : 'To be the leading digital commerce platform in East Africa, helping small businesses grow and thrive in the modern economy.'),

              // Stats row
              const SizedBox(height: 8),
              Text(Lang.isSwahili ? 'Kwa Nambari' : 'By the Numbers',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
              const SizedBox(height: 14),
              Row(children: [
                _buildStat(isDark, '500+', Lang.isSwahili ? 'Wateja' : 'Customers', AppColors.primary),
                const SizedBox(width: 12),
                _buildStat(isDark, '50+', Lang.isSwahili ? 'Maduka' : 'Shops', AppColors.secondary),
                const SizedBox(width: 12),
                _buildStat(isDark, '24/7', Lang.isSwahili ? 'Msaada' : 'Support', AppColors.success),
              ]),

              const SizedBox(height: 24),

              // Features
              Text(Lang.isSwahili ? 'Vipengele' : 'Features',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
              const SizedBox(height: 14),
              _buildFeature(isDark, Icons.store_rounded, AppColors.primary,
                Lang.isSwahili ? 'Maduka Mengi' : 'Multiple Shops',
                Lang.isSwahili ? 'Nunua kutoka maduka mbalimbali kwa agizo moja' : 'Shop from multiple stores in one order'),
              _buildFeature(isDark, Icons.delivery_dining_rounded, AppColors.secondary,
                Lang.isSwahili ? 'Delivery ya Haraka' : 'Fast Delivery',
                Lang.isSwahili ? 'Delivery haraka hadi mlangoni kwako' : 'Quick delivery right to your door'),
              _buildFeature(isDark, Icons.payment_rounded, AppColors.success,
                Lang.isSwahili ? 'Malipo Rahisi' : 'Easy Payments',
                Lang.isSwahili ? 'Lipa kwa mitandao yote ya simu au benki' : 'Pay via all mobile networks or bank'),
              _buildFeature(isDark, Icons.notifications_rounded, AppColors.warning,
                Lang.isSwahili ? 'Arifa za Wakati Halisi' : 'Real-time Notifications',
                Lang.isSwahili ? 'Fuatilia agizo lako hatua kwa hatua' : 'Track your order step by step'),
              _buildFeature(isDark, Icons.language_rounded, AppColors.info,
                Lang.isSwahili ? 'Lugha Mbili' : 'Bilingual',
                Lang.isSwahili ? 'Inafanya kazi kwa Kiswahili na Kiingereza' : 'Works in Swahili and English'),

              const SizedBox(height: 24),

              // Developer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(children: [
                  Text(Lang.isSwahili ? 'Imetengenezwa na' : 'Developed by',
                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                  const SizedBox(height: 4),
                  Text('DEVELOPMENT PP SOLUTION LTD',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Dar es Salaam, Tanzania',
                    style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                  const SizedBox(height: 12),
                  Text('© 2025 ZenjShop. All rights reserved.',
                    style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                ]),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSection(bool isDark, {required IconData icon, required Color color, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
          const SizedBox(height: 6),
          Text(content, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, height: 1.6)),
        ])),
      ]),
    );
  }

  Widget _buildStat(bool isDark, String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
      ),
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
      ]),
    ));
  }

  Widget _buildFeature(bool isDark, IconData icon, Color color, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCard : AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textWhite : AppColors.textDark)),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
        ])),
        Icon(Icons.check_circle_rounded, color: color, size: 18),
      ]),
    );
  }
}
