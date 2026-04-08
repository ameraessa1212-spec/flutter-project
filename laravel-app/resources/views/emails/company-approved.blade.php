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
                            <div style="text-align:center;margin:0 0 24px;">
                                <div style="display:inline-block;background-color:#e8f5e9;border-radius:50%;padding:16px;">
                                    <span style="font-size:36px;">&#10003;</span>
                                </div>
                            </div>
                            <h2 style="color:#333;margin:0 0 16px;font-size:20px;text-align:center;">تمت الموافقة على شركتكم!</h2>
                            <p style="color:#555;font-size:15px;line-height:1.8;margin:0 0 24px;text-align:center;">
                                يسعدنا إبلاغكم بأنه تمت الموافقة على تسجيل شركة
                                <strong>{{ $companyName }}</strong>
                                في منصة وصلة تدريب.
                            </p>
                            <p style="color:#555;font-size:15px;line-height:1.8;margin:0 0 24px;">
                                يمكنكم الآن تسجيل الدخول إلى حسابكم والبدء في:
                            </p>
                            <ul style="color:#555;font-size:14px;line-height:2.2;padding-right:20px;margin:0 0 24px;">
                                <li>نشر فرص التدريب المتاحة</li>
                                <li>استقبال ومراجعة طلبات المتدربين</li>
                                <li>إدارة برامج التدريب</li>
                            </ul>
                            <div style="text-align:center;margin:32px 0;">
                                <a href="{{ $loginUrl }}" style="display:inline-block;background-color:#6A5AE0;color:#ffffff;text-decoration:none;padding:14px 40px;border-radius:8px;font-size:16px;font-weight:bold;">
                                    تسجيل الدخول
                                </a>
                            </div>
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
