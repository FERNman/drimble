import 'package:auto_route/auto_route.dart';
import 'package:drimble/data/user_repository.dart';
import 'package:drimble/features/diary/diary_guard.dart';
import 'package:drimble/infra/push_notifications_service.dart';
import 'package:drimble/router.gr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'diary_guard_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<PushNotificationsService>(),
  MockSpec<NavigationResolver>(),
  MockSpec<StackRouter>()
])
void main() {
  group(DiaryGuard, () {
    final userRepositoryMock = MockUserRepository();
    final pushNotificationsServiceMock = MockPushNotificationsService();
    final diaryGuard = DiaryGuard(userRepositoryMock, pushNotificationsServiceMock);

    final resolverMock = MockNavigationResolver();
    final routerMock = MockStackRouter();

    setUp(() {
      reset(userRepositoryMock);
      reset(pushNotificationsServiceMock);

      reset(resolverMock);
      reset(routerMock);
    });

    test('should redirect to sign-in if the user is not signed in', () async {
      when(userRepositoryMock.isSignedIn()).thenReturn(false);

      await diaryGuard.onNavigation(resolverMock, routerMock);

      verify(routerMock.replaceAll([const SignInRoute()]));
    });

    test('should redirect to onboarding if the user hasnt finished onboarding', () async {
      when(userRepositoryMock.isSignedIn()).thenReturn(true);
      when(userRepositoryMock.didFinishOnboarding()).thenAnswer((r) => Future.value(false));

      await diaryGuard.onNavigation(resolverMock, routerMock);

      verify(routerMock.replaceAll([const OnboardingRoute()]));
    });

    test('should redirect to push notification permission if the user hasnt granted it', () async {
      when(userRepositoryMock.isSignedIn()).thenReturn(true);
      when(userRepositoryMock.didFinishOnboarding()).thenAnswer((r) => Future.value(true));
      when(pushNotificationsServiceMock.getPermissionStatus())
          .thenAnswer((r) => Future.value(PushNotificationPermission.unknown));

      await diaryGuard.onNavigation(resolverMock, routerMock);

      verify(routerMock.replaceAll([const RequestPushNotificationRoute()]));
    });

    test('should allow accessing the diary if the user is fully onboarded', () async {
      when(userRepositoryMock.isSignedIn()).thenReturn(true);
      when(userRepositoryMock.didFinishOnboarding()).thenAnswer((r) => Future.value(true));

      await diaryGuard.onNavigation(resolverMock, routerMock);

      verify(resolverMock.next());
    });
  });
}
