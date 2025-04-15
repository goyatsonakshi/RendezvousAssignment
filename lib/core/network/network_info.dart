        import 'package:connectivity_plus/connectivity_plus.dart';

        //Abstact class
        abstract class NetworkInfo {
          Future<bool> get isConnected;
        }

        //implementation
        class NetworkInfoImpl implements NetworkInfo {
          final Connectivity connectivity;

          NetworkInfoImpl(this.connectivity);

          @override
          Future<bool> get isConnected async {
            final connectivityResult = await connectivity.checkConnectivity();
            if (connectivityResult == ConnectivityResult.mobile ||
                connectivityResult == ConnectivityResult.wifi) {
              return true;
            }
            return false;
          }
        }
        