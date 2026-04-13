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
