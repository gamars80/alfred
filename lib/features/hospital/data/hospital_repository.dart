import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/hospital_detail_model.dart';


class HospitalRepository {
  Future<HospitalDetailResponse> getHospitalDetail(int id) async {
    try {
      final response = await DioClient.dio.get('/api/hospitals/$id/detail');
      // debugPrint(response.data);
      return HospitalDetailResponse.fromJson(response.data);
    } catch (e, stack) {
      debugPrint('❌ 병원 상세 요청 실패: $e');
      debugPrint('📛 Stack: $stack');
      throw Exception('데이터를 불러오지 못했습니다');
    }
  }
}