// ignore: file_names
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/company_details.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';
import 'package:Waslaa/features/opportunities/repositories/opportunity_repository.dart';

class CompanyPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CompanyPage({super.key, required this.scaffoldKey});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  List<Opportunity> _opportunities = [];
  List<Opportunity> _filtered = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedSpec = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<OpportunityRepository>();
      final list = await repo.getOpportunities(perPage: 50);
      if (!mounted) return;
      setState(() {
        _opportunities = list;
        _filtered = list;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'حدث خطأ أثناء تحميل الفرص';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _opportunities.where((item) {
        final title = item.title.toLowerCase();
        final company = (item.company?.name ?? '').toLowerCase();
        final spec = item.specialization?.name ?? '';

        final matchesSearch = _searchQuery.isEmpty ||
            title.contains(_searchQuery.toLowerCase()) ||
            company.contains(_searchQuery.toLowerCase());

        final matchesSpec =
            _selectedSpec == 'الكل' || spec == _selectedSpec;

        return matchesSearch && matchesSpec;
      }).toList();
    });
  }

  List<String> get _specializationFilters {
    final specs = _opportunities
        .map((e) => e.specialization?.name ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    specs.sort();
    return ['الكل', ...specs];
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
                color: Colors.black.withOpacity(0.45),
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
    if (_filtered.isEmpty) {
      return const _EmptyState();
    }
    return RefreshIndicator(
      onRefresh: _loadOpportunities,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.74,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
        ),
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          return _buildOpportunityCard(context, _filtered[index]);
        },
      ),
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
            border: Border.all(color: primarycolor.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            borderRadius: BorderRadius.circular(16),
            icon: Icon(Icons.filter_list_rounded, color: primarycolor, size: 24),
            onSelected: (value) {
              _selectedSpec = value;
              _applyFilters();
            },
            itemBuilder: (context) => _specializationFilters
                .map(
                  (spec) => PopupMenuItem<String>(
                    value: spec,
                    child: Text(spec, textAlign: TextAlign.right),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primarycolor.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              textAlign: TextAlign.right,
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
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
              color: Colors.black.withOpacity(0.05),
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
                                color: primarycolor.withOpacity(0.1),
                                child: Icon(Icons.business,
                                    size: 40, color: primarycolor),
                              ),
                            )
                          : Container(
                              color: primarycolor.withOpacity(0.1),
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
                              Colors.black.withOpacity(0.82),
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
                              ? Colors.green.withOpacity(0.18)
                              : Colors.red.withOpacity(0.18),
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
              color: Colors.black.withOpacity(0.70),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 52, color: Colors.grey.withOpacity(0.7)),
          const SizedBox(height: 12),
          const Text(
            'لا توجد فرص مطابقة',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرّب تغيير البحث أو اختيار تخصص مختلف',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
