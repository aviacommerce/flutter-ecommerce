import 'package:get_it/get_it.dart';
import 'package:ofypets_mobile_app/utils/connectivity_state.dart';

GetIt locator = GetIt();

void setupLocator() {
  locator.registerLazySingleton(() => ConnectivityManager());
}
