import 'package:flutter/material.dart';

class DiscussionSchedulePage extends StatelessWidget {
  const DiscussionSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "جدول مواعيد المناقشات",
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF6A5AE0),
              fontWeight: FontWeight.bold,
              fontSize: 15, // حجم خط عنوان الصفحة
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A5AE0), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 40.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // رأس البطاقة: الأيقونة والاسم
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Nabil Kamal",
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13, // حجم خط الاسم
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF6A5AE0).withOpacity(0.1),
                    child: const Text(
                      "N", 
                      style: TextStyle(color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // نص الرسالة من المشرف
              const Text(
                "السلام عليكم ... جدول مناقشات التدريب الميداني لقسم الحاسب الآلي ... يرجى الالتزام بالمواعيد المحددة بالجدول ... تمنياتي بالتوفيق",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12, // حجم خط المحتوى
                  height: 1.6,
                  color: Color(0xFF616161),
                ),
              ),
              const SizedBox(height: 20),

              // مكان الصورة (Placeholder)
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6A5AE0).withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search_outlined, size: 50, color: const Color(0xFF6A5AE0).withOpacity(0.4)),
                    const SizedBox(height: 12),
                    const Text(
                      "سيتم عرض صورة الجدول هنا عند توفرها",
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Color(0xFF6A5AE0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 