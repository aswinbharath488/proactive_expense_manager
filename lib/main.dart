import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/notification_service.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'data/api/api_client.dart';
import 'data/local/app_database.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/expense/expense_bloc.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final prefs = await PreferencesService.create();
  final db = await AppDatabase.open();
  final api = ApiClient();
  final authRepo = AuthRepository(api, prefs);
  final expenseRepo = ExpenseRepository(db, api, prefs);
  authRepo.applyTokenFromPrefs();

  runApp(
    ProactiveExpenseApp(
      prefs: prefs,
      authRepo: authRepo,
      expenseRepo: expenseRepo,
    ),
  );
}

class ProactiveExpenseApp extends StatelessWidget {
  const ProactiveExpenseApp({
    super.key,
    required this.prefs,
    required this.authRepo,
    required this.expenseRepo,
  });

  final PreferencesService prefs;
  final AuthRepository authRepo;
  final ExpenseRepository expenseRepo;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PreferencesService>.value(value: prefs),
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<ExpenseRepository>.value(value: expenseRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepo)),
          BlocProvider(create: (_) => ExpenseBloc(expenseRepo)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Proactive Expense Manager',
          theme: AppTheme.dark(),
          home: SplashScreen(prefs: prefs),
        ),
      ),
    );
  }
}
