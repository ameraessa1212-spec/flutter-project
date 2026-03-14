import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:Waslla/const/color.dart';

class AccountPage extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const AccountPage({super.key, this.scaffoldKey});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _image;
  DateTime? startDate;
  DateTime? endDate;
  int currentStatus = 0;
  final List<String> statusLabels = [
    "تم القبول",
    "بدء التدريب",
    "قيد التدريب",
    "انتهاء التدريب",
    "تسليم التقرير",
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "حسابي",
          style: TextStyle(
            color: primarycolor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.notifications_none, color: primarycolor, size: 26),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const NotificationsScreen(),
        //         ),
        //       );
        //     },
        //   ),
        //   const SizedBox(width: 5),
        //   IconButton(
        //     icon: Icon(Icons.menu, color: primarycolor, size: 26),
        //     onPressed: () {
        //       if (widget.scaffoldKey != null) {
        //         widget.scaffoldKey!.currentState?.openEndDrawer();
        //       } else {
        //         Scaffold.of(context).openEndDrawer();
        //       }
        //     },
        //   ),
        //   const SizedBox(width: 15),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildStatusTimeline(),
              const SizedBox(height: 40),
              _buildDateSection("تاريخ بداية التدريب", startDate, true),
              const SizedBox(height: 25),
              _buildDateSection("تاريخ نهاية التدريب", endDate, false),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primarycolor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                      _image == null
                          ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primarycolor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أميرة عيسى كرناص',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'رقم القيد: 219180456',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                'حاسب آلي',
                style: TextStyle(
                  color: primarycolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "فترة التدريب",
            style: TextStyle(color: primarycolor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(statusLabels.length, (index) {
            bool isCurrentOrPast = index <= currentStatus;
            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color:
                              index == 0
                                  ? Colors.transparent
                                  : (isCurrentOrPast
                                      ? primarycolor
                                      : Colors.grey[300]),
                          thickness: 2,
                        ),
                      ),
                      Icon(
                        isCurrentOrPast ? Icons.check_circle : Icons.circle,
                        size: 16,
                        color:
                            isCurrentOrPast ? primarycolor : Colors.grey[300],
                      ),
                      Expanded(
                        child: Divider(
                          color:
                              index == statusLabels.length - 1
                                  ? Colors.transparent
                                  : (index < currentStatus
                                      ? primarycolor
                                      : Colors.grey[300]),
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusLabels[index],
                    style: TextStyle(
                      fontSize: 8,
                      color: isCurrentOrPast ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateSection(String title, DateTime? date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (currentStatus < statusLabels.length - 1) {
                  setState(() => currentStatus++);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primarycolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "إرسال",
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, isStart),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.calendar_month, color: primarycolor),
                      Text(
                        date == null
                            ? "2025-01-10"
                            : DateFormat('yyyy-MM-dd').format(date),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }
}
