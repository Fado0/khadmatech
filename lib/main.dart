// التغيير للوضع الداكن تم انشاء بواسطة شهد


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'auth/forgot_password_page.dart';
import 'auth/uid_provider.dart';
import 'auth/welcome_screen.dart';
import 'companies/screens/company_dashboard_content.dart';
import 'companies/screens/company_reviews_page.dart';
import 'eamana/admin/adminMain.dart';
import 'eamana/admin/eamana_dashboard.dart';
import 'user/screens/other/UserMainPage.dart';
import 'user/screens/other/MyBookingsPage.dart';
import 'companies/screens/company_main_page.dart';
import 'theme/theme_notifier.dart';
import 'companies/screens/add_worker_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UIDProvider()),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ],
        child: const KhidmatikApp(),
      ),
    ),
  );
}

class KhidmatikApp extends StatelessWidget {
  const KhidmatikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'خدمتك',
          debugShowCheckedModeBanner: false,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: GoogleFonts.cairo().fontFamily,
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            useMaterial3: false,
            textTheme: GoogleFonts.cairoTextTheme(
              ThemeData.light().textTheme,
            ).apply(bodyColor: Colors.black, displayColor: Colors.black),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: GoogleFonts.cairo(color: Colors.grey[600]),
              labelStyle: GoogleFonts.cairo(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green,
              titleTextStyle: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: GoogleFonts.cairo().fontFamily,
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: false,
            textTheme: GoogleFonts.cairoTextTheme(
              ThemeData.dark().textTheme,
            ).apply(bodyColor: Colors.white, displayColor: Colors.white),
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
              labelStyle: GoogleFonts.cairo(color: Colors.white),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              titleTextStyle: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
          themeMode: themeNotifier.currentTheme,
          home: const WelcomeScreen(),
          routes: {
            '/login': (_) => const LoginPage(),
            '/register': (_) => const RegisterPage(),
            '/forgot_password': (_) => const ForgotPasswordPage(),
            '/company_dashboard': (_) => const CompanyMainPage(),
            '/company_dashboard_content': (_) =>
                const CompanyDashboardContent(),
            '/company_reviews_page': (_) => const CompanyReviewsPage(),
            '/eamana_dashboard': (_) => const EamanaDashboardPage(),
            '/admin_dashboard': (context) => const AdminDashboardPage(),
            '/add_worker': (_) => const AddWorkerPage(),
            '/myBookings': (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              return MyBookingsPage(userId: args['userId']);
            },
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/home_page') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => UserMainPage(
                  userId: args['userId'],
                  userData: args['userData'],
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
