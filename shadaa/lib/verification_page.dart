import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // وحدات التحكم للحصول على القيم من كل حقل
  final TextEditingController _pin1 = TextEditingController();
  final TextEditingController _pin2 = TextEditingController();
  final TextEditingController _pin3 = TextEditingController();
  final TextEditingController _pin4 = TextEditingController();

  // دالة التحقق من اكتمال الرمز
  void _verifyOtp() {
    String otp = _pin1.text + _pin2.text + _pin3.text + _pin4.text;

    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال الرمز المكون من 4 أرقام كاملاً',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/lock.png',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'تحقق',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'يرجى إدخال الرمز الذي أرسلناه إليك عبر البريد الإلكتروني',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),

            // صف حقول الرمز - الاتجاه LTR لضمان ترتيب المربعات من اليسار لليمين برمجياً
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOtpBox(_pin1, first: true, last: false),
                  _buildOtpBox(_pin2, first: false, last: false),
                  _buildOtpBox(_pin3, first: false, last: false),
                  _buildOtpBox(_pin4, first: false, last: true),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text('00:120 Sec', style: TextStyle(color: Colors.black45)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // منطق إعادة الإرسال هنا
              },
              child: const Text(
                'لم تستلم الرمز؟ أعد إرساله',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'تأكيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الويدجت المعدل للانتقال السلس والفوري
  Widget _buildOtpBox(
    TextEditingController controller, {
    required bool first,
    required bool last,
  }) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.text.isNotEmpty
              ? const Color(0xFF6A5AE0)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        showCursor: false, // إخفاء المؤشر لجمالية التصميم
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A5AE0),
        ),
        onChanged: (value) {
          // تحديث الحالة لتغيير لون الإطار عند الكتابة
          setState(() {});

          // الانتقال الفوري للحقل التالي
          if (value.length == 1 && !last) {
            FocusScope.of(context).nextFocus();
          }
          // العودة الفورية للحقل السابق عند المسح
          if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintText: "-",
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
