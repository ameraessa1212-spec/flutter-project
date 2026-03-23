// ignore: file_names
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/company_details.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/auth/models/specialization.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';
import 'package:Waslaa/features/opportunities/repositories/opportunity_repository.dart';

class CompanyPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CompanyPage({super.key, required this.scaffoldKey});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Opportunity> _opportunities = [];
  List<Specialization> _specializations = const [];
  bool _isLoading = true;
  bool _isLoadingFilters = true;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedSpecializationId;
  bool? _selectedAvailability;
  int _currentPage = 1;
  int _lastPage = 1;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingFilters = true;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final specializations = await authRepo.getSpecializations();
      if (!mounted) return;
      setState(() {
        _specializations = specializations;
        _isLoadingFilters = false;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _isLoadingFilters = false;
      });
    }

    await _loadOpportunities();
  }

  Future<void> _loadOpportunities({bool reset = true}) async {
    if (_isLoadingMore || (!reset && _currentPage >= _lastPage)) {
      return;
    }

    setState(() {
      if (reset) {
        _isLoading = true;
        _error = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final repo = context.read<OpportunityRepository>();
      final nextPage = reset ? 1 : _currentPage + 1;
      final result = await repo.getOpportunitiesPage(
        page: nextPage,
        perPage: 20,
        search: _searchQuery,
        specializationId: _selectedSpecializationId,
        isAvailable: _selectedAvailability,
      );
      if (!mounted) return;
      setState(() {
        _opportunities = reset
            ? result.items
            : [..._opportunities, ...result.items];
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل الفرص';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoading || _isLoadingMore) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      _loadOpportunities(reset: false);
    }
  }

  Future<void> _reloadOpportunities() {
    return _loadOpportunities(reset: true);
  }

  void _onSearchChanged(String value) {
    _searchQuery = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _reloadOpportunities();
    });
  }

  String get _selectedSpecializationLabel {
    if (_selectedSpecializationId == null) {
      return 'كل التخصصات';
    }

    for (final specialization in _specializations) {
      if (specialization.id == _selectedSpecializationId) {
        return specialization.name;
      }
    }

    return 'كل التخصصات';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        surfaceTintColor: const Color(0xFFF8F8FC),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'فرص التدريب',
              style: TextStyle(
                color: primarycolor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'استعرض الفرص المتاحة حسب التخصص',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 18),
            _buildSearchAndFilterRow(),
            const SizedBox(height: 18),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOpportunities,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (_opportunities.isEmpty) {
      return _EmptyState(
        hasFilters: _searchQuery.isNotEmpty || _selectedSpecializationId != null,
      );
    }
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reloadOpportunities,
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
              ),
              itemCount: _opportunities.length,
              itemBuilder: (context, index) {
                return _buildOpportunityCard(context, _opportunities[index]);
              },
            ),
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CircularProgressIndicator(),
          )
        else if (_currentPage < _lastPage)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton(
              onPressed: () => _loadOpportunities(reset: false),
              child: Text(
                'تحميل المزيد',
                style: TextStyle(color: primarycolor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primarycolor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PopupMenuButton<int?>(
            borderRadius: BorderRadius.circular(16),
            icon: Icon(Icons.filter_list_rounded, color: primarycolor, size: 24),
            enabled: !_isLoadingFilters,
            onSelected: (value) {
              setState(() {
                _selectedSpecializationId = value;
              });
              _reloadOpportunities();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int?>(
                value: null,
                child: Text('كل التخصصات', textAlign: TextAlign.right),
              ),
              ..._specializations
                .map(
                  (spec) => PopupMenuItem<int?>(
                    value: spec.id,
                    child: Text(spec.name, textAlign: TextAlign.right),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primarycolor.withValues(alpha: 0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن فرصة أو شركة...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search_rounded, color: primarycolor),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    Text(
                      _selectedSpecializationLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    _AvailabilityChip(
                      label: 'الكل',
                      selected: _selectedAvailability == null,
                      onTap: () {
                        setState(() => _selectedAvailability = null);
                        _reloadOpportunities();
                      },
                    ),
                    _AvailabilityChip(
                      label: 'المتاحة',
                      selected: _selectedAvailability == true,
                      onTap: () {
                        setState(() => _selectedAvailability = true);
                        _reloadOpportunities();
                      },
                    ),
                    _AvailabilityChip(
                      label: 'المغلقة',
                      selected: _selectedAvailability == false,
                      onTap: () {
                        setState(() => _selectedAvailability = false);
                        _reloadOpportunities();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(BuildContext context, Opportunity item) {
    final company = item.company;
    final companyName = company?.name ?? '';
    final imagePath = item.imagePath;
    final location = item.locationText ?? item.city ?? '';
    final duration = item.durationText ?? '';
    final spec = item.specialization?.name ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyDetailsPage(
              opportunity: item,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imagePath != null
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: primarycolor.withValues(alpha: 0.1),
                                child: Icon(Icons.business,
                                    size: 40, color: primarycolor),
                              ),
                            )
                          : Container(
                              color: primarycolor.withValues(alpha: 0.1),
                              child: Icon(Icons.business,
                                  size: 40, color: primarycolor),
                            ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.82),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: item.isAvailable
                              ? Colors.green.withValues(alpha: 0.18)
                              : Colors.red.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.isAvailable ? 'متاح' : 'مغلق',
                          style: TextStyle(
                            color: item.isAvailable
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      left: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  children: [
                    if (spec.isNotEmpty)
                      _infoRow(icon: Icons.school_outlined, text: spec),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _infoRow(
                          icon: Icons.location_on_outlined, text: location),
                    ],
                    if (duration.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _infoRow(
                          icon: Icons.access_time_rounded, text: duration),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primarycolor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.70),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;

  const _EmptyState({this.hasFilters = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 52, color: Colors.grey.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'لا توجد فرص مطابقة' : 'لا توجد فرص متاحة حالياً',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'جرّب تغيير البحث أو اختيار تخصص مختلف'
                : 'تحقق لاحقاً أو جرّب تحديث الصفحة لرؤية الفرص الجديدة',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AvailabilityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? primarycolor.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? primarycolor.withValues(alpha: 0.35)
                : primarycolor.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: selected ? primarycolor : Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
