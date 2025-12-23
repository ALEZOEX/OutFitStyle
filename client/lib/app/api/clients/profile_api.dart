import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio, {String baseUrl}) = _ProfileApi;

  @GET('/me')
  Future<Map<String, dynamic>> getMe();

  @PATCH('/me/preferences')
  Future<Map<String, dynamic>> updatePreferences(@Body() Map<String, dynamic> patch);

  @PATCH('/me/body')
  Future<Map<String, dynamic>> updateBody(@Body() Map<String, dynamic> patch);

  // опционально:
  // @POST('/me/onboarding-complete') Future<void> completeOnboarding();
}