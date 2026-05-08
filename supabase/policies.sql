-- =====================================================
-- Row Level Security (RLS) Policies
-- سياسات أمان قاعدة البيانات
-- =====================================================
-- هذه السياسات تحدد من يستطيع قراءة/كتابة كل جدول.
-- تشغيلها بعد schema.sql مباشرة.
-- =====================================================

-- ============== ENABLE RLS ON ALL TABLES ==============
alter table public.profiles enable row level security;
alter table public.merchants enable row level security;
alter table public.reviews enable row level security;
alter table public.verification_requests enable row level security;
alter table public.reports enable row level security;
alter table public.helpful_votes enable row level security;
alter table public.merchant_views enable row level security;
alter table public.saved_merchants enable row level security;

-- ============== PROFILES ==============
-- أي شخص يقدر يقرأ ملفات تعريف عامة
create policy "profiles are viewable by everyone"
  on public.profiles for select using (true);

-- المستخدم يقدر يحدّث ملفه فقط
create policy "users can update own profile"
  on public.profiles for update using (auth.uid() = id);

-- ============== MERCHANTS ==============
-- أي شخص يقدر يقرأ التجار
create policy "merchants are viewable by everyone"
  on public.merchants for select using (true);

-- أي مستخدم مسجل يقدر يضيف تاجر جديد (سيكون في حالة pending)
create policy "authenticated users can create merchants"
  on public.merchants for insert
  with check (auth.role() = 'authenticated');

-- التاجر يقدر يحدّث ملفه فقط
create policy "merchant owner can update"
  on public.merchants for update
  using (auth.uid() = owner_id);

-- الأدمن يقدر يحدث أي تاجر
create policy "admins can update any merchant"
  on public.merchants for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- الأدمن يقدر يحذف
create policy "admins can delete merchants"
  on public.merchants for delete
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============== REVIEWS ==============
-- أي شخص يقرأ التقييمات الظاهرة فقط
create policy "visible reviews are viewable by everyone"
  on public.reviews for select using (is_hidden = false);

-- الأدمن يرى كل التقييمات
create policy "admins can view all reviews"
  on public.reviews for select
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- المستخدمين المسجلين يقدرون يكتبون تقييمات
create policy "authenticated users can write reviews"
  on public.reviews for insert
  with check (auth.uid() = reviewer_id);

-- المستخدم يقدر يعدّل تقييمه (خلال 30 يوم)
create policy "users can update own recent reviews"
  on public.reviews for update
  using (
    auth.uid() = reviewer_id
    and created_at > now() - interval '30 days'
  );

-- التاجر يقدر يضيف رد على تقييماته (لكن لا يحذف)
create policy "merchant can reply to reviews"
  on public.reviews for update
  using (
    exists (
      select 1 from public.merchants
      where id = reviews.merchant_id and owner_id = auth.uid()
    )
  );

-- الأدمن يقدر يخفي/يحذف
create policy "admins can update any review"
  on public.reviews for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "admins can delete reviews"
  on public.reviews for delete
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============== VERIFICATION REQUESTS ==============
-- التاجر يرى طلبات توثيقه فقط
create policy "merchants see own verification requests"
  on public.verification_requests for select
  using (
    submitted_by = auth.uid()
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- المستخدم المسجل يقدر يقدم طلب توثيق
create policy "merchants can submit verification"
  on public.verification_requests for insert
  with check (auth.uid() = submitted_by);

-- الأدمن يحدّث الحالة
create policy "admins can review verifications"
  on public.verification_requests for update
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============== REPORTS ==============
-- أي مستخدم يقدر يقدم بلاغ
create policy "authenticated users can report"
  on public.reports for insert
  with check (auth.uid() = reporter_id);

-- الأدمن يرى ويعالج
create policy "admins can view and resolve reports"
  on public.reports for all
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- ============== HELPFUL VOTES ==============
create policy "users can read all helpful votes"
  on public.helpful_votes for select using (true);

create policy "users can vote helpful"
  on public.helpful_votes for insert
  with check (auth.uid() = user_id);

create policy "users can remove own vote"
  on public.helpful_votes for delete
  using (auth.uid() = user_id);

-- ============== SAVED MERCHANTS ==============
create policy "users see own saved merchants"
  on public.saved_merchants for select
  using (auth.uid() = user_id);

create policy "users can save merchants"
  on public.saved_merchants for insert
  with check (auth.uid() = user_id);

create policy "users can unsave"
  on public.saved_merchants for delete
  using (auth.uid() = user_id);

-- ============== MERCHANT VIEWS ==============
-- أي شخص يقدر يسجل مشاهدة (للإحصائيات)
create policy "anyone can log views"
  on public.merchant_views for insert
  with check (true);

-- التاجر يرى مشاهدات متجره
create policy "merchant sees own views"
  on public.merchant_views for select
  using (
    exists (
      select 1 from public.merchants
      where id = merchant_views.merchant_id and owner_id = auth.uid()
    )
    or exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );
