// صفحة التاجر الفردية — مع SSR و Schema markup كامل + نموذج التقييم
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import ReviewCard from "@/components/ReviewCard";
import ReviewForm from "@/components/ReviewForm";
import type { Merchant, Review } from "@/lib/supabase/types";

export const revalidate = 60;

export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const supabase = createClient();
  const { data: merchant } = await supabase.from("merchants").select("*").eq("slug", params.slug).single();
  if (!merchant) return { title: "تاجر غير موجود" };
  const title = `${merchant.name_ar} · ${merchant.country}`;
  const description = merchant.description_ar
    || `استعرض تقييمات ${merchant.name_ar} من ${merchant.country}، تخصصاته في ${merchant.types?.join("، ")}، وتجارب العملاء الحقيقية.`;
  return {
    title, description,
    alternates: { canonical: `/${merchant.slug}` },
    openGraph: { title: `${merchant.name_ar} · Oud Index`, description, url: `/${merchant.slug}` },
  };
}

export default async function MerchantPage({ params }: { params: { slug: string } }) {
  const supabase = createClient();

  const { data: merchant } = await supabase.from("merchants").select("*").eq("slug", params.slug).single();
  if (!merchant) notFound();

  const { data: { user } } = await supabase.auth.getUser();

  let reviewerName = "";
  let userHasReviewed = false;
  if (user) {
    const { data: profile } = await supabase.from("profiles").select("name, full_name").eq("id", user.id).single();
    reviewerName = (profile as any)?.full_name || (profile as any)?.name || user.email?.split("@")[0] || "";
    const { data: existingReview } = await supabase
      .from("reviews")
      .select("id")
      .eq("merchant_id", merchant.id)
      .eq("reviewer_id", user.id)
      .maybeSingle();
    userHasReviewed = !!existingReview;
  }

  const { data: reviewsData } = await supabase
    .from("reviews")
    .select("*")
    .eq("merchant_id", merchant.id)
    .eq("is_hidden", false)
    .order("created_at", { ascending: false });

  const reviews = (reviewsData ?? []) as Review[];
  const m = merchant as Merchant;

  const schemaOrg = {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    name: m.name_ar,
    alternateName: m.name_en || undefined,
    description: m.description_ar,
    url: `${process.env.NEXT_PUBLIC_SITE_URL || "https://oudindex.com"}/directory/${m.slug}`,
    address: {
      "@type": "PostalAddress",
      addressCountry: m.country_code || m.country,
      addressLocality: m.city || undefined,
    },
    aggregateRating: m.reviews_count > 0 ? {
      "@type": "AggregateRating",
      ratingValue: m.average_rating,
      reviewCount: m.reviews_count,
      bestRating: 5, worstRating: 1,
    } : undefined,
    review: reviews.slice(0, 10).map((r) => ({
      "@type": "Review",
      author: { "@type": "Person", name: r.reviewer_name },
      datePublished: r.created_at,
      reviewBody: r.text,
      reviewRating: { "@type": "Rating", ratingValue: r.rating, bestRating: 5, worstRating: 1 },
    })),
    foundingDate: m.founded_year ? `${m.founded_year}-01-01` : undefined,
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(schemaOrg) }} />

      <section className="merchant-hero">
        <div className="container">
          <div style={{ marginBottom: 16 }}>
            <Link href="/" style={{ color: "var(--dim)", fontSize: 12, letterSpacing: "0.1em" }}>← دليل التجار</Link>
          </div>

          <h1>{m.name_ar}</h1>
          {m.name_en && <div className="en-name">{m.name_en}</div>}

          <div className="meta-row">
            <span style={{ fontSize: 18 }}>{m.flag}</span>
            <span>{m.country}</span>
            {m.verification_status === "verified" ? (
              <span className="badge verified">VERIFIED MERCHANT</span>
            ) : (
              <span className="badge unverified">PENDING VERIFICATION</span>
            )}
            {m.founded_year && <span className="mono" style={{ color: "var(--dim)", fontSize: 12 }}>EST. {m.founded_year}</span>}
          </div>

          <div className="merchant-stats">
            <div className="stat">
              <div className="label">Rating</div>
              <div className="val mono" style={{ color: "var(--gold2)" }}>
                {m.average_rating ? Number(m.average_rating).toFixed(1) : "—"}{" "}
                <span className="stars" style={{ fontSize: 14 }}>
                  {[1,2,3,4,5].map(i => (
                    <span key={i} className={i <= Math.round(m.average_rating) ? "" : "empty"}>★</span>
                  ))}
                </span>
              </div>
            </div>
            <div className="stat">
              <div className="label">Reviews</div>
              <div className="val mono">{String(m.reviews_count).padStart(2, "0")}</div>
            </div>
            <div className="stat">
              <div className="label">Specialty</div>
              <div className="val" style={{ fontSize: 13 }}>{(m.types || []).join(" · ")}</div>
            </div>
            {m.founded_year && (
              <div className="stat">
                <div className="label">Founded</div>
                <div className="val mono">{m.founded_year}</div>
              </div>
            )}
          </div>

          {m.description_ar && (
            <p style={{ color: "var(--cream)", fontSize: 14, lineHeight: 1.85, maxWidth: 720, marginTop: 16 }}>
              {m.description_ar}
            </p>
          )}

          {(m.website || m.instagram || m.whatsapp) && (
            <div style={{ display: "flex", gap: 10, marginTop: 24, flexWrap: "wrap" }}>
              {m.website && <a href={m.website} target="_blank" rel="noopener nofollow" className="btn btn-ghost">الموقع</a>}
              {m.instagram && <a href={`https://instagram.com/${m.instagram.replace(/^@/, "")}`} target="_blank" rel="noopener nofollow" className="btn btn-ghost">إنستقرام</a>}
              {m.whatsapp && <a href={`https://wa.me/${m.whatsapp.replace(/\D/g, "")}`} target="_blank" rel="noopener nofollow" className="btn btn-ghost">واتساب</a>}
            </div>
          )}
        </div>
      </section>

      <section className="container" style={{ paddingTop: 40 }}>
        {!user ? (
          <div className="form-section">
            <h3>Write A Review · اكتبي تجربتكِ</h3>
            <p style={{ color: "var(--dim)", fontSize: 13, marginBottom: 18 }}>
              شاركي تجربتكِ الحقيقية مع {m.name_ar}. تقييمكِ يساعد عملاء آخرين ويبني سمعة المنصة.
            </p>
            <Link href={`/login?next=/${m.slug}`} className="btn btn-solid" style={{ display: "inline-block", padding: "12px 30px" }}>
              سجّلي دخولكِ لكتابة تقييم
            </Link>
          </div>
        ) : userHasReviewed ? (
          <div className="form-section" style={{ borderColor: "rgba(196,136,42,0.4)" }}>
            <h3>تم تقييم هذا التاجر مسبقاً</h3>
            <p style={{ color: "var(--dim)", fontSize: 13 }}>
              يمكنكِ تعديل تقييمكِ من <Link href="/dashboard" style={{ color: "var(--gold2)" }}>صفحة حسابكِ</Link> خلال ٣٠ يوماً من تاريخ النشر.
            </p>
          </div>
        ) : (
          <ReviewForm merchantId={m.id} reviewerId={user.id} reviewerName={reviewerName} />
        )}

        <div className="sec-head">
          <h2>Reviews</h2>
          <div className="count">{String(reviews.length).padStart(2, "0")} TOTAL</div>
        </div>

        {reviews.length === 0 ? (
          <div className="empty" style={{ border: "0.5px solid var(--b)" }}>
            <div className="empty-icon">∅</div>
            <div>لا توجد تقييمات بعد · كوني أول من تكتب تجربتها</div>
          </div>
        ) : (
          <div>
            {reviews.map((r) => <ReviewCard key={r.id} review={r} />)}
          </div>
        )}
      </section>
    </>
  );
}
