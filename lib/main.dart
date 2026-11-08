import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'services/account_service.dart';
import 'services/data_source_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await DataSourceService.initialize();
  // Loads in the background; the avatar and side menu update when it lands.
  unawaited(AccountService.initialize());
  runApp(const PigeonApp());
}
