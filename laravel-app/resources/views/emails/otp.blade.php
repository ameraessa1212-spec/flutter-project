<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background-color:#f4f4f7;font-family:Arial,Tahoma,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#f4f4f7;padding:40px 0;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
                    <tr>
                        <td style="background-color:#6A5AE0;padding:30px;text-align:center;">
                            <h1 style="color:#ffffff;margin:0;font-size:24px;">وصلة تدريب</h1>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding:40px 30px;">
                            <h2 style="color:#333;margin:0 0 16px;font-size:20px;">مرحباً {{ $userName }}،</h2>
                            <p style="color:#555;font-size:15px;line-height:1.8;margin:0 0 24px;">
                                لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك. استخدم الرمز التالي لإتمام العملية:
                            </p>
                            <div style="text-align:center;margin:32px 0;">
                                <div style="display:inline-block;background-color:#f0eefa;border:2px dashed #6A5AE0;border-radius:12px;padding:20px 48px;">
                                    <span style="font-size:36px;font-weight:bold;letter-spacing:12px;color:#6A5AE0;">{{ $otp }}</span>
                                </div>
                            </div>
                            <p style="color:#555;font-size:14px;line-height:1.8;margin:0 0 8px;">
                                هذا الرمز صالح لمدة <strong>10 دقائق</strong> فقط.
                            </p>
                            <p style="color:#888;font-size:13px;line-height:1.8;margin:24px 0 0;">
                                إذا لم تطلب إعادة تعيين كلمة المرور، يمكنك تجاهل هذا البريد.
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="background-color:#f9f9fb;padding:20px 30px;text-align:center;border-top:1px solid #eee;">
                            <p style="color:#aaa;font-size:12px;margin:0;">© {{ date('Y') }} وصلة تدريب. جميع الحقوق محفوظة.</p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
