"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

interface Props {
  merchantId: string;
  reviewerId: string;
  reviewerName: string;
}

export default function ReviewForm({ merchantId, reviewerId, reviewerName }: Props) {
  const router = useRouter();
  const [rating, setRating] = useState(0);
  const [hover, setHover] = useState(0);
  const [text, setText] = useState("");
  const [verified, setVerified] = useState(false);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const supabase = createClient();

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);

    if (rating === 0) {
      setErr("اختر عدد النجوم أولاً");
      return;
    }
    if (text.trim().length < 10) {
      setErr("التقييم يجب أن يكون ١٠ أحرف على الأقل");
      return;
    }

    setLoading(true);
    const { error } = await supabase.from("reviews").insert({
      merchant_id: merchantId,
      reviewer_id: reviewerId,
      reviewer_name: reviewerName,
      rating,
      text: text.trim(),
      is_verified_buyer: verified,
    });
    setLoading(false);

    if (error) {
      if (error.code === "23505") {
        setErr("لقد قيّمت هذا التاجر مسبقاً. يمكنك تعديل تقييمك من حسابك.");
      } else {
        setErr(error.message);
      }
      return;
    }

    setSuccess(true);
    setRating(0);
    setText("");
    setVerified(false);
    router.refresh();
  }

  if (success) {
    return (
      <div className="form-section" style={{ borderColor: "rgba(76,175,80,0.4)", background: "rgba(76,175,80,0.06)" }}>
        <div style={{ color: "var(--up)", fontSize: 14, marginBottom: 8 }}>✓ شكراً لمشاركة تجربتك</div>
        <p style={{ color: "var(--cream)", fontSize: 13, lineHeight: 1.7 }}>
          تقييمك نُشر بنجاح. أنت تساعد مجتمع عشاق العود على اختيار أفضل التجار.
        </p>
        <button
          onClick={() => setSuccess(false)}
          className="btn btn-ghost"
          style={{ marginTop: 14 }}
        >
          كتابة تقييم آخر لتاجر مختلف
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={submit} className="form-section">
      <h3>اكتب تجربتك</h3>

      {err && (
        <div style={{ background: "rgba(224,112,112,0.1)", border: "0.5px solid var(--down)", color: "var(--down)", padding: "10px 14px", marginBottom: 14, fontSize: 13 }}>
          {err}
        </div>
      )}

      <div className="field">
        <label>تقييمك (من ٥)</label>
        <div className="star-input" data-rating={rating}>
          {[1, 2, 3, 4, 5].map((i) => (
            <span
              key={i}
              className={i <= (hover || rating) ? "on" : ""}
              onMouseEnter={() => setHover(i)}
              onMouseLeave={() => setHover(0)}
              onClick={() => setRating(i)}
              style={{ cursor: "pointer", color: i <= (hover || rating) ? "var(--gold)" : "var(--b)", transition: "color 0.15s" }}
            >
              ★
            </span>
          ))}
        </div>
      </div>

      <div className="field">
        <label>تجربتك مع التاجر</label>
        <textarea
          required
          minLength={10}
          maxLength={2000}
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="اكتب تجربتك بصدق — ما أعجبك، ما لم يعجبك، الجودة، السعر، الخدمة..."
        />
        <div style={{ fontSize: 11, color: "var(--dimmer)", marginTop: 6, textAlign: "left" }}>{text.length} / 2000</div>
      </div>

      <div className="field">
        <label className="checkbox-row" style={{ cursor: "pointer" }}>
          <input
            type="checkbox"
            checked={verified}
            onChange={(e) => setVerified(e.target.checked)}
          />
          <span>اشتريت من هذا التاجر فعلاً (سيمنحك شارة "عميل موثّق")</span>
        </label>
      </div>

      <button type="submit" className="submit-btn" disabled={loading}>
        {loading ? "جاري النشر..." : "نشر التقييم"}
      </button>

      <p className="form-foot">
        يمكنك تعديل تقييمك خلال ٣٠ يوماً من الآن. التاجر يستطيع الرد عليه لكن لا يستطيع حذفه.
      </p>
    </form>
  );
}
