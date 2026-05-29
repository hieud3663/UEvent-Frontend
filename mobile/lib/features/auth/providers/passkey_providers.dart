import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/providers/service_providers.dart';
import 'package:frontend/features/auth/models/passkey_credential_model.dart';
import 'package:frontend/features/auth/services/passkey_auth_service.dart';

final passkeyAuthServiceProvider = Provider<PasskeyAuthService>(
  (ref) => PasskeyAuthService(ref.read(apiClientProvider)),
);

final passkeyCredentialsProvider =
    FutureProvider.autoDispose<List<PasskeyCredentialModel>>(
      (ref) => ref.read(passkeyAuthServiceProvider).listCredentials(),
    );
