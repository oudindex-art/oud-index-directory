import Link from "next/link";
import type { Merchant } from "@/lib/supabase/types";
import { initialsOf } from "@/lib/utils";

export default function MerchantCard({ merchant }: { merchant: Merchant }) {
  const r = merchant.average_rating || 0;
  const cnt = merchant.reviews_count || 0;
  const isVerified = merchant.verification_status === "verified";

  return (
    <Link href={`/directory/${merchant.slug}`} className="card">
      <div className="card-top">
        <div className="avatar">{initialsOf(merchant.name_en || merchant.name_ar)}</div>
        <div className="card-id-wrap">
          <div className="card-name">{merchant.name_ar}</div>
          <div className="card-meta">
            <span className="flag">{merchant.flag || ""}</span>
            <span>{merchant.country}</span>
            {isVerified ? (
              <span className="badge verified">VERIFIED</span>
            ) : (
              <span className="badge unverified">PENDING</span>
            )}
          </div>
        </div>
      </div>

      <div className="rating">
        <span className="rating-num">{r ? r.toFixed(1) : "—"}</span>
        <span className="stars">
          {[1, 2, 3, 4, 5].map((i) => (
            <span key={i} className={i <= Math.round(r) ? "" : "empty"}>★</span>
          ))}
        </span>
        <span className="rating-count">{String(cnt).padStart(2, "0")} REVIEWS</span>
      </div>

      <div className="tags">
        {(merchant.types || []).slice(0, 3).map((t) => (
          <span key={t} className="tag">{t}</span>
        ))}
      </div>

      {merchant.description_ar && (
        <div className="card-desc">{merchant.description_ar}</div>
      )}
    </Link>
  );
}
