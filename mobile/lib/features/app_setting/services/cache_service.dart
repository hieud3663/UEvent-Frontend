import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

class CacheCleanupResult {
  final int bytesBefore;
  final int bytesAfter;
  final int deletedEntries;
  final int failedEntries;

  const CacheCleanupResult({
    required this.bytesBefore,
    required this.bytesAfter,
    required this.deletedEntries,
    required this.failedEntries,
  });

  int get freedBytes => bytesBefore - bytesAfter;
  bool get hasFailures => failedEntries > 0;
}

class CacheService {
  final Future<Directory> Function()? temporaryDirectoryProvider;

  const CacheService({this.temporaryDirectoryProvider});

  Future<int> estimateCacheSizeBytes() async {
    try {
      final tempDir = await _temporaryDirectory();
      return _directorySize(tempDir);
    } catch (_) {
      return 0;
    }
  }

  Future<CacheCleanupResult> clearTemporaryCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final tempDir = await _temporaryDirectory();
    final bytesBefore = await _directorySize(tempDir);
    if (!await tempDir.exists()) {
      return CacheCleanupResult(
        bytesBefore: bytesBefore,
        bytesAfter: 0,
        deletedEntries: 0,
        failedEntries: 0,
      );
    }

    var deletedEntries = 0;
    var failedEntries = 0;
    await for (final entity in tempDir.list(followLinks: false)) {
      try {
        await entity.delete(recursive: true);
        deletedEntries++;
      } catch (_) {
        failedEntries++;
      }
    }

    return CacheCleanupResult(
      bytesBefore: bytesBefore,
      bytesAfter: await _directorySize(tempDir),
      deletedEntries: deletedEntries,
      failedEntries: failedEntries,
    );
  }

  Future<CacheCleanupResult> trimTemporaryCacheToLimit(int limitBytes) async {
    final tempDir = await _temporaryDirectory();
    final bytesBefore = await _directorySize(tempDir);
    if (bytesBefore <= limitBytes) {
      return CacheCleanupResult(
        bytesBefore: bytesBefore,
        bytesAfter: bytesBefore,
        deletedEntries: 0,
        failedEntries: 0,
      );
    }

    final files = <File>[];
    await for (final entity in tempDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) files.add(entity);
    }

    files.sort((a, b) {
      final aModified = _lastModifiedOrEpoch(a);
      final bModified = _lastModifiedOrEpoch(b);
      return aModified.compareTo(bModified);
    });

    var currentBytes = bytesBefore;
    var deletedEntries = 0;
    var failedEntries = 0;

    for (final file in files) {
      if (currentBytes <= limitBytes) break;

      try {
        final length = await file.length();
        await file.delete();
        currentBytes -= length;
        deletedEntries++;
      } catch (_) {
        failedEntries++;
      }
    }

    return CacheCleanupResult(
      bytesBefore: bytesBefore,
      bytesAfter: await _directorySize(tempDir),
      deletedEntries: deletedEntries,
      failedEntries: failedEntries,
    );
  }

  Future<int> _directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;

    var total = 0;
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<Directory> _temporaryDirectory() {
    final provider = temporaryDirectoryProvider;
    return provider == null ? getTemporaryDirectory() : provider();
  }

  DateTime _lastModifiedOrEpoch(File file) {
    try {
      return file.statSync().modified;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
