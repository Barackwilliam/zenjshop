import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqsEn = [
    {'q': 'How do I place an order?', 'a': 'Browse products, add them to cart, then go to Cart → Checkout. Enter your delivery address and tap "Place Order".'},
    {'q': 'How do I pay?', 'a': 'After placing an order, send payment to number 22567522 (DEVELOPMENT PP SOLUTION LTD). We accept all mobile networks (M-Pesa, Tigo, Airtel) and bank transfers.'},
    {'q': 'How long does delivery take?', 'a': 'Delivery typically takes 1–3 hours within Dar es Salaam. Other regions may take 1–2 days.'},
    {'q': 'How do I track my order?', 'a': 'Go to Profile → My Orders to see your order status in real time.'},
    {'q': 'Can I cancel my order?', 'a': 'You can request cancellation before the order is confirmed. Contact us immediately via WhatsApp.'},
    {'q': 'How do I return a product?', 'a': 'We accept returns within 7 days of delivery. Contact us via WhatsApp with your order number and reason.'},
    {'q': 'How do I open a shop?', 'a': 'Sign up as Shop Owner, then submit your shop for admin approval. Once approved, you can start adding products.'},
    {'q': 'How do I upload product images?', 'a': 'In Shop Owner → My Shops → Add Product, tap the camera icon to upload from your gallery.'},
  ];

  final List<Map<String, String>> _faqsSw = [
    {'q': 'Ninawezaje kufanya agizo?', 'a': 'Angalia bidhaa, ziongeze kwenye cart, kisha nenda Cart → Checkout. Weka anwani yako na bonyeza "Tuma Agizo".'},
    {'q': 'Ninawezaje kulipa?', 'a': 'Baada ya kufanya agizo, tuma malipo kwenye namba 22567522 (DEVELOPMENT PP SOLUTION LTD). Tunakubali mitandao yote ya simu na benki.'},
    {'q': 'Delivery inachukua muda gani?', 'a': 'Delivery inachukua saa 1–3 ndani ya Dar es Salaam. Mikoa mingine inaweza kuchukua siku 1–2.'},
    {'q': 'Ninawezaje kufuatilia agizo langu?', 'a': 'Nenda Wasifu → Maagizo Yangu kuona hali ya agizo lako kwa wakati halisi.'},
    {'q': 'Ninaweza kughairi agizo?', 'a': 'Unaweza kuomba kughairi kabla ya agizo kuthibitishwa. Wasiliana nasi mara moja kupitia WhatsApp.'},
    {'q': 'Ninawezaje kurudisha bidhaa?', 'a': 'Tunakubali marejesho ndani ya siku 7 baada ya delivery. Wasiliana nasi kupitia WhatsApp na nambari yako ya agizo.'},
    {'q': 'Ninawezaje kufungua duka?', 'a': 'Jisajili kama Mwenye Duka, kisha wasilisha duka lako kwa idhini ya admin. Baada ya kuidhinishwa, unaweza kuanza kuongeza bidhaa.'},
    {'q': 'Ninawezaje kupakia picha za bidhaa?', 'a': 'Katika Mwenye Duka → Maduka Yangu → Ongeza Bidhaa, bonyeza ikoni ya kamera kupakia kutoka kwenye gallery yako.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final faqs = Lang.isSwahili ? _faqsSw : _faqsEn;

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
        title: Text(Lang.isSwahili ? 'Msaada & Mawasiliano' : 'Help & Support',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Contact cards
          _buildContactCard(isDark),
          const SizedBox(height: 24),

          Text(Lang.isSwahili ? 'Maswali Yanayoulizwa Mara Kwa Mara' : 'Frequently Asked Questions',
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
          const SizedBox(height: 14),

          ...faqs.asMap().entries.map((e) => _buildFaqTile(e.key, e.value, isDark)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildContactCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(Lang.isSwahili ? 'Wasiliana Nasi' : 'Contact Us',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(Lang.isSwahili ? 'Tuko hapa kukusaidia 24/7' : 'We\'re here to help you 24/7',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 20),
        _buildContactItem(Icons.phone_rounded, 'WhatsApp', '+255 XXX XXX XXX', isDark: false, onTap: null),
        const SizedBox(height: 12),
        _buildContactItem(Icons.email_rounded, 'Email', 'support@zenjshop.co.tz', isDark: false, onTap: null),
        const SizedBox(height: 12),
        _buildContactItem(Icons.location_on_rounded, Lang.isSwahili ? 'Ofisi' : 'Office', 'Dar es Salaam, Tanzania', isDark: false, onTap: null),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Clipboard.setData(const ClipboardData(text: '+255 XXX XXX XXX'));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(Lang.isSwahili ? 'Namba imenakiliwa!' : 'Number copied!',
                style: GoogleFonts.poppins(fontSize: 13)),
              backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(Lang.isSwahili ? 'Piga Simu WhatsApp' : 'Chat on WhatsApp',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, {required bool isDark, VoidCallback? onTap}) {
    return Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 18)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
    ]);
  }

  Widget _buildFaqTile(int index, Map<String, String> faq, bool isDark) {
    final isExpanded = _expandedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? AppColors.primary.withValues(alpha: 0.08) : isDark ? AppColors.bgCard : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isExpanded ? AppColors.primary.withValues(alpha: 0.3) : isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(faq['q']!,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textWhite : AppColors.textDark))),
            Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: isExpanded ? AppColors.primary : isDark ? AppColors.textGrey : AppColors.textDarkGrey),
          ]),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Text(faq['a']!,
              style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, height: 1.6)),
          ],
        ]),
      ),
    );
  }
}
