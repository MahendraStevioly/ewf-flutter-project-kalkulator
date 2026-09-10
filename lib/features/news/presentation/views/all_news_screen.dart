import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/domain/entities/news_item.dart';
import '../../../dashboard/presentation/widgets/news_detail_bottom_sheet.dart';
import '../viewmodels/news_viewmodel.dart'; // <-- Sesuaikan path import ViewModel ini

class AllNewsScreen extends StatefulWidget {
  // Hapus parameter newsList dari konstruktor, karena sekarang kita ambil dari internet!
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Tarik berita secara live saat layar ini pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsViewModel>().fetchLiveNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Berita & Analisa Terkini',
          style: TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      // Gunakan Consumer untuk memantau status Loading, Error, atau Sukses
      body: Consumer<NewsViewModel>(
        builder: (context, viewModel, child) {
          // Tampilkan loading spinner
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Tampilkan pesan error jika gagal koneksi
          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.gray),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage!, style: const TextStyle(color: AppColors.gray)),
                  TextButton(
                    onPressed: () => viewModel.fetchLiveNews(),
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }

          final newsList = viewModel.liveNewsList;

          // UI Orisinal buatan teman Anda jika data kosong
          if (newsList.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada berita saat ini',
                style: TextStyle(color: AppColors.gray),
              ),
            );
          }

          // UI Orisinal buatan teman Anda jika data sukses dimuat
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: newsList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = newsList[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      NewsDetailBottomSheet.show(context, item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 90,
                              height: 80,
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFFE2E8F0),
                                  child: const Icon(Icons.article_rounded, color: AppColors.gray),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      item.timeAgo,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF718096),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.dark,
                                    height: 1.25,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sumber: ${item.source}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFA0AEC0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}