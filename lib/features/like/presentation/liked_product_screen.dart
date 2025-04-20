import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../call/presentation/product_webview_screen.dart';
import '../data/like_repository.dart';
import '../model/liked_product.dart';

class LikedProductScreen extends StatefulWidget {
  const LikedProductScreen({Key? key}) : super(key: key);

  @override
  State<LikedProductScreen> createState() => _LikedProductScreenState();
}

class _LikedProductScreenState extends State<LikedProductScreen> {
  final repo = LikeRepository();
  late Future<List<LikedProduct>> futureLikes;
  final formatter = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();
    futureLikes = repo.fetchLikedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '찜한 상품 목록',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<LikedProduct>>(
        future: futureLikes,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('에러: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                '찜한 상품이 없습니다.',
                style: GoogleFonts.notoSans(color: Colors.white70),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.55,  // 높이를 좀 더 확보
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => _buildCard(list[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(LikedProduct p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductWebViewScreen(url: p.productLink),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ───────── 이미지 + 하트 오버레이 ─────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    p.productImage,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent.shade100,
                    size: 22,
                  ),
                ),
              ],
            ),

            // ───────── 텍스트 영역 ─────────
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                p.productName,
                maxLines: 1,  // 한 줄로 제한
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '₩${formatter.format(p.productPrice.toInt())}',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                p.mallName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
