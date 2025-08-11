import 'package:dashboard/mobil/customer_drawer.dart';
import 'package:dashboard/mobil/modules/delegate/agent_branch_location.dart';
import 'package:dashboard/mobil/modules/delegate/shipment_screen_delegate.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_login/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
// Import necessary packages and files
// ... (You'll need to create the following files)
// import 'package:dashboard/agent/modules/agent_home/agent_home_cubit.dart';
// import 'package:dashboard/agent/modules/agent_home/agent_home_state.dart';
// import 'package:dashboard/agent/modules/agent_home/screens/agent_branch_location.dart'; // For branch location
// import 'package:dashboard/agent/modules/agent_home/screens/agent_settings.dart'; // For settings
// import 'package:dashboard/agent/modules/agent_home/screens/agent_shipments.dart'; // For shipments
// import 'package:dashboard/agent/widgets/agent_drawer.dart'; // For the drawer
//

// Placeholder for missing files, replace with actual imports
class AgentHomeCubit extends Cubit<AgentHomeState> {
  AgentHomeCubit() : super(AgentHomeInitial());

  static AgentHomeCubit get(context) => BlocProvider.of(context);
  int selectedIndex = 0;

  bool showAgentLocation = false;

  void onItemTapped(int index) {
    selectedIndex = index;
    emit(AgentBottomNavChanged());
  }

  void toggleAgentLocation(bool value) {
    showAgentLocation = value;
    emit(AgentLocationToggleChanged());
  }


}
class AgentHomeState {}
class AgentHomeInitial extends AgentHomeState {}
class AgentBottomNavChanged extends AgentHomeState {}

class AgentLocationToggleChanged extends AgentHomeState {}

class AgentSettings extends StatelessWidget {
  const AgentSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text('Agent Settings')));
  }
}


class AgentDrawer extends StatelessWidget {
  const AgentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: Center(child: Text('Agent Drawer')));
  }
}

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgentHomeCubit(),
      child: BlocConsumer<AgentHomeCubit, AgentHomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = AgentHomeCubit.get(context);

          final List<Widget> screens = [
            const AgentBranchLocation(),
            const SettingsScreen(),
            const AgentShipments(),
          ];

          final List<AppBar> appBars = [
            AppBar(
              title: const Text('موقع الفرع'),
              backgroundColor: Colors.orange,
            ),
            AppBar(
              title: const Text('الاعدادات'),
              backgroundColor: Colors.orange,
            ),
            AppBar(
              title: const Text('بيانات الشحنات'),
              backgroundColor: Colors.orange,
            ),
          ];

          return Scaffold(
            drawer: const CustomDrawer(),
            appBar: appBars[cubit.selectedIndex],
            body: screens[cubit.selectedIndex],
            floatingActionButton: cubit.selectedIndex == 0
                ? _buildLocationToggleFab(context, cubit)
                : null,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.selectedIndex,
              onTap: cubit.onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'موقع الفرع',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'الاعدادات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'بيانات الشحنات',
                ),
              ],
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationToggleFab(BuildContext context, AgentHomeCubit cubit) {
    return FloatingActionButton(
      backgroundColor: Colors.orange,
      child: const Icon(Icons.location_searching, color: Colors.white),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('عرض موقع المندوب'),
                          CupertinoSwitch(
                            value: cubit.showAgentLocation,
                            onChanged: (value) {
                              setState(() {
                                cubit.toggleAgentLocation(value);
                              });
                            },
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cubit.showAgentLocation
                            ? 'سيتم عرض موقعك الحالي على الخريطة'
                            : 'سيتم إخفاء موقعك الحالي من الخريطة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}