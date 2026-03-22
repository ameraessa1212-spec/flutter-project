# تشغيل مشروع Laravel على Windows (من A إلى Z)

هذا الدليل يشرح تشغيل مشروع Laravel الموجود داخل مجلد `laravel-app` على نظام Windows خطوة بخطوة.

> ملاحظة: هذا المشروع مضبوط افتراضيًا على SQLite حسب `.env.example`.

---

## 1) المتطلبات (Prerequisites)

ثبّت الأدوات التالية على Windows:

1) **Git**
- https://git-scm.com/downloads

2) **PHP 8.2+**
- المشروع يتطلب PHP `^8.2`.
- تأكد أن PHP مضاف إلى PATH.

3) **Composer**
- https://getcomposer.org/download/

4) **Node.js (LTS) + npm**
- https://nodejs.org/

5) (حسب خيار قاعدة البيانات)
- **SQLite** (مفضل للتشغيل المحلي السريع).
- أو **PostgreSQL** إذا تفضل تشغيل DB على جهازك.

### تحقق سريع من الإصدارات
افتح PowerShell (أو Windows Terminal) ثم نفّذ:

```powershell
php -v
composer -V
node -v
npm -v
```

---

## 2) تنزيل المشروع وفتح مجلد Laravel

إذا كنت تعمل داخل هذا الريبو بالفعل، تأكد فقط أنك داخل مجلد Laravel:

```powershell
cd path\to\flutter-project\laravel-app
```

(استبدل `path\to\...` بمسارك على جهازك)

---

## 3) إعداد ملف البيئة `.env`

### 3.1 إنشاء `.env`
عادةً ستجد ملف `.env` موجودًا، لكن إن لم يكن موجودًا:

```powershell
copy .env.example .env
```

### 3.2 توليد مفتاح التطبيق

```powershell
php artisan key:generate
```

### 3.3 إعداد قاعدة البيانات (اختر مسارًا واحدًا)

#### الخيار A (مفضل): SQLite

1) تأكد من وجود ملف قاعدة البيانات:

```powershell
type nul > database\database.sqlite
```

2) افتح `.env` وعدّل القيم التالية:

```dotenv
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

ملاحظات مهمة:
- ستحتاج امتدادات PHP الخاصة بـ SQLite: `pdo_sqlite` و `sqlite3`.

#### الخيار B: PostgreSQL محلي على جهازك

1) ثبّت PostgreSQL (مثلاً عبر Windows installer).
2) أنشئ قاعدة بيانات (مثلاً `waslaa`).
3) في `.env` استخدم إعدادات محلية (مثال):

```dotenv
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=waslaa
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_SCHEMA=public
```

> تنبيه: إذا استخدمت إعدادات `DB_HOST/DB_DATABASE...` تأكد أن `DB_URL` غير مفعّل أو اتركه فارغًا لتفادي التعارض.

---

## 4) تثبيت اعتماديات PHP (Composer)

داخل `laravel-app` نفّذ:

```powershell
composer install
```

### (اختياري) إعداد تلقائي عبر سكربت Composer
المشروع يحتوي سكربت جاهز اسمه `setup` داخل `composer.json` يقوم عادةً بـ:
- `composer install`
- إنشاء `.env` إن لم يكن موجودًا
- `php artisan key:generate`
- `php artisan migrate --force`
- `npm install` ثم `npm run build`

لتشغيله:

```powershell
composer run setup
```

> مهم: تأكد أنك ضبطت إعدادات قاعدة البيانات في `.env` قبل تشغيل `setup` لأن خطوة `migrate` ستفشل إذا لم يكن اتصال DB جاهزًا.

إذا ظهرت مشاكل unzip أو extensions، راجع قسم “حل المشاكل الشائعة”.

---

## 5) تشغيل الـ Migrations (إنشاء الجداول)

بعد ضبط قاعدة البيانات في `.env`:

```powershell
php artisan migrate
```

إذا كان عندك Seeders وتحتاج بيانات تجريبية:

```powershell
php artisan db:seed
```

(نفّذها فقط إذا كان المشروع يحتوي Seeders مناسبة)

---

## 6) تثبيت اعتماديات الواجهة (Node/Vite)

```powershell
npm install
```

ثم للتطوير:

```powershell
npm run dev
```

أو للبناء للإنتاج:

```powershell
npm run build
```

---

## 7) تشغيل السيرفر

### تشغيل Laravel
في نافذة PowerShell جديدة داخل `laravel-app`:

```powershell
php artisan serve
```

ستجد التطبيق عادة على:
- http://127.0.0.1:8000

### تحقق سريع (Health Check)
يمكنك التأكد أن السيرفر يعمل بفتح الصفحة الرئيسية:

- http://127.0.0.1:8000

### تشغيل الكل مرة واحدة (اختياري)
هذا المشروع يحتوي سكربت `composer run dev` لتشغيل عدة خدمات معًا (السيرفر + Vite + Queue + Logs):

```powershell
composer run dev
```

إذا واجهت مشكلة مع هذا السكربت على Windows، استخدم التشغيل اليدوي:
- نافذة 1: `php artisan serve`
- نافذة 2: `npm run dev`

---

## 8) لوحة التحكم (Filament)

المشروع يحتوي لوحة تحكم Filament، والمسار ظاهر من إعدادات اللوحة:
- `/admin-waslaa`

مثال:
- http://127.0.0.1:8000/admin-waslaa

### إنشاء مستخدم إداري (إن لزم)
في مشاريع Filament عادة يوجد أمر لإنشاء مستخدم:

```powershell
php artisan make:filament-user
```

إذا كان الأمر غير موجود أو اختلف اسمه حسب نسخة Filament، ابحث في أوامر Artisan المتاحة:

```powershell
php artisan list | findstr filament
```

---

## 9) إعدادات التخزين (Storage)

الرفع في الـ API يستخدم disk اسمه `public` (Laravel filesystem).

- تأكد من تنفيذ:

```powershell
php artisan storage:link
```

---

## 10) حل المشاكل الشائعة على Windows

### A) `php` أو `composer` غير معروف
- تأكد من إضافة مسارات PHP وComposer إلى PATH.
- أغلق وافتح Terminal بعد تعديل PATH.

### B) أخطاء Extensions (مثل sqlite3 / pdo_sqlite / pgsql / pdo_pgsql / openssl)
1) افتح ملف `php.ini` (مكانه يعتمد على طريقة تثبيت PHP).
2) فعّل الأسطر التالية (مثال):

```ini
extension=openssl
extension=curl
extension=mbstring
extension=pdo_sqlite
extension=sqlite3
extension=pdo_pgsql
extension=pgsql
extension=fileinfo
```

ثم أعد تشغيل الطرفية وجرب:

```powershell
php -m | findstr pgsql
```

### C) `Class "ZipArchive" not found` أو مشاكل unzip أثناء `composer install`
- فعّل extension `zip` في `php.ini`:

```ini
extension=zip
```

### D) مشكلة اتصال PostgreSQL عبر DB_URL
- تأكد أن `DB_URL` مكتوب بصيغة صحيحة.
- تأكد من كلمة المرور/المعرف/المنطقة.
- تأكد أن `pdo_pgsql` مفعّل.

### E) Vite لا يعمل أو الصفحة بدون CSS/JS
- شغّل `npm install` ثم `npm run dev` أثناء التطوير.
- أو نفّذ `npm run build` ثم جرّب الصفحة.

---

## أوامر مفيدة (للصيانة)

```powershell
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

---

## تشغيل سريع (ملخص)

```powershell
cd path\to\flutter-project\laravel-app
copy .env.example .env
php artisan key:generate
# عدّل إعدادات DB في .env
composer install
php artisan migrate
npm install
# نافذتان:
php artisan serve
npm run dev
```
