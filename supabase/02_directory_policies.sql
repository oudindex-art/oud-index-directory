-- =====================================================
-- Row Level Security Policies (Adapted)
-- متوافق مع is_admin الموجود (بدل role enum)
-- =====================================================

-- ============== ENABLE RLS ==============
alter table public.merchants enable row level security;
alter table public.reviews enable row level security;
alter table public.verification_requests enable row level security;
alter table public.merchant_reports enable row level security;
alter table public.helpful_votes enable row level security;
alter table public.merchant_views enable row level security;
alter table public.saved_merchants enable row level security;

-- ============== HELPER: is_admin check ==============
create or replace function public.is_admin_user()
returns boolean as $$
  select coalesce((select is_admin from public.profiles where id = auth.uid()), false);
$$ language sql security definer stable;

-- ============== MERCHANTS ==============
drop policy if exists "merchants viewable by all" on public.merchants;
create policy "merchants viewable by all" on public.merchants for select using (true);

drop policy if exists "auth users can create merchants" on public.merchants;
create policy "auth users can create merchants" on public.merchants for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "merchant owner can update" on public.merchants;
create policy "merchant owner can update" on public.merchants for update
  using (auth.uid() = owner_id);

drop policy if exists "admins can update any merchant" on public.merchants;
create policy "admins can update any merchant" on public.merchants for update
  using (public.is_admin_user());

drop policy if exists "admins can delete merchants" on public.merchants;
create policy "admins can delete merchants" on public.merchants for delete
  using (public.is_admin_user());

-- ============== REVIEWS ==============
drop policy if exists "visible reviews readable" on public.reviews;
create policy "visible reviews readable" on public.reviews for select
  using (is_hidden = false or public.is_admin_user());

drop policy if exists "auth users can write reviews" on public.reviews;
create policy "auth users can write reviews" on public.reviews for insert
  with check (auth.uid() = reviewer_id);

drop policy if exists "users update own recent reviews" on public.reviews;
create policy "users update own recent reviews" on public.reviews for update
  using (auth.uid() = reviewer_id and created_at > now() - interval '30 days');

drop policy if exists "merchant can reply" on public.reviews;
create policy "merchant can reply" on public.reviews for update
  using (exists (select 1 from public.merchants where id = reviews.merchant_id and owner_id = auth.uid()));

drop policy if exists "admins update any review" on public.reviews;
create policy "admins update any review" on public.reviews for update
  using (public.is_admin_user());

drop policy if exists "admins delete reviews" on public.reviews;
create policy "admins delete reviews" on public.reviews for delete
  using (public.is_admin_user());

-- ============== VERIFICATION REQUESTS ==============
drop policy if exists "see own verification" on public.verification_requests;
create policy "see own verification" on public.verification_requests for select
  using (submitted_by = auth.uid() or public.is_admin_user());

drop policy if exists "submit verification" on public.verification_requests;
create policy "submit verification" on public.verification_requests for insert
  with check (auth.uid() = submitted_by);

drop policy if exists "admins review verification" on public.verification_requests;
create policy "admins review verification" on public.verification_requests for update
  using (public.is_admin_user());

-- ============== MERCHANT REPORTS ==============
drop policy if exists "auth users can report" on public.merchant_reports;
create policy "auth users can report" on public.merchant_reports for insert
  with check (auth.uid() = reporter_id);

drop policy if exists "admins manage reports" on public.merchant_reports;
create policy "admins manage reports" on public.merchant_reports for all
  using (public.is_admin_user());

-- ============== HELPFUL VOTES ==============
drop policy if exists "all read helpful votes" on public.helpful_votes;
create policy "all read helpful votes" on public.helpful_votes for select using (true);

drop policy if exists "users vote helpful" on public.helpful_votes;
create policy "users vote helpful" on public.helpful_votes for insert
  with check (auth.uid() = user_id);

drop policy if exists "users remove own vote" on public.helpful_votes;
create policy "users remove own vote" on public.helpful_votes for delete
  using (auth.uid() = user_id);

-- ============== SAVED MERCHANTS ==============
drop policy if exists "users see own saved" on public.saved_merchants;
create policy "users see own saved" on public.saved_merchants for select
  using (auth.uid() = user_id);

drop policy if exists "users save merchants" on public.saved_merchants;
create policy "users save merchants" on public.saved_merchants for insert
  with check (auth.uid() = user_id);

drop policy if exists "users unsave" on public.saved_merchants;
create policy "users unsave" on public.saved_merchants for delete
  using (auth.uid() = user_id);

-- ============== MERCHANT VIEWS ==============
drop policy if exists "anyone log views" on public.merchant_views;
create policy "anyone log views" on public.merchant_views for insert with check (true);

drop policy if exists "merchant sees own views" on public.merchant_views;
create policy "merchant sees own views" on public.merchant_views for select
  using (
    exists (select 1 from public.merchants where id = merchant_views.merchant_id and owner_id = auth.uid())
    or public.is_admin_user()
  );

-- ============== التحقق ==============
select tablename, count(*) as policy_count
from pg_policies
where schemaname = 'public'
  and tablename in ('merchants', 'reviews', 'verification_requests', 'merchant_reports', 'helpful_votes', 'saved_merchants', 'merchant_views')
group by tablename
order by tablename;
