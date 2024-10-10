import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/DriverMyAppointmentView.dart';

import 'package:trashtrek/src/appointments_feature/my_appointments_view.dart';
import 'package:trashtrek/src/chatBot/chatbot.dart';
import 'package:trashtrek/src/chatBot/waste_assistant.dart';
import 'package:trashtrek/src/reward_management/admin_driver_dashboard.dart';
import 'package:trashtrek/src/reward_management/driver_profile.dart';
import 'package:trashtrek/src/appointments_feature/appointment_service.dart';
import 'package:trashtrek/src/dashboards/admin_dashboard.dart';
import 'package:trashtrek/src/user_management_feature/driverRegistration.dart';
import 'package:trashtrek/src/user_management_feature/editUserProfile.dart';

import 'package:trashtrek/src/dashboards/resident_dashboard.dart';
import 'package:trashtrek/src/user_management_feature/signin.dart';
import 'package:trashtrek/src/user_management_feature/signup.dart';
import 'package:trashtrek/src/user_management_feature/splashScreen.dart';
import 'package:trashtrek/src/user_management_feature/userProfile.dart';
import 'package:trashtrek/src/user_management_feature/userReport.dart';
import 'package:trashtrek/src/waste_map_feature/waste_map_driver_view.dart';

import 'appointments_feature/AppointmentReportPage.dart';
import 'notification_feature/notification_service.dart';
import 'reward_management/admin_driver_profile.dart';
import 'reward_management/view_reviews.dart';
import 'dashboards/report_dashboard.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'dashboards/driver_dashboard.dart';
import 'appointments_feature/schedule_appointment_view.dart';

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
                  case Constants.appointmentsRoute:
                    return ScheduleAppointmentView(apiService: ApiService());
                  case MyAppointmentsView.routeName:
                    return MyAppointmentsView(apiService: ApiService());
                  case MyReviewsScreen.routeName:
                    return const MyReviewsScreen();
                  case AdminDriverDashboard.routeName:
                    return const AdminDriverDashboard(
                      driverId: '',
                    );
                  case DriverProfile.routeName:
                    return const DriverProfile(
                      driverId: '',
                      residentId: '',
                    );
                  case AdminDriverProfile.routeName:
                    return const AdminDriverProfile();
                  case Constants.driverDashboardRoute:
                    return const DriverDashboard();
                  case Constants.residentDashboardRoute:
                    return const ResidentDashboard();
                  case Constants.chatBotRoute:
                    return const Chatbot();
                  case Constants.wasteAssistantRoute:
                    return const WasteAssistant();
                  case Constants.adminDashboardRoute:
                    return const AdminDashboard();
                  case Constants.userReportRoute:
                    return const UserReport();
                  case Constants.appointmentReportRoute:
                    return  AppointmentReportPage(apiService: ApiService());
                  case Constants.spashScreenRoute:
                    return const SplashScreen();
                  case Constants.signInRoute:
                    return const SignIn();
                  case Constants.signUpRoute:
                    return const SignUp();
                  case Constants.driverRegistraionRoute:
                    return const DriverRegistraion();
                  case Constants.userProfileRoute:
                    return const UserProfile();
                  case Constants.edtuserProfileRoute:
                    return const EditUserProfile();
                  case Constants.wasteMapDriverRoute:
                    return const WasteMapDriverView();
                  case Constants.wasteMapResidentRoute:
                    return const WasteMapDriverView();
                  case Constants.reportDashboardRoute:
                    return const ReportView();
                  case Constants.driverAppointmentRoute:
                    return DriverMyAppointmentsView(
                        apiService: ApiService(),
                        notificationService: NotificationService());
                  default:
                    return const SignIn();
                }
              },
            );
          },
        );
      },
    );
  }
}
