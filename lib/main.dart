import 'package:dantri_clone/router/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';  // nhớ import provider
import 'firebase_options.dart';

import 'viewmodels/category_viewmodel.dart'; // import viewmodel nếu cần



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const DanTriApp());
}

class DanTriApp extends StatelessWidget {
  const DanTriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryViewModel(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Dân trí',
        theme: ThemeData(
          primaryColor: Colors.green,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
          scaffoldBackgroundColor: Colors.white,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
