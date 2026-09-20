import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';

void main() {
  test('AiService parses SSE tokens with spaces and newlines intact', () {
    final aiService = AiService(FakeApiService(), FakeDioClient());

    // Test JSON token with leading space
    final tokenWithSpace = aiService.parseSseEventForTesting('token', '{"text": " platform"}');
    expect(tokenWithSpace, isA<AiStreamToken>());
    expect((tokenWithSpace as AiStreamToken).text, ' platform');

    // Test JSON token with multiple newlines
    final tokenWithNewlines = aiService.parseSseEventForTesting('token', '{"text": "\\n\\n## Key Features:\\n\\n"}');
    expect(tokenWithNewlines, isA<AiStreamToken>());
    expect((tokenWithNewlines as AiStreamToken).text, '\n\n## Key Features:\n\n');

    // Test raw text token
    final rawToken = aiService.parseSseEventForTesting('token', ' lightweight');
    expect(rawToken, isA<AiStreamToken>());
    expect((rawToken as AiStreamToken).text, ' lightweight');
  });
}

class FakeApiService extends Fake implements ApiService {}
class FakeDioClient extends Fake implements DioClient {}
