library dictionary;

import 'package:flutter/material.dart';

export 'src/models.dart';
export 'src/repository.dart';
export 'src/utils.dart';

///
/// Объект для получения кешированных данных
/// с возможностью запросить данные с сервера
@immutable
class CachedDataLazy<T> {
  const CachedDataLazy({
    required this.cachedData,
    Future<T> Function()? freshDataLazy,
  }) : _freshDataLazy = freshDataLazy;

  final T cachedData;
  final Future<T> Function()? _freshDataLazy;

  Future<T> get freshData => _freshDataLazy?.call() ?? Future.value(cachedData);
}
