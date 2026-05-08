-- =====================================================
-- Oud Index Directory · Combined Setup SQL
-- =====================================================
-- مكيّف للمشروع الموجود (يستخدم profiles & is_admin الحاليين)
-- يضيف فقط جداول الدليل + التقييمات + التوثيق
-- آمن للتشغيل: لا يلمس الجداول الموجودة (oud_prices, profiles, إلخ)
-- =====================================================

-- ============== EXTENSIONS ==============
create extension if not exists "uuid-ossp";
create extension if not exists "pg_trgm";

-- ============== ENUMS ==============
do $$ begin
  create type merchant_region as enum ('gulf', 'asia', 'west', 'other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type verification_status as enum ('pending', 'in_review', 'verified', 'rejected');
exception when duplicate_object then null; end $$;

-- ============== MERCHANTS (التجار) ==============
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

-- بحث نصي
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
create index if not exists idx_reviews_rating on public.reviews(rating);
create index if not exists idx_reviews_visible on public.reviews(merchant_id, is_hidden) where is_hidden = false;

-- تحديث إحصائيات التاجر تلقائياً
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
create index if not exists idx_verif_merchant on public.verification_requests(merchant_id);

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
create index if not exists idx_reports_target on public.merchant_reports(target_type, target_id);

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

drop trigger if exists reports_count_trigger on public.merchant_reports;
create trigger reports_count_trigger
  after insert on public.merchant_reports
  for each row execute function public.increment_review_reports();

-- ============== HELPFUL VOTES ==============
create table if not exists public.review_helpful_votes (
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

-- ============== RLS POLICIES (مكيّفة لـ is_admin) ==============

-- MERCHANTS
alter table public.merchants enable row level security;

drop policy if exists "merchants_public_read" on public.merchants;
create policy "merchants_public_read"
  on public.merchants for select using (true);

drop policy if exists "merchants_auth_insert" on public.merchants;
create policy "merchants_auth_insert"
  on public.merchants for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "merchants_owner_update" on public.merchants;
create policy "merchants_owner_update"
  on public.merchants for update
  using (auth.uid() = owner_id);

drop policy if exists "merchants_admin_update" on public.merchants;
create policy "merchants_admin_update"
  on public.merchants for update
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "merchants_admin_delete" on public.merchants;
create policy "merchants_admin_delete"
  on public.merchants for delete
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- REVIEWS
alter table public.reviews enable row level security;

drop policy if exists "reviews_public_read_visible" on public.reviews;
create policy "reviews_public_read_visible"
  on public.reviews for select using (is_hidden = false);

drop policy if exists "reviews_admin_read_all" on public.reviews;
create policy "reviews_admin_read_all"
  on public.reviews for select
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "reviews_auth_insert" on public.reviews;
create policy "reviews_auth_insert"
  on public.reviews for insert
  with check (auth.uid() = reviewer_id);

drop policy if exists "reviews_owner_update_recent" on public.reviews;
create policy "reviews_owner_update_recent"
  on public.reviews for update
  using (auth.uid() = reviewer_id and created_at > now() - interval '30 days');

drop policy if exists "reviews_merchant_reply" on public.reviews;
create policy "reviews_merchant_reply"
  on public.reviews for update
  using (
    exists (select 1 from public.merchants where id = reviews.merchant_id and owner_id = auth.uid())
  );

drop policy if exists "reviews_admin_update" on public.reviews;
create policy "reviews_admin_update"
  on public.reviews for update
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "reviews_admin_delete" on public.reviews;
create policy "reviews_admin_delete"
  on public.reviews for delete
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- VERIFICATION REQUESTS
alter table public.verification_requests enable row level security;

drop policy if exists "verif_self_read" on public.verification_requests;
create policy "verif_self_read"
  on public.verification_requests for select
  using (
    submitted_by = auth.uid()
    or exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

drop policy if exists "verif_self_insert" on public.verification_requests;
create policy "verif_self_insert"
  on public.verification_requests for insert
  with check (auth.uid() = submitted_by);

drop policy if exists "verif_admin_update" on public.verification_requests;
create policy "verif_admin_update"
  on public.verification_requests for update
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- REPORTS
alter table public.merchant_reports enable row level security;

drop policy if exists "reports_auth_insert" on public.merchant_reports;
create policy "reports_auth_insert"
  on public.merchant_reports for insert
  with check (auth.uid() = reporter_id);

drop policy if exists "reports_admin_all" on public.merchant_reports;
create policy "reports_admin_all"
  on public.merchant_reports for all
  using (
    exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- HELPFUL VOTES
alter table public.review_helpful_votes enable row level security;

drop policy if exists "helpful_public_read" on public.review_helpful_votes;
create policy "helpful_public_read" on public.review_helpful_votes for select using (true);

drop policy if exists "helpful_self_insert" on public.review_helpful_votes;
create policy "helpful_self_insert"
  on public.review_helpful_votes for insert
  with check (auth.uid() = user_id);

drop policy if exists "helpful_self_delete" on public.review_helpful_votes;
create policy "helpful_self_delete"
  on public.review_helpful_votes for delete
  using (auth.uid() = user_id);

-- SAVED MERCHANTS
alter table public.saved_merchants enable row level security;

drop policy if exists "saved_self_read" on public.saved_merchants;
create policy "saved_self_read" on public.saved_merchants for select using (auth.uid() = user_id);

drop policy if exists "saved_self_insert" on public.saved_merchants;
create policy "saved_self_insert"
  on public.saved_merchants for insert
  with check (auth.uid() = user_id);

drop policy if exists "saved_self_delete" on public.saved_merchants;
create policy "saved_self_delete"
  on public.saved_merchants for delete
  using (auth.uid() = user_id);

-- MERCHANT VIEWS
alter table public.merchant_views enable row level security;

drop policy if exists "views_anyone_insert" on public.merchant_views;
create policy "views_anyone_insert"
  on public.merchant_views for insert with check (true);

drop policy if exists "views_owner_admin_read" on public.merchant_views;
create policy "views_owner_admin_read"
  on public.merchant_views for select
  using (
    exists (select 1 from public.merchants where id = merchant_views.merchant_id and owner_id = auth.uid())
    or exists (select 1 from public.profiles where id = auth.uid() and is_admin = true)
  );

-- =====================================================
-- SEED DATA · ٢٨ تاجر معروف عالمياً
-- =====================================================

insert into public.merchants (slug, name_ar, name_en, country, country_code, flag, region, types, description_ar, description_en, founded_year, verification_status, verified_at) values
('abdul-samad-al-qurashi', 'عبد الصمد القرشي', 'Abdul Samad Al Qurashi', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['هندي','كمبودي','عطور عود','بخور ومعمول'], 'بيت عود سعودي عريق منذ ١٨٥٢م، يُعدّ من أقدم وأشهر بيوت العود في العالم العربي.', 'A historic Saudi oud house since 1852, one of the oldest and most renowned oud houses in the Arab world.', 1852, 'verified', now()),
('arabian-oud', 'العربية للعود', 'Arabian Oud', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['كمبودي','هندي','عطور عود','دهن العود'], 'أكبر سلسلة محلات عود في العالم، تأسست عام ١٩٨٢. تنتشر فروعها في أكثر من ٣٥ دولة.', 'The world''s largest oud retail chain, founded in 1982. Operates in over 35 countries.', 1982, 'verified', now()),
('al-haramain', 'الحرمين', 'Al Haramain Perfumes', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['عطور عود','دهن العود','بخور ومعمول'], 'بيت عطور وعود سعودي تأسس عام ١٩٧٠. مشهور بدهن العود المباركية والسيوفي.', 'A Saudi perfume and oud house founded in 1970. Known for Mubarakiyah and Suyufi dehn al oud.', 1970, 'verified', now()),
('ajmal-perfumes', 'أجمل للعطور', 'Ajmal Perfumes', 'الإمارات', 'AE', '🇦🇪', 'gulf', ARRAY['هندي','كمبودي','عطور عود','دهن العود'], 'بيت أجمل تأسس عام ١٩٥١ في الهند ثم انتقل للإمارات. أكثر من ٧٠ عاماً في صناعة العود والعطور.', 'Ajmal was founded in 1951 in India and later moved to UAE. Over 70 years in oud and perfumery.', 1951, 'verified', now()),
('rasasi', 'الرصاصي', 'Rasasi', 'الإمارات', 'AE', '🇦🇪', 'gulf', ARRAY['عطور عود','دهن العود'], 'بيت رصاصي العالمي للعطور الفاخرة، يجمع بين العراقة الشرقية والجودة العالمية.', 'Global luxury perfume house combining oriental heritage with world-class quality.', 1979, 'verified', now()),
('hind-al-oud', 'هند العود', 'Hind Al Oud', 'الإمارات', 'AE', '🇦🇪', 'gulf', ARRAY['دهن العود','عطور عود','بخور ومعمول'], 'علامة إماراتية مميزة في عالم العود والعطور الفاخرة، معروفة بجودة الدهن العالية.', 'Distinctive Emirati brand in luxury oud and perfumery, known for high-quality dehn al oud.', null, 'verified', now()),
('anfasic-dokhoon', 'أنفاسك دخون', 'Anfasic Dokhoon', 'الإمارات', 'AE', '🇦🇪', 'gulf', ARRAY['بخور ومعمول','عطور عود'], 'متخصصة في المعمول والبخور الفاخر، حضور قوي في وسائل التواصل الاجتماعي.', 'Specialists in premium ma''moul and bakhoor, strong social media presence.', null, 'pending', null),
('swiss-arabian', 'سويس عربيان', 'Swiss Arabian', 'الإمارات', 'AE', '🇦🇪', 'gulf', ARRAY['عطور عود'], 'بيت عطور تأسس عام ١٩٧٤، يجمع التراث العربي بالحرفية السويسرية.', 'Perfume house founded in 1974, blending Arabian heritage with Swiss craftsmanship.', 1974, 'verified', now()),
('lattafa', 'لطافة', 'Lattafa Perfumes', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['عطور عود'], 'بيت عطور سعودي صاعد بسرعة، اشتهر بالعطور بأسعار مناسبة وتركيبات قوية.', 'Fast-rising Saudi perfume house, known for affordable yet powerful compositions.', null, 'verified', now()),
('amouage', 'أمواج', 'Amouage', 'عُمان', 'OM', '🇴🇲', 'gulf', ARRAY['عطور عود','دهن العود'], 'بيت العطور العُماني الأرقى عالمياً، تأسس عام ١٩٨٣. عطوره من أفخم العطور في العالم.', 'Oman''s finest luxury perfume house, founded in 1983. Among the world''s most prestigious.', 1983, 'verified', now()),
('bawader-kuwait', 'بوادر', 'Bawader', 'الكويت', 'KW', '🇰🇼', 'gulf', ARRAY['دهن العود','بخور ومعمول'], 'بيت عود كويتي معروف بالدهن الكمبودي عالي الجودة وخلطات المعمول الخاصة.', 'Kuwaiti oud house known for high-quality Cambodian dehn and signature ma''moul blends.', null, 'pending', null),
('al-jazeera-perfumes', 'الجزيرة للعطور', 'Al Jazeera Perfumes', 'الكويت', 'KW', '🇰🇼', 'gulf', ARRAY['عطور عود','دهن العود'], 'بيت عطور كويتي تقليدي، يخدم عملاء الكويت منذ عقود.', 'Traditional Kuwaiti perfume house serving customers for decades.', null, 'pending', null),
('surrati', 'سراتي', 'Surrati', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['عطور عود','بخور ومعمول'], 'علامة سعودية معروفة بعطور العود وخلطات البخور الفاخرة.', 'Saudi brand known for oud perfumes and premium bakhoor blends.', null, 'verified', now()),
('asayel', 'أصايل', 'Asayel', 'السعودية', 'SA', '🇸🇦', 'gulf', ARRAY['دهن العود','بخور ومعمول'], 'متخصصون في الدهن والمعمول الفاخر بأسلوب تقليدي.', 'Specialists in traditional premium dehn and ma''moul.', null, 'pending', null),
('ensar-oud', 'إنصار عود', 'Ensar Oud', 'الولايات المتحدة', 'US', '🇺🇸', 'west', ARRAY['هندي','كمبودي','فيتنامي','دهن العود'], 'بيت العود الأرقى في الغرب، أسسه إنصار بيكتوفيتش. مرجع عالمي في دهن العود الأصيل والمقطر تقليدياً.', 'The premier oud house in the West, founded by Ensar Bektovic. Global reference for authentic, traditionally distilled oud oils.', 2007, 'verified', now()),
('agar-aura', 'أجار أورا', 'Agar Aura', 'كندا', 'CA', '🇨🇦', 'west', ARRAY['دهن العود','هندي','كمبودي'], 'بيت عود حرفي يديره طه سيد، معروف بالشفافية في المصدر وتقطير العود الفاخر.', 'Artisan oud house run by Taha Syed, known for source transparency and premium distillation.', null, 'verified', now()),
('sultan-pasha-attars', 'سلطان باشا', 'Sultan Pasha Attars', 'المملكة المتحدة', 'GB', '🇬🇧', 'west', ARRAY['دهن العود','عطور عود'], 'بيت عطور حرفي بريطاني، يصنع تركيبات شرقية فاخرة بأسلوب تقليدي.', 'British artisan perfume house creating premium oriental compositions in the traditional style.', null, 'verified', now()),
('imperial-oud', 'إمبيريال عود', 'Imperial Oud', 'المملكة المتحدة', 'GB', '🇬🇧', 'west', ARRAY['دهن العود','هندي','كمبودي'], 'بيت عود بريطاني متخصص في الدهن النادر من المصادر الأصلية.', 'British oud house specializing in rare oils from original sources.', null, 'verified', now()),
('rising-phoenix-perfumery', 'رايزنق فينيكس', 'Rising Phoenix Perfumery', 'الولايات المتحدة', 'US', '🇺🇸', 'west', ARRAY['دهن العود','عطور عود'], 'بيت عطور حرفي أسسه JK DeLapp، معروف بدهن العود والعطور الطبيعية المركّبة بدقة.', 'Artisan perfume house by JK DeLapp, known for oud oils and meticulously composed natural perfumes.', null, 'verified', now()),
('mellifluence', 'مليفلوينس', 'Mellifluence', 'المملكة المتحدة', 'GB', '🇬🇧', 'west', ARRAY['دهن العود','عطور عود'], 'بيت عطور حرفي يديره عبدالله صوفي، معروف بالمخلطات الشرقية الناعمة.', 'Artisan house by Abdullah Sufi, known for refined oriental mukhallats.', null, 'pending', null),
('areej-le-dore', 'أريج لي دوريه', 'Areej Le Doré', 'تايلاند', 'TH', '🇹🇭', 'asia', ARRAY['دهن العود','عطور عود'], 'بيت عطور حرفي أسسه آدم (Russian Adam)، يصنع تركيبات نادرة بأقل من ٢٠٠ زجاجة لكل إصدار.', 'Artisan perfume house by Russian Adam, creating rare compositions in batches under 200 bottles.', 2017, 'verified', now()),
('feel-oud', 'فيل عود', 'Feel Oud', 'فيتنام', 'VN', '🇻🇳', 'asia', ARRAY['فيتنامي','دهن العود'], 'بيت عود متخصص في تقطير الدهن الفيتنامي مباشرة من المصدر في خانه هوا.', 'Oud house specializing in Vietnamese oil distillation direct from source in Khanh Hoa.', null, 'pending', null),
('oriscent', 'أوريسنت', 'Oriscent', 'عُمان', 'OM', '🇴🇲', 'asia', ARRAY['دهن العود'], 'أحد أوائل بيوت العود الغربية، تديره تريغف هاريس من ظفار. مرجع تاريخي في عالم الدهن.', 'One of the earliest Western oud houses, run by Trygve Harris from Dhofar.', null, 'pending', null),
('habibul-hab', 'حبيب الحب', 'Habibul Hab', 'ماليزيا', 'MY', '🇲🇾', 'asia', ARRAY['دهن العود','إندونيسي'], 'متخصص في الدهن الماليزي والإندونيسي، حضور قوي في مجتمعات هواة العود.', 'Specialist in Malaysian and Indonesian dehn, strong presence in oud enthusiast communities.', null, 'pending', null),
('kannauj-attar-wallahs', 'صنّاع كنوج', 'Kannauj Attar Wallahs', 'الهند', 'IN', '🇮🇳', 'asia', ARRAY['دهن العود','هندي'], 'ورثة الصناعة التقليدية للعطور والدهن في كنوج، الهند. جذور تعود لـ٤٠٠ عام.', 'Heirs to the traditional perfumery and oil-making craft in Kannauj, India. Roots going back 400 years.', null, 'pending', null),
('khanh-hoa-producers', 'منتجو خانه هوا', 'Khanh Hoa Producers', 'فيتنام', 'VN', '🇻🇳', 'asia', ARRAY['فيتنامي','دهن العود'], 'تجمع منتجي العود في إقليم خانه هوا الفيتنامي، أحد أهم مناطق إنتاج العود في العالم.', 'Collective of oud producers in Vietnam''s Khanh Hoa province.', null, 'pending', null),
('pursat-oud', 'بورسات', 'Pursat Oud', 'كمبوديا', 'KH', '🇰🇭', 'asia', ARRAY['كمبودي','دهن العود'], 'منتجو العود من إقليم بورسات الكمبودي، مصدر تاريخي للعود الكمبودي الفاخر.', 'Oud producers from Cambodia''s Pursat province, a historic source of premium Cambodian oud.', null, 'pending', null),
('kalimantan-producers', 'منتجو كاليمانتان', 'Kalimantan Producers', 'إندونيسيا', 'ID', '🇮🇩', 'asia', ARRAY['إندونيسي','دهن العود'], 'منتجو العود من جزيرة كاليمانتان، الموطن الأكبر لشجرة العود الإندونيسية.', 'Oud producers from Kalimantan island, the largest home of Indonesian agarwood trees.', null, 'pending', null)
on conflict (slug) do nothing;

-- =====================================================
-- تم! ٢٨ تاجر تمت إضافتهم
-- =====================================================
