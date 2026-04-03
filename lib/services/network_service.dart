import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';

/// Simple connectivity mixin — shows an offline banner when there's no internet.
/// Uses a lightweight approach without external connectivity packages.
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// Call this in initState to start monitoring (optional).
  void initConnectivity() {
    // Default: assume online. In production, integrate connectivity_plus.
    _isOnline = true;
  }

  /// Build an offline warning banner. Returns SizedBox.shrink() when online.
  Widget buildOfflineBanner() {
    if (_isOnline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.error,
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            'Hakuna muunganiko wa intaneti',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
