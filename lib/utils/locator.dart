import 'package:get_it/get_it.dart';
import 'package:aviastore/utils/connectivity_state.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => ConnectivityManager());
}
