// صفحة دليل التجار — Server Component مع SSR كامل
import type { Metadata } from "next";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import MerchantCard from "@/components/MerchantCard";
import type { Merchant, MerchantRegion } from "@/lib/supabase/types";

export const metadata: Metadata = {
  title: "دليل التجار · Merchants Directory",
  description: "الدليل العالمي لتجار العود. تقييمات حقيقية من عملاء حقيقيين. ابحث، قارن، واختر بثقة من بين أبرز بيوت العود في العالم.",
  alternates: { canonical: "/" },
  openGraph: {
    title: "دليل التجار العالمي · Oud Index",
    description: "تقييمات حقيقية من عملاء حقيقيين لأبرز بيوت العود في العالم.",
    url: "/",
  },
};

const REGIONS: { value: MerchantRegion | "all"; label: string }[] = [
  { value: "all", label: "الكل" },
  { value: "gulf", label: "الخليج" },
  { value: "asia", label: "آسيا (المنشأ)" },
  { value: "west", label: "الغرب" },
];

const TYPES = ["الكل","هندي","كمبودي","فيتنامي","إندونيسي","دهن العود","بخور ومعمول","عطور عود"];

export const revalidate = 60; // إعادة التحميل كل دقيقة (ISR)

export default async function DirectoryPage({
  searchParams,
}: {
  searchParams: { region?: string; type?: string; q?: string };
}) {
  const supabase = createClient();

  // بناء الاستعلام
  let query = supabase
    .from("merchants")
    .select("*")
    .order("verification_status", { ascending: false }) // verified أولاً
    .order("average_rating", { ascending: false })
    .order("reviews_count", { ascending: false });

  if (searchParams.region && searchParams.region !== "all") {
    query = query.eq("region", searchParams.region);
  }
  if (searchParams.type && searchParams.type !== "الكل") {
    query = query.contains("types", [searchParams.type]);
  }
  if (searchParams.q) {
    query = query.textSearch("search_vector", searchParams.q, { type: "websearch" });
  }

  const { data: merchants, error } = await query;

  if (error) console.error("Directory error:", error.message);

  const list = (merchants ?? []) as Merchant[];

  // إحصائيات
  const verifiedCount = list.filter((m) => m.verification_status === "verified").length;
  const totalReviews = list.reduce((s, m) => s + (m.reviews_count || 0), 0);
  const countries = new Set(list.map((m) => m.country)).size;

  return (
    <>
      {/* HERO */}
      <section className="hero">
        <div className="container">
          <div className="hero-eyebrow">Merchant Directory · دليل التجار</div>
          <h1>The Global <span className="gold">Oud Merchants</span> Directory</h1>
          <div className="ar-title">الدليل العالمي لتجار العود</div>
          <p className="lead">
            تقييمات حقيقية من عملاء حقيقيين. ابحث، قارن، واختر بثقة من بين أبرز بيوت العود في العالم —
            من الخليج إلى الدول المنتجة في آسيا.
          </p>

          <form className="search-wrap" action="/" method="get">
            <input name="q" defaultValue={searchParams.q || ""} placeholder="ابحث باسم التاجر، الدولة، أو نوع العود..." />
            {searchParams.region && <input type="hidden" name="region" value={searchParams.region} />}
            {searchParams.type && <input type="hidden" name="type" value={searchParams.type} />}
            <button type="submit">بحث</button>
          </form>

          <div className="hero-stats">
            <div>
              <div className="stat-num">{String(list.length).padStart(2, "0")}</div>
              <div className="stat-label">Merchants</div>
            </div>
            <div>
              <div className="stat-num">{totalReviews}</div>
              <div className="stat-label">Reviews</div>
            </div>
            <div>
              <div className="stat-num">{countries}</div>
              <div className="stat-label">Countries</div>
            </div>
            <div>
              <div className="stat-num">{verifiedCount}</div>
              <div className="stat-label">Verified</div>
            </div>
          </div>
        </div>
      </section>

      {/* FILTERS */}
      <section className="container">
        <div className="filter-bar">
          <div className="filter-row">
            <span className="filter-label">المنطقة</span>
            {REGIONS.map((r) => {
              const active = (searchParams.region || "all") === r.value;
              const params = new URLSearchParams();
              if (r.value !== "all") params.set("region", r.value);
              if (searchParams.type) params.set("type", searchParams.type);
              if (searchParams.q) params.set("q", searchParams.q);
              return (
                <Link
                  key={r.value}
                  href={`/${params.toString() ? "?" + params : ""}`}
                  className={`chip ${active ? "active" : ""}`}
                >
                  {r.label}
                </Link>
              );
            })}
          </div>
          <div className="filter-row">
            <span className="filter-label">النوع</span>
            {TYPES.map((t) => {
              const current = searchParams.type || "الكل";
              const active = current === t;
              const params = new URLSearchParams();
              if (t !== "الكل") params.set("type", t);
              if (searchParams.region) params.set("region", searchParams.region);
              if (searchParams.q) params.set("q", searchParams.q);
              return (
                <Link
                  key={t}
                  href={`/${params.toString() ? "?" + params : ""}`}
                  className={`chip ${active ? "active" : ""}`}
                >
                  {t}
                </Link>
              );
            })}
          </div>
        </div>

        {/* GRID */}
        <div className="sec-head">
          <h2>Merchants</h2>
          <div className="count">{String(list.length).padStart(2, "0")} RESULTS</div>
        </div>

        {list.length === 0 ? (
          <div className="grid">
            <div className="empty">
              <div className="empty-icon">∅</div>
              <div>لا توجد نتائج تطابق البحث</div>
            </div>
          </div>
        ) : (
          <div className="grid">
            {list.map((m) => <MerchantCard key={m.id} merchant={m} />)}
          </div>
        )}
      </section>

      {/* CTA */}
      <section className="cta-band" style={{ marginTop: 60 }}>
        <div className="container">
          <div className="eyebrow">Suggest a Merchant</div>
          <h2>Help us grow the directory — Free</h2>
          <div className="ar-h2">ساعدنا في بناء الدليل — مجاناً</div>
          <p>هل تعرف تاجر عود يستحق الإدراج؟ أو هل أنت صاحب متجر تريد إضافته؟ أرسل المعلومات وسنُراجعها ونتحقق منها قبل النشر.</p>
          <a href="/suggest-merchant" className="btn btn-solid">اقترح / أضف متجرك</a>
          <div className="cta-perks">
            <div className="perk">إدراج مجاني</div>
            <div className="perk">دليل مستقل</div>
            <div className="perk">مراجعة قبل النشر</div>
            <div className="perk">شارة موثّق</div>
          </div>
        </div>
      </section>
    </>
  );
}
