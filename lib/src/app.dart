import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/screens/my_appointments_view.dart';
import 'package:trashtrek/src/user_management_feature/residentDashboard.dart';
import 'package:trashtrek/src/user_management_feature/signin.dart';
import 'package:trashtrek/src/user_management_feature/signup.dart';
import 'package:trashtrek/src/user_management_feature/userProfile.dart';
import 'package:trashtrek/src/waste_map_feature/waste_map_driver_view.dart';

import 'reward_management/screens/add_rating_view.dart';
import 'reward_management/screens/admin_driver_profile.dart';
import 'reward_management/screens/view_reviews.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'user_management_feature/driverDashboard.dart';
import 'appointments_feature/screens/schedule_appointment_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case SampleItemDetailsView.routeName:
                    return const SampleItemDetailsView();
                  case Constants.appointmentsRoute:
                    return const ScheduleAppointmentView();
                  case MyAppointmentsView.routeName:
                    return MyAppointmentsView();
                  case RateDriverScreen.routeName:
                    return const RateDriverScreen();
                  case MyReviewsScreen.routeName:
                    return const MyReviewsScreen();
                  case AdminDriverProfile.routeName:
                    return const AdminDriverProfile();
                  case Constants.driverDashboardRoute:
                    return const DriverDashboard();
                  case Constants.residentDashboardRoute:
                    return const ResidentDashboard();
                  case Constants.signInRoute:
                    return const SignIn();
                  case Constants.signUpRoute:
                    return const SignUp();
                  case Constants.userProfileRoute:
                    return const UserProfile();
                  case Constants.wasteMapDriverRoute:
                    return const WasteMapDriverView();
                  case Constants.wasteMapResidentRoute:
                    return const WasteMapDriverView();
                  case Constants.homeRoute:
                    return const SampleItemListView();
                  default:
                    return const SampleItemListView();
                }
              },
            );
          },
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     // home: ScheduleAppointmentView(),
  //     // home: RateDriverScreen(),
  //     // home : MyReviewsScreen(),
  //     // home : AdminDriverProfile(),
  //     // home: DriverDashboard(),
  //     home: DriverProfile(),
  //   );
  // }
}
