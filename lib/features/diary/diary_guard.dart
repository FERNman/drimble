import 'package:auto_route/auto_route.dart';

import '../../data/user_repository.dart';
import '../../infra/push_notifications_service.dart';
import '../../router.gr.dart';

class DiaryGuard extends AutoRouteGuard {
  final UserRepository _userRepository;
  final PushNotificationsService _pushNotificationsService;

  DiaryGuard(this._userRepository, this._pushNotificationsService);

  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (!_userRepository.isSignedIn()) {
      router.replaceAll([const SignInRoute()]);
    } else if (!(await _userRepository.didFinishOnboarding())) {
      router.replaceAll([const OnboardingRoute()]);
    } else if ((await _pushNotificationsService.getPermissionStatus()) == PushNotificationPermission.unknown) {
      router.replaceAll([const RequestPushNotificationRoute()]);
    } else {
      resolver.next();
    }
  }
}
