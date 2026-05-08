import type { Review } from "@/lib/supabase/types";
import { initialsOf, timeAgo } from "@/lib/utils";

export default function ReviewCard({ review }: { review: Review }) {
  return (
    <div className="review">
      <div className="review-head">
        <div className="review-avatar">{initialsOf(review.reviewer_name)}</div>
        <div className="review-meta">
          <div className="review-name">
            <span>{review.reviewer_name}</span>
            {review.is_verified_buyer ? (
              <span className="badge verified">VERIFIED BUYER</span>
            ) : (
              <span className="badge unverified">UNVERIFIED</span>
            )}
          </div>
          <div className="review-date">{timeAgo(review.created_at)}</div>
        </div>
      </div>

      <div className="review-stars">
        {[1, 2, 3, 4, 5].map((i) => (
          <span key={i} className={i <= review.rating ? "" : "empty"}>★</span>
        ))}
      </div>

      <div className="review-text">{review.text}</div>

      {review.merchant_reply && (
        <div className="review-merchant-reply">
          <div className="label">رد المتجر</div>
          {review.merchant_reply}
        </div>
      )}
    </div>
  );
}
