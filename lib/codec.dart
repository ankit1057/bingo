import 'dart:convert';
import 'dart:io';

import 'models.dart';

final Codec<BoardTemplate, String> gameCodec =
    _GameJsonCodec().fuse(json).fuse(utf8).fuse(gzip).fuse(_UrlSafeBase64());

/// The [base64] codec is great for encoding bytes into strings using all
/// letters, numbers, + and /. However, in URLs, no slashes are allowed. So,
/// instead of using + and / as special characters, the [_UrlSafeBase64] uses
/// - and _.
/// Note: YouTube uses a similar codec for it's video ids.
class _UrlSafeBase64 extends Codec<List<int>, String> {
  @override
  Converter<List<int>, String> get encoder => _UrlSafeBase64Encoder();

  @override
  Converter<String, List<int>> get decoder => _UrlSafeBase64Decoder();
}

class _UrlSafeBase64Encoder extends Converter<List<int>, String> {
  @override
  String convert(List<int> input) =>
      base64.encode(input).replaceAll('+', '-').replaceAll('/', '_');
}

class _UrlSafeBase64Decoder extends Converter<String, List<int>> {
  @override
  List<int> convert(String input) =>
      base64.decode(input.replaceAll('-', '+').replaceAll('_', '/'));
}

/// Converts a [BoardTemplate] to [json].
class _GameJsonCodec extends Codec<BoardTemplate, Object> {
  @override
  Converter<Object, BoardTemplate> get decoder => _JsonToGameConverter();

  @override
  Converter<BoardTemplate, Object> get encoder => _GameToJsonConverter();
}

class _GameToJsonConverter extends Converter<BoardTemplate, Object> {
  @override
  Object convert(BoardTemplate game) {
    return {
      'version': 0,
      'name': game.name,
      'size': game.size,
      'tiles': game.tiles,
    };
  }
}

class _JsonToGameConverter extends Converter<Object, BoardTemplate> {
  @override
  BoardTemplate convert(Object data) {
    final json = data as Map<String, dynamic>;
    if (json['version'] < 0) throw 'invalid version';
    switch (json['version']) {
      case 0:
        return BoardTemplate(
          name: json['name'],
          size: json['size'],
          tiles: (json['tiles'] as List).cast<String>(),
        );
      default:
        throw 'unknown encoding';
    }
  }
}