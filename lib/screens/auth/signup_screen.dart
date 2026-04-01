import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/lang.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'customer';
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnack(Lang.get('fill_all'), isError: true);
      return;
    }

    if (_phoneController.text.length < 10) {
      _showSnack(Lang.get('invalid_phone'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    UserModel? user = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) return;
      switch (user.role) {
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
      if (!mounted) return;
      _showSnack(Lang.get('signup_error'), isError: true);
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
                        Lang.get('signup_title'),
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Lang.get('signup_sub'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Jina
                    _buildLabel(Lang.get('full_name')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            Lang.isSwahili
                                ? 'Jina lako kamili'
                                : 'Your full name',
                        prefixIcon: const Icon(Icons.person_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Email
                    _buildLabel(Lang.get('email')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'mfano@gmail.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Simu
                    _buildLabel(Lang.get('phone')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '0712345678',
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Password
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

                    const SizedBox(height: 18),

                    // Role
                    _buildLabel(Lang.get('role_label')),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2A3158),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedRole,
                          dropdownColor: AppColors.bgCard,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textGrey,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'customer',
                              child: Text(
                                Lang.get('role_customer'),
                                style: GoogleFonts.poppins(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'shop_owner',
                              child: Text(
                                Lang.get('role_shop_owner'),
                                style: GoogleFonts.poppins(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'delivery',
                              child: Text(
                                Lang.get('role_delivery'),
                                style: GoogleFonts.poppins(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Signup Button
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
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _isLoading ? null : _signup,
                          child: Center(
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      Lang.get('signup'),
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

                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
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
                                        ? 'Una akaunti? '
                                        : 'Have account? ',
                              ),
                              TextSpan(
                                text:
                                    Lang.isSwahili
                                        ? 'Ingia hapa'
                                        : 'Login here',
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
                    const SizedBox(height: 30),
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
