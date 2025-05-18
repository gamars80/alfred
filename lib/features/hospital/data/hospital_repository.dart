import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/hospital_detail_model.dart';


class HospitalRepository {
  Future<HospitalDetailResponse> getHospitalDetail(int id, int createdAt) async {
    try {
      debugPrint('aaaaaaaaaaa');
      final response = await DioClient.dio.get('/api/hospitals/$id/$createdAt/detail');
      // debugPrint(response.data);
      // debugPrint('📦 API 응답 데이터:${response.data}');
      return HospitalDetailResponse.fromJson(response.data);
    } catch (e, stack) {
      debugPrint('❌ 병원 상세 요청 실패: $e');
      debugPrint('📛 Stack: $stack');
      throw Exception('데이터를 불러오지 못했습니다');
    }
  }
}