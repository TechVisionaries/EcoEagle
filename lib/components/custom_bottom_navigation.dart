import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/reward_management/admin_driver_dashboard.dart';
import 'package:trashtrek/src/reward_management/driver_profile.dart';
import 'package:trashtrek/src/reward_management/view_reviews.dart';

class CustomBottomNavigation {
  static BottomNavigationBar dynamicNav(BuildContext context, int? index, String userType) {
    if (userType == 'Admin') {
      return(
        BottomNavigationBar(
          currentIndex: index ?? 0,
          enableFeedback: true,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (value) {
            if(value == index) return;

            switch (value) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constants.adminDashboardRoute,
                  (route) => false,
                );
                break;

              case 1:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AdminDriverDashboard.routeName,
                  (route) => false,
                );
                break;

              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constants.reportDashboardRoute,
                  (route) => false,
                );
                break;

              default:
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping),
              label: "Drivers",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: "Reports",
            )
          ],
        )
      );
    } else if (userType == 'Driver') {
      return(
        BottomNavigationBar(
          currentIndex: index ?? 0,
          enableFeedback: true,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (value) {
            if(value == index) return;

            switch (value) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constants.driverDashboardRoute,
                  (route) => false,
                );
                break;

              case 1:
                Navigator.restorablePushNamed(
                  context,
                  Constants.wasteMapDriverRoute
                );
                break;

              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  DriverProfile.routeName,
                  (route) => false,
                );
                break;

              default:
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route),
              label: "Route",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reviews),
              label: "Reviews",
            )
          ],
        )
      );
    } else {
      return(
        BottomNavigationBar(
          currentIndex: index ?? 0,
          enableFeedback: true,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (value) {
            if(value == index) return;

            switch (value) {
              case 0:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constants.residentDashboardRoute,
                  (route) => false,
                );
                break;

              case 1:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Constants.myAppointmentsRoute,
                  (route) => false,
                );
                break;

              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MyReviewsScreen.routeName,
                  (route) => false,
                );
                break;

              default:
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_sharp),
              label: "Appointments",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.reviews),
              label: "Reviews",
            )
          ],
        )
      );
    }
  }
}