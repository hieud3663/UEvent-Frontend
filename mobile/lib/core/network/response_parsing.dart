Map<String, dynamic> extractObjectData(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    final dynamic nestedData = responseData['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    final dynamic nestedResult = responseData['result'];
    if (nestedResult is Map<String, dynamic>) {
      return nestedResult;
    }

    return responseData;
  }

  throw const FormatException('Expected a JSON object response');
}

List<Map<String, dynamic>> extractListData(dynamic responseData) {
  dynamic rawList = responseData;

  if (responseData is Map<String, dynamic>) {
    rawList = responseData['results'] ?? responseData['data'] ?? responseData['items'];
  }

  if (rawList is List) {
    return rawList.whereType<Map<String, dynamic>>().toList();
  }

  return const [];
}

T mapObjectData<T>(
  dynamic responseData,
  T Function(Map<String, dynamic>) mapper,
) {
  return mapper(extractObjectData(responseData));
}

List<T> mapListData<T>(
  dynamic responseData,
  T Function(Map<String, dynamic>) mapper,
) {
  return extractListData(responseData).map(mapper).toList();
}

TModel mapDtoToModel<TDto, TModel>(
  Map<String, dynamic> raw, {
  required TDto Function(Map<String, dynamic>) dtoFromMap,
  required TModel Function(TDto) toModel,
}) {
  final dto = dtoFromMap(raw);
  return toModel(dto);
}

TModel mapObjectResponseToModel<TDto, TModel>(
  dynamic responseData, {
  required TDto Function(Map<String, dynamic>) dtoFromMap,
  required TModel Function(TDto) toModel,
}) {
  return mapObjectData(
    responseData,
    (raw) => mapDtoToModel(
      raw,
      dtoFromMap: dtoFromMap,
      toModel: toModel,
    ),
  );
}

List<TModel> mapListResponse<TDto, TModel>(
  dynamic responseData, {
  required TDto Function(Map<String, dynamic>) dtoFromMap,
  required TModel Function(TDto) toModel,
}) {
  return mapListData(
    responseData,
    (raw) => mapDtoToModel(
      raw,
    dtoFromMap: dtoFromMap,
    toModel: toModel,
    ),
  );
}
