# دليل الإعداد والنشر — خطوة بخطوة بالعربي
## Setup & Deployment Guide

> هذا الدليل يأخذكِ من الصفر إلى موقع مباشر على `oudindex.com/directory`.
> لا يحتاج خبرة برمجية، فقط متابعة الخطوات بالترتيب.
> **الزمن المتوقع: ٤٥-٦٠ دقيقة كاملة.**

---

## المتطلبات قبل البدء

كل ما تحتاجينه:

- [ ] حساب على [GitHub](https://github.com) (لرفع الكود) — مجاني
- [ ] حساب على [Supabase](https://supabase.com) (قاعدة البيانات) — مجاني
- [ ] حساب على [Vercel](https://vercel.com) (الاستضافة) — مجاني
- [ ] حساب على [Resend](https://resend.com) (الإيميلات) — مجاني
- [ ] الوصول إلى إعدادات النطاق `oudindex.com` (DNS)

كل الحسابات أعلاه **مجانية** لأشهر الأولى.

---

## الخطوة ١: إعداد Supabase (قاعدة البيانات) — ١٥ دقيقة

### ١.١ إنشاء المشروع

1. اذهبي إلى [supabase.com](https://supabase.com) وسجّلي دخول
2. اضغطي **New Project**
3. املئي:
   - **Name**: `oud-index`
   - **Database Password**: اختاري كلمة سر قوية (احفظيها!)
   - **Region**: `EU (Ireland)` أو `Singapore` (الأقرب لجمهورك)
4. اضغطي **Create new project** وانتظري دقيقتين

### ١.٢ تشغيل قاعدة البيانات

1. من القائمة الجانبية، اختاري **SQL Editor**
2. اضغطي **+ New query**
3. **شغّلي ٣ ملفات بالترتيب:**

   **أولاً:** افتحي `supabase/schema.sql` من المشروع، انسخي محتواه كاملاً، الصقيه في SQL Editor، اضغطي **Run** ▶️

   **ثانياً:** افتحي `supabase/policies.sql`، نفس الخطوات

   **ثالثاً:** افتحي `supabase/seed.sql`، نفس الخطوات (هذا يضيف ٢٨ تاجر للبدء)

4. تأكدي من نجاح كل خطوة (يجب ترى ✓ Success)

### ١.٣ تفعيل المصادقة

1. من القائمة الجانبية، اختاري **Authentication** → **Providers**
2. **Email**: مفعّل تلقائياً ✓
3. **Google** (اختياري لكن موصى به):
   - فعّليه
   - اتبعي [دليل Google OAuth](https://supabase.com/docs/guides/auth/social-login/auth-google)

### ١.٤ نسخ مفاتيح الاتصال

1. من القائمة الجانبية، **Project Settings** → **API**
2. انسخي **Project URL** (يبدأ بـ `https://xxxx.supabase.co`)
3. انسخي **anon / public** key
4. انسخي **service_role** key (سرّي جداً، لا تشاركيها)

احفظي هذه ٣ قيم — ستحتاجينها بعد قليل.

---

## الخطوة ٢: إعداد Resend (الإيميلات) — ١٠ دقيقة

### ٢.١ إنشاء الحساب

1. اذهبي إلى [resend.com](https://resend.com) وسجّلي
2. من القائمة، **Domains** → **Add Domain**
3. أدخلي `oudindex.com`
4. سيُعطيكِ Resend مجموعة سجلات DNS

### ٢.٢ إضافة سجلات DNS

اذهبي إلى مزوّد النطاق (مثل GoDaddy أو Cloudflare) حيث يعيش `oudindex.com` وأضيفي السجلات التي أعطاكِ Resend (عادة TXT و MX records).

### ٢.٣ التحقق

ارجعي لـ Resend واضغطي **Verify Domain**. قد يستغرق حتى ٢٤ ساعة لكن غالباً دقائق.

### ٢.٤ نسخ API Key

من القائمة، **API Keys** → **Create API Key** (احفظيه).

---

## الخطوة ٣: رفع الكود إلى GitHub — ٥ دقائق

### ٣.١ إنشاء repository

1. على GitHub، اضغطي **+ New repository**
2. الاسم: `oud-index-platform`
3. خاص (Private) أو عام — اختياركِ
4. **Create repository**

### ٣.٢ رفع الكود

في الطرفية (Terminal) على جهازك:

```bash
cd مسار/مجلد/oud-index-platform
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/oud-index-platform.git
git push -u origin main
```

---

## الخطوة ٤: النشر على Vercel — ١٠ دقيقة

### ٤.١ ربط Vercel بـ GitHub

1. اذهبي إلى [vercel.com](https://vercel.com)
2. سجّلي دخول بـ GitHub
3. **Import Project**
4. اختاري `oud-index-platform`

### ٤.٢ ضبط متغيرات البيئة

في صفحة الـ Import، أضيفي **Environment Variables**:

| الاسم | القيمة |
|-------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | (من الخطوة ١.٤) |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | (من الخطوة ١.٤) |
| `SUPABASE_SERVICE_ROLE_KEY` | (من الخطوة ١.٤) |
| `RESEND_API_KEY` | (من الخطوة ٢.٤) |
| `EMAIL_FROM` | `Oud Index <noreply@oudindex.com>` |
| `EMAIL_ADMIN` | إيميلكِ الشخصي |
| `NEXT_PUBLIC_SITE_URL` | `https://oudindex.com` |
| `ADMIN_EMAILS` | إيميلكِ الشخصي |

### ٤.٣ النشر

اضغطي **Deploy**. انتظري دقيقتين. مبروك، الموقع مباشر على رابط مؤقت مثل `oud-index-platform.vercel.app`.

---

## الخطوة ٥: ربط النطاق `oudindex.com/directory` — ١٥ دقيقة

هذا أهم وأصعب جزء. عندكِ خياران:

### الخيار أ (الأسهل): دومين فرعي

اربطي `directory.oudindex.com` بـ Vercel:

1. في Vercel، **Project Settings** → **Domains**
2. أضيفي `directory.oudindex.com`
3. Vercel يعطيكِ سجل CNAME
4. أضيفيه في إعدادات DNS الخاصة بـ `oudindex.com`

> ملاحظة: هذا أسهل لكن أقل قوة في SEO. ينفع للبداية.

### الخيار ب (الأفضل للـ SEO): مسار فرعي

لتحقيق `oudindex.com/directory/`، تحتاجين:

**على Vercel** (إذا كان `oudindex.com` مستضاف هنا):
1. أضيفي مشروع `oudindex-platform` كـ subpath
2. في Vercel، Project Settings → Routing → أضيفي rewrite

**على Cloudflare** (إذا كان النطاق هنا):
1. **Workers Routes** → أنشئي route لـ `oudindex.com/directory/*`
2. أنشئي Worker يعمل reverse proxy إلى `oud-index-platform.vercel.app`

> هذا يحتاج خبرة تقنية. أنصحكِ تبدئين بالخيار أ ثم تنتقلين للخيار ب لاحقاً.

---

## الخطوة ٦: تعيين نفسكِ كأدمن — ٣ دقائق

1. سجّلي أول حساب على الموقع (`/register`)
2. ارجعي لـ Supabase → **Table Editor** → `profiles`
3. ابحثي عن الصف الذي إيميله إيميلكِ
4. غيّري عمود `role` من `customer` إلى `admin`
5. احفظي

أنتِ الآن أدمن وتقدرين تدخلين على `/admin`.

---

## الخطوة ٧: إعداد Google Search Console — ١٠ دقيقة (للSEO)

1. اذهبي [search.google.com/search-console](https://search.google.com/search-console)
2. أضيفي `oudindex.com`
3. اختاري طريقة التحقق (DNS أو HTML tag)
4. بعد التحقق، **Sitemaps** → أضيفي:
   ```
   https://oudindex.com/sitemap.xml
   ```

> Sitemap سيتم بناؤه تلقائياً في المرحلة 2.

---

## التحقق من النجاح

اختبري الروابط التالية على موقعكِ:

- [ ] `oudindex.com/directory` — يعرض ٢٨ تاجر
- [ ] `oudindex.com/directory?region=gulf` — يفلتر للخليج فقط
- [ ] `oudindex.com/directory/abdul-samad-al-qurashi` — صفحة عبد الصمد القرشي
- [ ] فعالة الـ search box — اكتبي "كمبودي"
- [ ] افتحي صفحة تاجر، انظري في source code → يجب ترين `<script type="application/ld+json">` (هذا للSEO)

إذا كل شيء يعمل، **مبروك! المرحلة الأولى منشورة.**

---

## ماذا بعد؟

في الجلسة القادمة سأبني لكِ المرحلة 2 (التسجيل + الدخول + نموذج التقييم) والمرحلة 3 (لوحة التاجر + لوحة الأدمن + الإيميلات).

---

## استكشاف الأخطاء

### الموقع لا يعرض التجار
- تأكدي من تشغيل `seed.sql` بنجاح
- في Supabase، **Table Editor** → `merchants` → يجب ترين ٢٨ صف
- تحقق من متغيرات البيئة في Vercel

### خطأ في النشر على Vercel
- تأكدي من رفع كل الملفات (بما فيها `package.json`)
- راجعي logs في Vercel للتفاصيل

### الإيميلات لا تصل
- تحقّقي من تفعيل النطاق في Resend
- راجعي بريد السبام
- تأكدي من سجلات DNS

---

## أسئلة شائعة

**س: هل يمكن استخدام نطاق آخر غير oudindex.com؟**
ج: نعم، فقط غيّري `NEXT_PUBLIC_SITE_URL` في Vercel.

**س: كيف أضيف تجاراً يدوياً؟**
ج: من Supabase Table Editor، أو سيكون لكِ زر في لوحة الأدمن (المرحلة 3).

**س: هل التقييمات قابلة للحذف؟**
ج: العميل يقدر يعدّل خلال ٣٠ يوم. الأدمن (أنتِ) يقدر يخفي/يحذف. التاجر يقدر يرد لكن لا يحذف.

**س: ماذا لو أخطأت في خطوة؟**
ج: لا تقلقي، كل شي قابل للإصلاح. كل خطوة قابلة للإعادة.

---

تواصلي معي في أي خطوة تواجهين فيها مشكلة، وسأساعدكِ خطوة بخطوة.
