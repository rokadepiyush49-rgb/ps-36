import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:janmaang/shared/widgets/jm_logo.dart';
import 'package:janmaang/shared/widgets/jm_photo_gallery.dart';

/// Guards a failure mode that compiles, analyses and tests clean, and only
/// shows up as a silent 404 at runtime: an asset referenced in Dart but never
/// declared in `pubspec.yaml`.
///
/// Both asset slots ship with fallbacks, so a missing declaration would not
/// crash — the images would simply never appear, even after being dropped in.
void main() {
  late List<String> declaredAssetEntries;

  setUpAll(() {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final assetsIndex = pubspec.indexWhere((l) => l.trim() == 'assets:');
    expect(assetsIndex, isNot(-1), reason: 'pubspec declares an assets block');

    declaredAssetEntries = <String>[];
    for (final line in pubspec.skip(assetsIndex + 1)) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('- ')) break;
      declaredAssetEntries.add(trimmed.substring(2).trim());
    }
  });

  bool isDeclared(String assetPath) => declaredAssetEntries.any(
        (entry) => entry.endsWith('/')
            ? assetPath.startsWith(entry)
            : assetPath == entry,
      );

  test('every referenced asset is declared in pubspec', () {
    final referenced = <String>[
      JmLogo.markAsset,
      JmLogo.fullAsset,
      for (final slide in JanMaangGallery.slides) slide.asset,
    ];

    for (final asset in referenced) {
      expect(isDeclared(asset), isTrue,
          reason: '$asset is used in code but not declared in pubspec.yaml — '
              'it would silently 404 at runtime');
    }
  });

  test('every declared asset directory exists on disk', () {
    for (final entry in declaredAssetEntries) {
      if (!entry.endsWith('/')) continue;
      expect(Directory(entry).existsSync(), isTrue,
          reason: '$entry is declared but missing; the build would fail');
    }
  });

  test('the gallery carries the four infrastructure slides, in order', () {
    expect(JanMaangGallery.slides.length, 4);
    expect(
      JanMaangGallery.slides.map((s) => s.asset).toList(),
      <String>[
        'assets/gallery/roads.jpg',
        'assets/gallery/transit.jpg',
        'assets/gallery/civic.jpg',
        'assets/gallery/water.jpg',
      ],
    );
    // Each slide must caption itself, since the photographs are decorative and
    // the caption is what carries meaning to a screen reader.
    for (final slide in JanMaangGallery.slides) {
      expect(slide.title, isNotEmpty);
      expect(slide.caption, isNotEmpty);
    }
  });
}
