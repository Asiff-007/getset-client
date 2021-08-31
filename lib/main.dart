import 'package:flutter/material.dart';
import 'package:retail_client/screens/add_price.dart';
import 'package:retail_client/screens/screen_arguments/add_price_arguments.dart';
import 'package:retail_client/screens/wrapper.dart';
import 'package:retail_client/screens/screen_arguments/campaign_arguments.dart';
import './screens/login_page.dart';
import './screens/home_page.dart';
import 'screens/create_campaign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLogged = prefs.getBool(Constants.isLogged) ?? false;
  final MyApp myApp = MyApp(
    initialRoute: isLogged ? '/home' : '/login',
  );
  runApp(EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: 'assets/translations', // <-- change patch to your
      fallbackLocale: Locale('en', 'US'),
      child: myApp));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: initialRoute,
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/campaign': (context) => CreateCampaign(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/add_price') {
            final args = settings.arguments as AddPrizeArguments;
            return MaterialPageRoute(
              builder: (context) {
                return AddPrice(
                  campaignId: args.campaignId,
                );
              },
            );
          }
          if (settings.name == '/wrapper') {
            final args = settings.arguments as CampaignArguments;
            return MaterialPageRoute(
              builder: (context) {
                return Wrapper(campaignId: args.campaignId, index: args.index);
              },
            );
          }
        },
      );
}
