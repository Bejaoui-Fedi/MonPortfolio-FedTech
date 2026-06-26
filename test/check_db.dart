import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fedtech/utils/supabase_config.dart';

void main() {
  test('print skills table columns and data', () async {
    final client = SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
    final skills = await client.from('skills').select();
    print('--- SKILLS ---');
    for (var s in skills) {
      print('Skill: $s');
    }
    print('----------------');
  });
}
