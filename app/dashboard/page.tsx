// لوحة تحكم المستخدم — تعرض إما واجهة العميل أو التاجر
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login?next=/dashboard");

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  const { data: myMerchants } = await supabase
    .from("merchants")
    .select("id, slug, name_ar, country, flag, verification_status, reviews_count, average_rating")
    .eq("owner_id", user.id);

  const { data: myReviews } = await supabase
    .from("reviews")
    .select("id, rating, text, created_at, merchant:merchants(slug, name_ar, flag)")
    .eq("reviewer_id", user.id)
    .order("created_at", { ascending: false })
    .limit(20);

  const isMerchant = (profile as any)?.is_merchant || (myMerchants && myMerchants.length > 0);
  const displayName = (profile as any)?.full_name || (profile as any)?.name || user.email?.split("@")[0];

  return (
    <>
      <section className="merchant-hero">
        <div className="container">
          <div style={{ marginBottom: 12, color: "var(--dim)", fontSize: 12, letterSpacing: "0.15em", textTransform: "uppercase" }}>
            Dashboard · لوحة التحكم
          </div>
          <h1>أهلاً، {displayName}</h1>
          <div className="meta-row">
            <span style={{ color: "var(--dim)", fontSize: 13 }}>{user.email}</span>
            {isMerchant && <span className="badge gold">MERCHANT</span>}
            {(profile as any)?.is_admin && <span className="badge verified">ADMIN</span>}
          </div>
        </div>
      </section>

      <section className="container" style={{ paddingTop: 40 }}>
        {/* قسم المتاجر */}
        <div className="sec-head">
          <h2>{isMerchant ? "متاجري" : "كن تاجراً"}</h2>
        </div>

        {(myMerchants && myMerchants.length > 0) ? (
          <div className="grid">
            {myMerchants.map((m: any) => (
              <Link key={m.id} href={`/${m.slug}`} className="card">
                <div style={{ fontSize: 18, fontWeight: 700, color: "var(--gold2)", marginBottom: 8 }}>{m.name_ar}</div>
                <div className="card-meta">
                  <span>{m.flag}</span>
                  <span>{m.country}</span>
                  {m.verification_status === "verified" ? (
                    <span className="badge verified">VERIFIED</span>
                  ) : (
                    <span className="badge unverified">PENDING</span>
                  )}
                </div>
                <div className="rating">
                  <span className="rating-num">{m.average_rating ? Number(m.average_rating).toFixed(1) : "—"}</span>
                  <span className="rating-count">{String(m.reviews_count).padStart(2, "0")} REVIEWS</span>
                </div>
              </Link>
            ))}
          </div>
        ) : (
          <div className="form-section" style={{ textAlign: "center", padding: 30 }}>
            <h3 style={{ marginBottom: 12 }}>لا يوجد متجر مسجّل لكِ</h3>
            <p style={{ color: "var(--dim)", fontSize: 13, marginBottom: 18 }}>
              هل أنتِ تاجرة عود؟ أضيفي متجركِ مجاناً وابدئي في استقبال التقييمات والعملاء.
            </p>
            <Link href="/dashboard/add-merchant" className="btn btn-solid">
              + أضيفي متجركِ
            </Link>
          </div>
        )}

        {/* قسم تقييماتي */}
        <div className="sec-head" style={{ marginTop: 30 }}>
          <h2>تقييماتي</h2>
          <div className="count">{(myReviews?.length || 0).toString().padStart(2, "0")} TOTAL</div>
        </div>

        {(myReviews && myReviews.length > 0) ? (
          <div>
            {myReviews.map((r: any) => (
              <div key={r.id} className="review">
                <div className="review-head">
                  <div className="review-meta">
                    <div className="review-name">
                      <Link href={`/${r.merchant?.slug}`} style={{ color: "var(--cream)" }}>
                        {r.merchant?.flag} {r.merchant?.name_ar}
                      </Link>
                    </div>
                    <div className="review-date">
                      {new Date(r.created_at).toLocaleDateString("ar-SA")}
                    </div>
                  </div>
                </div>
                <div className="review-stars">
                  {[1,2,3,4,5].map(i => <span key={i} className={i <= r.rating ? "" : "empty"}>★</span>)}
                </div>
                <div className="review-text">{r.text}</div>
              </div>
            ))}
          </div>
        ) : (
          <div className="empty" style={{ border: "0.5px solid var(--b)" }}>
            <div className="empty-icon">∅</div>
            <div>لم تكتبي أي تقييم بعد</div>
            <Link href="/" className="btn btn-ghost" style={{ marginTop: 14, display: "inline-block" }}>
              تصفّحي الدليل
            </Link>
          </div>
        )}
      </section>
    </>
  );
}
