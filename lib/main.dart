import 'package:flutter/material.dart';
import 'package:retail_client/screens/add_price.dart';
import 'package:retail_client/screens/args/add_price_args.dart';
import 'package:retail_client/screens/args/campaign_args.dart';
import 'package:retail_client/screens/args/verify-prize_args.dart';
import 'package:retail_client/screens/scan.dart';
import 'package:retail_client/screens/wrapper.dart';
import './screens/start_page.dart';
import './screens/login_page.dart';
import './screens/signup_page.dart';
import './screens/response_page.dart';
import './screens/home_page.dart';
import 'screens/create_campaign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/verify_prize.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isLogged = prefs.getBool(Constants.isLogged) ?? false;
  final MyApp myApp = MyApp(
    initialRoute: isLogged ? '/home' : '/start',
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
          '/start': (context) => StartPage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/response': (context) => ResponsePage(),
          '/home': (context) => HomePage(),
          '/campaign': (context) => CreateCampaign(
                campaignId: 0,
                campaignName: '',
                from: DateTime.now(),
                to: DateTime.now(),
              ),
          '/scan': (context) => Scan(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/add_price') {
            final args = settings.arguments as AddPrizeArguments;
            return MaterialPageRoute(
              builder: (context) {
                return AddPrice(campaignId: args.campaignId, from: args.from);
              },
            );
          }
          if (settings.name == '/wrapper') {
            final args = settings.arguments as CampaignArguments;
            return MaterialPageRoute(
              builder: (context) {
                return Wrapper(
                    campaignId: args.campaignId,
                    campaignName: args.campaignName,
                    from: args.from,
                    to: args.to,
                    status: args.status,
                    totalPlayers: args.totalPlayers,
                    claimedPrizes: args.claimedPrizes,
                    index: args.index);
              },
            );
          }
          if (settings.name == '/verify_prize') {
            final args = settings.arguments as VerifyArgs;
            return MaterialPageRoute(
              builder: (context) {
                return VerifyPrize(
                    campaignId: args.campaignId, ticketId: args.ticketId);
              },
            );
          }
        },
      );
}
