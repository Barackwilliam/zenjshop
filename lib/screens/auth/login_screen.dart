import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnack(Lang.get('fill_all'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    UserModel? user = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) { return; }
      switch (user.role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case 'shop_owner':
          Navigator.pushReplacementNamed(context, '/shop_owner');
          break;
        case 'delivery':
          Navigator.pushReplacementNamed(context, '/delivery');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/customer');
      }
    } else {
      if (!mounted) { return; }
      _showSnack(Lang.get('login_error'), isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Back Button
                    GestureDetector(
                      onTap:
                          () => Navigator.pushReplacementNamed(
                            context,
                            '/welcome',
                          ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2A3158),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textWhite,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Header
                    ShaderMask(
                      shaderCallback:
                          (bounds) => const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ).createShader(bounds),
                      child: Text(
                        Lang.get('login_title'),
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Lang.get('login_sub'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Email Field
                    _buildLabel(Lang.get('email')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'mfano@gmail.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _buildLabel(Lang.get('password')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Button
                    Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _isLoading ? null : _login,
                          child: Center(
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      Lang.get('login'),
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Signup Link
                    Center(
                      child: GestureDetector(
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/signup',
                            ),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    Lang.isSwahili
                                        ? 'Huna akaunti? '
                                        : 'No account? ',
                              ),
                              TextSpan(
                                text:
                                    Lang.isSwahili
                                        ? 'Jisajili hapa'
                                        : 'Sign up here',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
    );
  }
}
