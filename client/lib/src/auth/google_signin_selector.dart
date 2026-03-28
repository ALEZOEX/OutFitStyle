// Conditional export для Google Sign-In
export 'google_signin_stub.dart'
    if (dart.library.html) 'google_signin_web.dart';
