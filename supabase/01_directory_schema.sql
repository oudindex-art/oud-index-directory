-- =====================================================
-- Oud Index — Directory Schema (Adapted)
-- متوافق مع المشروع الحالي:
-- - يحافظ على profiles الموجود (يضيف أعمدة فقط)
-- - يستخدم is_admin الموجود بدل role enum
-- - يضيف الجداول الجديدة فقط (لن يكسر شيئاً موجوداً)
-- =====================================================

-- ============== EXTENSIONS ==============
create extension if not exists "uuid-ossp";
create extension if not exists "pg_trgm";

-- ============== EXTEND profiles (آمن — IF NOT EXISTS) ==============
alter table public.profiles add column if not exists phone text;
alter table public.profiles add column if not exists phone_verified boolean default false;
alter table public.profiles add column if not exists is_merchant boolean default false;
alter table public.profiles add column if not exists updated_at timestamptz default now();

-- ============== ENUMS (آمن — IF NOT EXISTS) ==============
do $$ begin
  create type merchant_region as enum ('gulf', 'asia', 'west', 'other');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type verification_status as enum ('pending', 'in_review', 'verified', 'rejected');
exception when duplicate_object then null;
end $$;

-- ============== MERCHANTS ==============
create table if not exists public.merchants (
  id uuid primary key default uuid_generate_v4(),
  slug text unique not null,
  name_ar text not null,
  name_en text,
  country text not null,
  country_code text,
  flag text,
  region merchant_region not null,
  city text,
  types text[] not null default '{}',
  description_ar text,
  description_en text,
  founded_year int,
  website text,
  instagram text,
  whatsapp text,
  email text,
  phone text,
  verification_status verification_status default 'pending',
  verified_at timestamptz,
  verified_by uuid references public.profiles(id),
  owner_id uuid references public.profiles(id) on delete set null,
  claimed_at timestamptz,
  reviews_count int default 0,
  average_rating numeric(3,2) default 0,
  views_count int default 0,
  search_vector tsvector,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_merchants_slug on public.merchants(slug);
create index if not exists idx_merchants_region on public.merchants(region);
create index if not exists idx_merchants_verification on public.merchants(verification_status);
create index if not exists idx_merchants_country on public.merchants(country);
create index if not exists idx_merchants_types on public.merchants using gin(types);
create index if not exists idx_merchants_search on public.merchants using gin(search_vector);
create index if not exists idx_merchants_rating on public.merchants(average_rating desc);

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

-- ============== REVIEWS ==============
create table if not exists public.reviews (
  id uuid primary key default uuid_generate_v4(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  reviewer_id uuid references public.profiles(id) on delete set null,
  reviewer_name text not null,
  rating int not null check (rating between 1 and 5),
  text text not null check (char_length(text) between 10 and 2000),
  is_verified_buyer boolean default false,
  proof_of_purchase_url text,
  merchant_reply text,
  merchant_reply_at timestamptz,
  is_hidden boolean default false,
  hidden_reason text,
  reports_count int default 0,
  helpful_count int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(merchant_id, reviewer_id)
);

create index if not exists idx_reviews_merchant on public.reviews(merchant_id);
create index if not exists idx_reviews_reviewer on public.reviews(reviewer_id);
create index if not exists idx_reviews_created on public.reviews(created_at desc);
create index if not exists idx_reviews_visible on public.reviews(merchant_id, is_hidden) where is_hidden = false;

-- Trigger لتحديث إحصائيات التاجر
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
    reviews_count = (select count(*) from public.reviews where merchant_id = merchant_id_var and is_hidden = false),
    average_rating = coalesce((select round(avg(rating)::numeric, 2) from public.reviews where merchant_id = merchant_id_var and is_hidden = false), 0),
    updated_at = now()
  where id = merchant_id_var;
  return null;
end;
$$ language plpgsql;

drop trigger if exists reviews_stats_trigger on public.reviews;
create trigger reviews_stats_trigger
  after insert or update or delete on public.reviews
  for each row execute function public.update_merchant_stats();

-- ============== VERIFICATION REQUESTS ==============
create table if not exists public.verification_requests (
  id uuid primary key default uuid_generate_v4(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  submitted_by uuid not null references public.profiles(id),
  commercial_registration_url text,
  national_id_url text,
  selfie_url text,
  business_address text,
  business_phone text,
  video_call_scheduled_at timestamptz,
  video_call_completed_at timestamptz,
  status verification_status default 'pending',
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id),
  reviewer_notes text,
  rejection_reason text,
  created_at timestamptz default now()
);

create index if not exists idx_verif_status on public.verification_requests(status);

-- ============== REPORTS ==============
create table if not exists public.merchant_reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid references public.profiles(id) on delete set null,
  target_type text not null check (target_type in ('review', 'merchant')),
  target_id uuid not null,
  reason text not null,
  details text,
  status text default 'open' check (status in ('open', 'investigating', 'resolved', 'dismissed')),
  resolved_at timestamptz,
  resolved_by uuid references public.profiles(id),
  resolution_note text,
  created_at timestamptz default now()
);

create index if not exists idx_reports_status on public.merchant_reports(status);

-- زيادة عداد البلاغات على التقييم
create or replace function public.increment_review_reports()
returns trigger as $$
begin
  if new.target_type = 'review' then
    update public.reviews set reports_count = reports_count + 1 where id = new.target_id;
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists reports_count_trigger on public.merchant_reports;
create trigger reports_count_trigger
  after insert on public.merchant_reports
  for each row execute function public.increment_review_reports();

-- ============== HELPFUL VOTES ==============
create table if not exists public.helpful_votes (
  id uuid primary key default uuid_generate_v4(),
  review_id uuid not null references public.reviews(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(review_id, user_id)
);

-- ============== MERCHANT VIEWS ==============
create table if not exists public.merchant_views (
  id bigserial primary key,
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  visitor_session text,
  viewed_at timestamptz default now()
);

create index if not exists idx_views_merchant on public.merchant_views(merchant_id, viewed_at desc);

-- ============== SAVED MERCHANTS ==============
create table if not exists public.saved_merchants (
  user_id uuid not null references public.profiles(id) on delete cascade,
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  saved_at timestamptz default now(),
  primary key (user_id, merchant_id)
);

-- ============== التحقق ==============
select
  'merchants' as table_name, count(*) from public.merchants
union all select 'reviews', count(*) from public.reviews
union all select 'verification_requests', count(*) from public.verification_requests
union all select 'merchant_reports', count(*) from public.merchant_reports;
