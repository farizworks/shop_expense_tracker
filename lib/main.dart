import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/theme_provider.dart';
import 'features/business/presentation/providers/business_provider.dart';
import 'features/daily_entry/presentation/providers/daily_entry_provider.dart';
import 'features/employee/presentation/providers/employee_provider.dart';
import 'app.dart';

// void main(){
//   runApp(MyHome());
// }
//
// class MyHome extends StatelessWidget {
//   const MyHome({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: Text('Hlala'),);
//   }
// }




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<BusinessProvider>(
          create: (_) => di.sl<BusinessProvider>(),
        ),
        ChangeNotifierProvider<DailyEntryProvider>(
          create: (_) => di.sl<DailyEntryProvider>(),
        ),
        ChangeNotifierProvider<EmployeeProvider>(
          create: (_) => di.sl<EmployeeProvider>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
