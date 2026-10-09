import 'package:flutter_test/flutter_test.dart';
import 'package:rent_lanka_mobile/navigation/profile_navigation.dart';
import 'package:rent_lanka_mobile/features/provider/screens/provider_profile_screen.dart';
import 'package:rent_lanka_mobile/features/exchange_messaging_profile/screens/profile_screen.dart';
import 'package:rent_lanka_mobile/features/user_discovery/screens/role/role_selection_screen.dart';

void main() {
  test('saved player role opens the existing player profile', () {
    expect(profileScreenForRole('player'), isA<ProfileScreen>());
  });
  test('saved provider role opens the existing provider profile', () {
    expect(profileScreenForRole('provider'), isA<ProviderProfileScreen>());
  });
  test('role normalization matches login', () {
    expect(profileScreenForRole(' Provider '), isA<ProviderProfileScreen>());
  });
  test('missing document or role goes to role selection', () {
    expect(profileScreenForRole(null), isA<RoleSelectionScreen>());
    expect(profileScreenForRole(''), isA<RoleSelectionScreen>());
  });
  test('unknown role never defaults to the player profile', () {
    expect(() => profileScreenForRole('unknown'), throwsStateError);
  });
}
