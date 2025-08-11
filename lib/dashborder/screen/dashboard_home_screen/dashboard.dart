import 'package:dashboard/dashborder/screen/dashboard_home_screen/widget_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/parcel_controller/parcel_controller.dart';
import '../../controller/user_controller.dart';
import '../../home_screen.dart';
import '../../modules/theme.dart';

class Dashboard extends StatelessWidget {
  final Widget child;

  const Dashboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ThemeProvider, ParcelController, UserController>(
      builder: (context, themeProvider, shipmentController, userController, _) {
        final theme = Theme.of(context);
        final isDarkMode = themeProvider.isDarkMode;

        return Directionality(
         textDirection: TextDirection.rtl, child: Scaffold(
            endDrawer: (ResponsiveWidget.isSmallScreen(context) ||
                ResponsiveWidget.isMediumScreen(context)) ? child : null,

            appBar: buildAppBarHomeDash(
                context, themeProvider, shipmentController, userController),
            body: buildBody(
                context, theme, shipmentController, userController, isDarkMode),
          ),
        );
      },
    );
  }

}