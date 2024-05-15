import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../infra/push_notifications_service.dart';
import '../../router.gr.dart';
import '../common/build_context_extensions.dart';

@RoutePage()
class RequestPushNotificationPage extends StatelessWidget {
  const RequestPushNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/images/clock_and_calendar.png', height: 200),
              const SizedBox(height: 48),
              Text(
                context.l10n.push_notification_permission_title,
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.push_notification_permission_description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.router.replaceAll([const DiaryRoute()]);
                    },
                    child: Text(context.l10n.push_notification_permission_notNow),
                  ),
                  const SizedBox(width: 24),
                  OutlinedButton(
                    onPressed: () {
                      _askForPermission(context).then((value) => context.router.replaceAll([const DiaryRoute()]));
                    },
                    child: Text(context.l10n.push_notification_permission_sure),
                  )
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _askForPermission(BuildContext context) async {
    await context.read<PushNotificationsService>().askForPermission();
  }
}
