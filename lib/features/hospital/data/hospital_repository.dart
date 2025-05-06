import 'package:dio/dio.dart';
import '../../auth/common/dio/dio_client.dart';
import '../model/hospital_detail_model.dart';


class HospitalRepository {
  Future<HospitalDetailResponse> getHospitalDetail(int id) async {
    final response = await DioClient.dio.get('/api/hospitals/$id/detail');
    return HospitalDetailResponse.fromJson(response.data);
  }
}
