import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminNavProvider = StateProvider<int>((ref) => 0);
final adminSidebarExpandedProvider = StateProvider<bool>((ref) => true);
