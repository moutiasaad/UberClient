import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tshl_tawsil/config/app_colors.dart';
import 'package:tshl_tawsil/config/app_icons.dart';
import 'package:tshl_tawsil/config/app_size.dart';
import 'package:tshl_tawsil/config/font_family.dart';
import 'package:tshl_tawsil/api/services/points_service.dart';
import 'package:tshl_tawsil/models/points_model.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  final PointsService _pointsService = PointsService();
  PointsModel? _pointsData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final points = await _pointsService.getPoints();
      setState(() {
        _pointsData = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: AppColors.backGroundColor,
        width: kIsWeb ? AppSize.size800 : null,
        child: Scaffold(
          backgroundColor: AppColors.backGroundColor,
          appBar: _buildAppBar(),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState()
                  : _buildContent(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backGroundColor,
      elevation: AppSize.size0,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: AppSize.size5, top: AppSize.size10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                AppIcons.arrowBack,
                width: AppSize.size20,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: AppSize.size12, right: AppSize.size12),
              child: Text(
                'Points',
                style: TextStyle(
                  fontSize: AppSize.size20,
                  fontFamily: FontFamily.latoBold,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.smallTextColor,
          ),
          const SizedBox(height: AppSize.size16),
          Text(
            'Failed to load points',
            style: TextStyle(
              fontSize: AppSize.size16,
              fontFamily: FontFamily.latoMedium,
              color: AppColors.smallTextColor,
            ),
          ),
          const SizedBox(height: AppSize.size16),
          ElevatedButton(
            onPressed: _loadPoints,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadPoints,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSize.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsCard(),
            const SizedBox(height: AppSize.size24),
            const Text(
              'History',
              style: TextStyle(
                fontSize: AppSize.size18,
                fontFamily: FontFamily.latoBold,
                fontWeight: FontWeight.w700,
                color: AppColors.blackTextColor,
              ),
            ),
            const SizedBox(height: AppSize.size16),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.size24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(AppSize.size16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Points',
            style: TextStyle(
              fontSize: AppSize.size14,
              fontFamily: FontFamily.latoMedium,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSize.size8),
          Text(
            '${_pointsData?.balance ?? 0}',
            style: const TextStyle(
              fontSize: 48,
              fontFamily: FontFamily.latoBold,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSize.size8),
          Text(
            'Worth ${_pointsData?.valueInDinar.toStringAsFixed(2) ?? '0.00'} ${_pointsData?.currency ?? 'SAR'}',
            style: const TextStyle(
              fontSize: AppSize.size16,
              fontFamily: FontFamily.latoMedium,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_pointsData?.history.isEmpty ?? true) {
      return Container(
        padding: const EdgeInsets.all(AppSize.size40),
        child: const Center(
          child: Text(
            'No points history yet',
            style: TextStyle(
              fontSize: AppSize.size14,
              fontFamily: FontFamily.latoMedium,
              color: AppColors.smallTextColor,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pointsData!.history.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSize.size12),
      itemBuilder: (context, index) {
        final item = _pointsData!.history[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(PointHistory item) {
    return Container(
      padding: const EdgeInsets.all(AppSize.size16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSize.size10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: item.isPositive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.size10),
            ),
            child: Icon(
              item.isPositive ? Icons.add : Icons.remove,
              color: item.isPositive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: AppSize.size12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.typeText,
                  style: const TextStyle(
                    fontSize: AppSize.size14,
                    fontFamily: FontFamily.latoSemiBold,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: AppSize.size12,
                    fontFamily: FontFamily.latoRegular,
                    color: AppColors.smallTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.isPositive ? '+' : '-'}${item.points}',
            style: TextStyle(
              fontSize: AppSize.size16,
              fontFamily: FontFamily.latoBold,
              fontWeight: FontWeight.w700,
              color: item.isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
