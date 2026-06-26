import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('check project image url status', () async {
    final url = 'https://zoumecxqequojyvldtff.supabase.co/storage/v1/object/public/portfolio/projects/1778186917763.JPG';
    print('Fetching URL: $url');
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      print('Status code: ${response.statusCode}');
      print('Headers:');
      response.headers.forEach((name, values) {
        print('  $name: $values');
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      client.close();
    }
  });
}
