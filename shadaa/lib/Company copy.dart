import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5C5CE6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: null, // Set your Arabic font here if you want (e.g. "Cairo")
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: CompaniesScreen(),
      ),
    );
  }
}

/// --------------------
/// Models + Mock Data
/// --------------------
class Company {
  final String id;
  final String name;
  final String status; // متاح
  final String actionLabel; // عرض المورد
  final String? logoUrl;

  const Company({
    required this.id,
    required this.name,
    required this.status,
    required this.actionLabel,
    this.logoUrl,
  });
}

const _mockCompanies = <Company>[
  Company(
    id: "1",
    name: "هاتفنا ليبيا",
    status: "متاح",
    actionLabel: "عرض المورد",
    logoUrl:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Logo_TV_2015.png/240px-Logo_TV_2015.png",
  ),
  Company(
    id: "2",
    name: "الموارد الجديد",
    status: "متاح",
    actionLabel: "عرض المورد",
    logoUrl:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Logo-green.svg/240px-Logo-green.svg.png",
  ),
  Company(
    id: "3",
    name: "الباحة القابضة",
    status: "متاح",
    actionLabel: "عرض المورد",
    logoUrl:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Font_Awesome_5_solid_globe.svg/200px-Font_Awesome_5_solid_globe.svg.png",
  ),
  Company(
    id: "4",
    name: "ليبيا",
    status: "متاح",
    actionLabel: "عرض المورد",
    logoUrl:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Purple_circle_100%25.svg/240px-Purple_circle_100%25.svg.png",
  ),
  // Two empty placeholders like your screenshot bottom row
  Company(
    id: "5",
    name: "",
    status: "",
    actionLabel: "",
    logoUrl: null,
  ),
  Company(
    id: "6",
    name: "",
    status: "",
    actionLabel: "",
    logoUrl: null,
  ),
];

/// --------------------
/// Screen
/// --------------------
class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = "";

  int _selectedCompanyIndex = 0; // highlight the first card like the screenshot
  int _bottomIndex = 2; // "الشركات" selected (home in middle-ish of your UI)

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Company> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return _mockCompanies;
    return _mockCompanies
        .where((c) => c.name.isNotEmpty && c.name.contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5C5CE6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "الشركات",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("الإشعارات")),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () {
              // TODO: open menu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("القائمة")),
              );
            },
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          _SearchBar(
            controller: _search,
            hintText: "بحث عن اسم الشركة...",
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 110),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final c = _filtered[i];
                  final isPlaceholder = c.name.isEmpty;
                  final isSelected = !isPlaceholder && (i == _selectedCompanyIndex);

                  return _CompanyCard(
                    company: c,
                    isSelected: isSelected,
                    onTap: isPlaceholder
                        ? null
                        : () => setState(() => _selectedCompanyIndex = i),
                    onAction: isPlaceholder
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("عرض المورد: ${c.name}")),
                            );
                          },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Bottom bar with floating center button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _CenterFab(
        color: primary,
        label: "الشركات",
        icon: Icons.calendar_month_rounded,
        onTap: () {
          setState(() => _bottomIndex = 2);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("الشركات")),
          );
        },
      ),
      bottomNavigationBar: _BottomDock(
        selectedIndex: _bottomIndex,
        onSelect: (idx) => setState(() => _bottomIndex = idx),
      ),
    );
  }
}

/// --------------------
/// Widgets
/// --------------------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFCDD3FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF6B6B6B)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search_rounded, color: Color(0xFF9AA0A6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _CompanyCard({
    required this.company,
    required this.isSelected,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = company.name.isEmpty;

    final borderColor = isSelected
        ? const Color(0xFF5C5CE6)
        : const Color(0xFFB9B9B9);

    final shadow = isSelected
        ? [
            BoxShadow(
              color: const Color(0xFF5C5CE6).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ];

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1.2),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: isPlaceholder
                    ? Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_outlined,
                            color: Color(0xFFB0B7C3), size: 28),
                      )
                    : _Logo(logoUrl: company.logoUrl),
              ),
            ),
            if (!isPlaceholder) ...[
              Text(
                company.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                company.status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  company.actionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C5CE6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? logoUrl;
  const _Logo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url == null || url.isEmpty) {
      return const Icon(Icons.apartment_rounded, size: 56, color: Color(0xFF8B93A7));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.apartment_rounded,
          size: 56,
          color: Color(0xFF8B93A7),
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CenterFab({
    required this.color,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      width: 78,
      child: Column(
        children: [
          Material(
            elevation: 10,
            shadowColor: color.withOpacity(0.35),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          )
        ],
      ),
    );
  }
}

class _BottomDock extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _BottomDock({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5C5CE6);

    Widget item({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final active = selectedIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: active ? primary : const Color(0xFFB0B7C3)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active ? primary : const Color(0xFFB0B7C3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      height: 70,
      color: primary,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          item(index: 0, icon: Icons.description_rounded, label: "الطلبات"),
          item(index: 1, icon: Icons.chat_bubble_rounded, label: "المحادثة"),
          const SizedBox(width: 60), // space for center FAB
          item(index: 3, icon: Icons.home_rounded, label: "الرئيسية"),
          item(index: 4, icon: Icons.person_rounded, label: "حسابي"),
        ],
      ),
    );
  }
}
