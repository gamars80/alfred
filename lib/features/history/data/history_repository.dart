import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/history_response.dart';
import '../model/beauty_history.dart';

class HistoryRepository {
  final Dio _dio = DioClient.dio;

  Future<HistoryResponse> fetchHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    final queryParams = {
      if (nextPageKey != null)
        'nextPageKey': nextPageKey,
    };
    final response = await _dio.get(
      '/api/recomendation-history',
      queryParameters: queryParams,
    );
    return HistoryResponse.fromJson(response.data);
  }



  Future<BeautyHistoryResponse> fetchBeautyHistories({
    int limit = 10,
    String? nextPageKey,
  }) async {
    // nextPageKey가 있으면 있는 그대로 넣고, 없으면 생략
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (nextPageKey != null)
        'nextPageKey': nextPageKey, // Uri.encodeComponent 제거
    };
    debugPrint("nextPageKey::::::::::::::$nextPageKey");
    debugPrint("queryParams::::$queryParams");

    final response = await _dio.get(
      '/api/recomendation-history/beauty-history',
      queryParameters: queryParams, // Dio가 자동으로 한 번만 인코딩해 줌
    );
    return BeautyHistoryResponse.fromJson(response.data);
  }
}
