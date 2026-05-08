-- =====================================================
-- Oud Index Platform · Database Schema
-- منصة مؤشر العود · هيكل قاعدة البيانات
-- =====================================================
--
-- كيفية الاستخدام:
-- 1. اذهبي إلى https://supabase.com وأنشئي مشروعاً جديداً
-- 2. افتحي SQL Editor من القائمة الجانبية
-- 3. الصقي محتوى هذا الملف وشغّليه
-- 4. ثم شغّلي seed.sql لإضافة بيانات أولية
-- 5. ثم شغّلي policies.sql لتفعيل سياسات الأمان
-- =====================================================

-- ============== EXTENSIONS ==============
create extension if not exists "uuid-ossp";
create extension if not exists "pg_trgm"; -- للبحث النصي السريع

-- ============== ENUMS ==============
create type merchant_region as enum ('gulf', 'asia', 'west', 'other');
create type verification_status as enum ('pending', 'in_review', 'verified', 'rejected');
create type user_role as enum ('customer', 'merchant', 'admin');

-- ============== USERS / PROFILES ==============
-- ملف تعريف المستخدم (مرتبط بـ Supabase Auth)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text,
  phone text,
  phone_verified boolean default false,
  avatar_url text,
  role user_role default 'customer',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_profiles_role on public.profiles(role);
create index idx_profiles_email on public.profiles(email);

-- Trigger لإنشاء profile تلقائياً عند تسجيل مستخدم جديد
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'),
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============== MERCHANTS (التجار) ==============
create table public.merchants (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,                          -- للرابط: /directory/abdulsamad-al-qurashi
  name_ar text not null,                              -- الاسم بالعربي
  name_en text,                                       -- الاسم بالإنجليزي (للSEO)
  country text not null,
  country_code text,                                  -- ISO: SA, AE, KW, etc.
  flag text,                                          -- emoji 🇸🇦
  region merchant_region not null,
  city text,

  -- التخصص
  types text[] not null default '{}',                 -- ["هندي","كمبودي","دهن العود"]

  -- المعلومات
  description_ar text,
  description_en text,
  founded_year int,

  -- التواصل
  website text,
  instagram text,
  whatsapp text,
  email text,
  phone text,

  -- التوثيق
  verification_status verification_status default 'pending',
  verified_at timestamptz,
  verified_by uuid references public.profiles(id),

  -- الملكية (إذا طالب التاجر بالقائمة)
  owner_id uuid references public.profiles(id) on delete set null,
  claimed_at timestamptz,

  -- الإحصائيات (محسوبة تلقائياً عبر trigger)
  reviews_count int default 0,
  average_rating numeric(3,2) default 0,
  views_count int default 0,

  -- SEO و البحث
  search_vector tsvector,

  -- التوقيتات
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_merchants_slug on public.merchants(slug);
create index idx_merchants_region on public.merchants(region);
create index idx_merchants_verification on public.merchants(verification_status);
create index idx_merchants_country on public.merchants(country);
create index idx_merchants_types on public.merchants using gin(types);
create index idx_merchants_search on public.merchants using gin(search_vector);
create index idx_merchants_rating on public.merchants(average_rating desc);

-- Trigger للبحث النصي
create or replace function public.merchants_search_update()
returns trigger as $$
begin
  new.search_vector :=
    setweight(to_tsvector('simple', coalesce(new.name_ar, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(new.name_en, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(new.country, '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(array_to_string(new.types, ' '), '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(new.description_ar, '')), 'C') ||
    setweight(to_tsvector('simple', coalesce(new.description_en, '')), 'C');
  return new;
end;
$$ language plpgsql;

drop trigger if exists merchants_search_trigger on public.merchants;
create trigger merchants_search_trigger
  before insert or update on public.merchants
  for each row execute function public.merchants_search_update();

-- ============== REVIEWS (التقييمات) ==============
create table public.reviews (
  id uuid primary key default uuid_generate_v4(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  reviewer_id uuid references public.profiles(id) on delete set null,

  -- محتوى التقييم
  reviewer_name text not null,                        -- نسخة محفوظة للحفاظ على العرض
  rating int not null check (rating between 1 and 5),
  text text not null check (char_length(text) between 10 and 2000),

  -- التحقق من الشراء
  is_verified_buyer boolean default false,
  proof_of_purchase_url text,                         -- صورة الإيصال (اختياري)

  -- رد التاجر
  merchant_reply text,
  merchant_reply_at timestamptz,

  -- الإشراف
  is_hidden boolean default false,                    -- مخفي بقرار الأدمن
  hidden_reason text,
  reports_count int default 0,

  -- الإحصائيات
  helpful_count int default 0,                        -- "مفيد" من الزوار

  -- التوقيتات
  created_at timestamptz default now(),
  updated_at timestamptz default now(),

  -- العميل لا يستطيع تقييم نفس التاجر مرتين
  unique(merchant_id, reviewer_id)
);

create index idx_reviews_merchant on public.reviews(merchant_id);
create index idx_reviews_reviewer on public.reviews(reviewer_id);
create index idx_reviews_created on public.reviews(created_at desc);
create index idx_reviews_rating on public.reviews(rating);
create index idx_reviews_visible on public.reviews(merchant_id, is_hidden) where is_hidden = false;

-- Trigger لتحديث إحصائيات التاجر تلقائياً
create or replace function public.update_merchant_stats()
returns trigger as $$
declare
  merchant_id_var uuid;
begin
  if (tg_op = 'DELETE') then
    merchant_id_var := old.merchant_id;
  else
    merchant_id_var := new.merchant_id;
  end if;

  update public.merchants
  set
    reviews_count = (
      select count(*) from public.reviews
      where merchant_id = merchant_id_var and is_hidden = false
    ),
    average_rating = coalesce((
      select round(avg(rating)::numeric, 2) from public.reviews
      where merchant_id = merchant_id_var and is_hidden = false
    ), 0),
    updated_at = now()
  where id = merchant_id_var;

  return null;
end;
$$ language plpgsql;

drop trigger if exists reviews_stats_trigger on public.reviews;
create trigger reviews_stats_trigger
  after insert or update or delete on public.reviews
  for each row execute function public.update_merchant_stats();

-- ============== VERIFICATION REQUESTS (طلبات التوثيق) ==============
create table public.verification_requests (
  id uuid primary key default uuid_generate_v4(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  submitted_by uuid not null references public.profiles(id),

  -- الوثائق
  commercial_registration_url text,                   -- صورة السجل التجاري
  national_id_url text,                               -- صورة بطاقة الهوية
  selfie_url text,                                    -- سيلفي مع البطاقة
  business_address text,
  business_phone text,

  -- مكالمة الفيديو
  video_call_scheduled_at timestamptz,
  video_call_completed_at timestamptz,

  -- القرار
  status verification_status default 'pending',
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id),
  reviewer_notes text,
  rejection_reason text,

  created_at timestamptz default now()
);

create index idx_verif_status on public.verification_requests(status);
create index idx_verif_merchant on public.verification_requests(merchant_id);

-- ============== REPORTS (البلاغات) ==============
create table public.reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid references public.profiles(id) on delete set null,

  -- ما يتم الإبلاغ عنه
  target_type text not null check (target_type in ('review', 'merchant')),
  target_id uuid not null,

  reason text not null,                               -- spam, fake, offensive, etc.
  details text,

  -- المعالجة
  status text default 'open' check (status in ('open', 'investigating', 'resolved', 'dismissed')),
  resolved_at timestamptz,
  resolved_by uuid references public.profiles(id),
  resolution_note text,

  created_at timestamptz default now()
);

create index idx_reports_status on public.reports(status);
create index idx_reports_target on public.reports(target_type, target_id);

-- Trigger لزيادة عداد البلاغات على التقييم
create or replace function public.increment_review_reports()
returns trigger as $$
begin
  if new.target_type = 'review' then
    update public.reviews
    set reports_count = reports_count + 1
    where id = new.target_id;
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists reports_count_trigger on public.reports;
create trigger reports_count_trigger
  after insert on public.reports
  for each row execute function public.increment_review_reports();

-- ============== HELPFUL VOTES (مفيد) ==============
create table public.helpful_votes (
  id uuid primary key default uuid_generate_v4(),
  review_id uuid not null references public.reviews(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(review_id, user_id)
);

-- ============== VIEWS LOG (لإحصائيات التجار) ==============
create table public.merchant_views (
  id bigserial primary key,
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  visitor_session text,                               -- session ID مجهول
  viewed_at timestamptz default now()
);

create index idx_views_merchant on public.merchant_views(merchant_id, viewed_at desc);

-- ============== SAVED MERCHANTS (المفضلة) ==============
create table public.saved_merchants (
  user_id uuid not null references public.profiles(id) on delete cascade,
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  saved_at timestamptz default now(),
  primary key (user_id, merchant_id)
);

-- ============== HELPER FUNCTIONS ==============

-- توليد slug من الاسم
create or replace function public.generate_slug(name text)
returns text as $$
declare
  base_slug text;
  final_slug text;
  counter int := 0;
begin
  -- تنظيف الاسم وتحويله لـ slug
  base_slug := lower(trim(name));
  base_slug := regexp_replace(base_slug, '[^a-z0-9\s-]', '', 'g');
  base_slug := regexp_replace(base_slug, '\s+', '-', 'g');
  base_slug := regexp_replace(base_slug, '-+', '-', 'g');
  base_slug := trim(both '-' from base_slug);

  if base_slug = '' then
    base_slug := 'merchant-' || extract(epoch from now())::bigint::text;
  end if;

  final_slug := base_slug;

  -- إضافة رقم لو مكرر
  while exists (select 1 from public.merchants where slug = final_slug) loop
    counter := counter + 1;
    final_slug := base_slug || '-' || counter;
  end loop;

  return final_slug;
end;
$$ language plpgsql;
