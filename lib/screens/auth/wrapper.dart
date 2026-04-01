import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import 'welcome_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const WelcomeScreen();
        }

        return FutureBuilder<UserModel?>(
          future: authService.getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (!userSnapshot.hasData || userSnapshot.data == null) {
              return const WelcomeScreen();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              switch (userSnapshot.data!.role) {
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
            });

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          },
        );
      },
    );
  }
}
