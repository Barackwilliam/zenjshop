import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});
  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _addressController = TextEditingController();
  bool _isSaving = false;
  String _currentAddress = '';

  final List<String> _quickAddresses = [
    'Kariakoo, Dar es Salaam',
    'Kinondoni, Dar es Salaam',
    'Ilala, Dar es Salaam',
    'Temeke, Dar es Salaam',
    'Mbagala, Dar es Salaam',
    'Mwenge, Dar es Salaam',
    'Mikocheni, Dar es Salaam',
    'Sinza, Dar es Salaam',
  ];

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  void _loadAddress() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      final userData = await _firestoreService.getUserData(uid);
      if (userData != null && mounted) {
        setState(() {
          _currentAddress = (userData as dynamic).address ?? '';
          _addressController.text = _currentAddress;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_addressController.text.trim().isEmpty) { return; }
    setState(() => _isSaving = true);
    final uid = _authService.currentUser?.uid ?? '';
    await _firestoreService.updateUserProfile(uid, address: _addressController.text.trim());
    setState(() { _isSaving = false; _currentAddress = _addressController.text.trim(); });
    if (!mounted) { return; }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(Lang.isSwahili ? 'Anwani imehifadhiwa!' : 'Address saved!',
        style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

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
        title: Text(Lang.isSwahili ? 'Anwani ya Delivery' : 'Delivery Address',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Current address display
          if (_currentAddress.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(Lang.isSwahili ? 'Anwani Iliyohifadhiwa:' : 'Saved Address:',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                  Text(_currentAddress, style: GoogleFonts.poppins(fontSize: 13, color: isDark ? AppColors.textWhite : AppColors.textDark)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          Text(Lang.isSwahili ? 'Weka Anwani Mpya' : 'Enter New Address',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
          const SizedBox(height: 12),

          TextField(
            controller: _addressController,
            maxLines: 3,
            style: GoogleFonts.poppins(color: isDark ? AppColors.textWhite : AppColors.textDark, fontSize: 14),
            decoration: InputDecoration(
              hintText: Lang.isSwahili ? 'Mfano: Kariakoo, Dar es Salaam' : 'E.g: Kariakoo, Dar es Salaam',
              hintStyle: GoogleFonts.poppins(color: isDark ? AppColors.textGrey : AppColors.textDarkGrey, fontSize: 13),
              prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on_rounded, color: AppColors.primary)),
              filled: true,
              fillColor: isDark ? AppColors.bgSurface : AppColors.bgSurfaceLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const SizedBox(height: 16),

          // Save button
          GestureDetector(
            onTap: _isSaving ? null : _saveAddress,
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]),
              child: Center(child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(Lang.isSwahili ? 'Hifadhi Anwani' : 'Save Address',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ])),
            ),
          ),

          const SizedBox(height: 28),
          Text(Lang.isSwahili ? 'Anwani za Haraka' : 'Quick Addresses',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textWhite : AppColors.textDark)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8, runSpacing: 8,
            children: _quickAddresses.map((addr) => GestureDetector(
              onTap: () => setState(() => _addressController.text = addr),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _addressController.text == addr
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : isDark ? AppColors.bgCard : AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _addressController.text == addr
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : isDark ? const Color(0xFF2A3158) : const Color(0xFFDDE0FF),
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on_outlined,
                    color: _addressController.text == addr ? AppColors.primary : isDark ? AppColors.textGrey : AppColors.textDarkGrey,
                    size: 14),
                  const SizedBox(width: 6),
                  Text(addr,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500,
                      color: _addressController.text == addr ? AppColors.primary : isDark ? AppColors.textGrey : AppColors.textDarkGrey)),
                ]),
              ),
            )).toList(),
          ),
        ]),
      ),
    );
  }
}
