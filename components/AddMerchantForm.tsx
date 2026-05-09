"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

const TYPES = ["هندي", "كمبودي", "فيتنامي", "إندونيسي", "دهن العود", "بخور ومعمول", "عطور عود"];
const COUNTRIES = [
  { name: "السعودية", code: "SA", flag: "🇸🇦", region: "gulf" },
  { name: "الإمارات", code: "AE", flag: "🇦🇪", region: "gulf" },
  { name: "الكويت", code: "KW", flag: "🇰🇼", region: "gulf" },
  { name: "قطر", code: "QA", flag: "🇶🇦", region: "gulf" },
  { name: "عُمان", code: "OM", flag: "🇴🇲", region: "gulf" },
  { name: "البحرين", code: "BH", flag: "🇧🇭", region: "gulf" },
  { name: "اليمن", code: "YE", flag: "🇾🇪", region: "gulf" },
  { name: "الهند", code: "IN", flag: "🇮🇳", region: "asia" },
  { name: "كمبوديا", code: "KH", flag: "🇰🇭", region: "asia" },
  { name: "فيتنام", code: "VN", flag: "🇻🇳", region: "asia" },
  { name: "إندونيسيا", code: "ID", flag: "🇮🇩", region: "asia" },
  { name: "ماليزيا", code: "MY", flag: "🇲🇾", region: "asia" },
  { name: "تايلاند", code: "TH", flag: "🇹🇭", region: "asia" },
  { name: "الولايات المتحدة", code: "US", flag: "🇺🇸", region: "west" },
  { name: "المملكة المتحدة", code: "GB", flag: "🇬🇧", region: "west" },
  { name: "كندا", code: "CA", flag: "🇨🇦", region: "west" },
  { name: "فرنسا", code: "FR", flag: "🇫🇷", region: "west" },
];

function slugify(t: string) {
  return t.toLowerCase().trim().replace(/[^a-z0-9\s-]/g, "").replace(/\s+/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
}

export default function AddMerchantForm({ userId }: { userId: string }) {
  const router = useRouter();
  const [nameAr, setNameAr] = useState("");
  const [nameEn, setNameEn] = useState("");
  const [countryIdx, setCountryIdx] = useState(0);
  const [city, setCity] = useState("");
  const [foundedYear, setFoundedYear] = useState("");
  const [types, setTypes] = useState<string[]>([]);
  const [descAr, setDescAr] = useState("");
  const [website, setWebsite] = useState("");
  const [instagram, setInstagram] = useState("");
  const [whatsapp, setWhatsapp] = useState("");
  const [phone, setPhone] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const supabase = createClient();
  const country = COUNTRIES[countryIdx];

  function toggleType(t: string) {
    setTypes((s) => s.includes(t) ? s.filter((x) => x !== t) : [...s, t]);
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);

    if (types.length === 0) {
      setErr("اختر تخصصاً واحداً على الأقل");
      return;
    }

    setLoading(true);
    const slug = slugify(nameEn || nameAr) || `merchant-${Date.now()}`;

    const { data, error } = await supabase.from("merchants").insert({
      slug,
      name_ar: nameAr,
      name_en: nameEn || null,
      country: country.name,
      country_code: country.code,
      flag: country.flag,
      region: country.region,
      city: city || null,
      founded_year: foundedYear ? parseInt(foundedYear) : null,
      types,
      description_ar: descAr,
      website: website || null,
      instagram: instagram || null,
      whatsapp: whatsapp || null,
      phone: phone || null,
      owner_id: userId,
      claimed_at: new Date().toISOString(),
    }).select("slug").single();

    setLoading(false);

    if (error) {
      setErr(error.message);
      return;
    }

    // Mark profile as merchant
    await supabase.from("profiles").update({ is_merchant: true }).eq("id", userId);
    router.push(`/${data.slug}`);
    router.refresh();
  }

  return (
    <form onSubmit={submit} className="form-section">
      <h3>معلومات المتجر</h3>

      {err && (
        <div style={{ background: "rgba(224,112,112,0.1)", border: "0.5px solid var(--down)", color: "var(--down)", padding: "10px 14px", marginBottom: 14, fontSize: 13 }}>
          {err}
        </div>
      )}

      <div className="field">
        <label>اسم المتجر بالعربي *</label>
        <input type="text" required value={nameAr} onChange={(e) => setNameAr(e.target.value)} placeholder="مثال: عود الأصايل" />
      </div>

      <div className="field">
        <label>اسم المتجر بالإنجليزي (اختياري — للSEO)</label>
        <input type="text" value={nameEn} onChange={(e) => setNameEn(e.target.value)} placeholder="Oud Al Asayel" dir="ltr" style={{ textAlign: "left" }} />
      </div>

      <div className="field">
        <label>الدولة *</label>
        <select required value={countryIdx} onChange={(e) => setCountryIdx(parseInt(e.target.value))}>
          {COUNTRIES.map((c, i) => (
            <option key={c.code} value={i}>{c.flag} {c.name}</option>
          ))}
        </select>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <div className="field">
          <label>المدينة (اختياري)</label>
          <input type="text" value={city} onChange={(e) => setCity(e.target.value)} placeholder="الرياض" />
        </div>
        <div className="field">
          <label>سنة التأسيس (اختياري)</label>
          <input type="number" min="1800" max="2026" value={foundedYear} onChange={(e) => setFoundedYear(e.target.value)} placeholder="1995" />
        </div>
      </div>

      <div className="field">
        <label>التخصص (اختر كل ما ينطبق) *</label>
        <div className="types-grid" style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
          {TYPES.map((t) => (
            <label
              key={t}
              style={{
                padding: "6px 12px",
                border: "0.5px solid",
                borderColor: types.includes(t) ? "var(--gold)" : "var(--b)",
                color: types.includes(t) ? "var(--gold2)" : "var(--dim)",
                background: types.includes(t) ? "rgba(196,136,42,0.1)" : "transparent",
                fontSize: 12,
                cursor: "pointer",
                userSelect: "none",
              }}
            >
              <input type="checkbox" checked={types.includes(t)} onChange={() => toggleType(t)} style={{ display: "none" }} />
              {t}
            </label>
          ))}
        </div>
      </div>

      <div className="field">
        <label>وصف قصير عن متجرك *</label>
        <textarea required value={descAr} onChange={(e) => setDescAr(e.target.value)} placeholder="ما الذي يميّز متجرك؟ منذ متى وأنت في تجارة العود؟" minLength={20} maxLength={500} />
      </div>

      <div className="field">
        <label>الموقع الإلكتروني (اختياري)</label>
        <input type="url" value={website} onChange={(e) => setWebsite(e.target.value)} placeholder="https://..." dir="ltr" style={{ textAlign: "left" }} />
      </div>

      <div className="field">
        <label>إنستقرام (بدون @)</label>
        <input type="text" value={instagram} onChange={(e) => setInstagram(e.target.value)} placeholder="oudshop" dir="ltr" style={{ textAlign: "left" }} />
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
        <div className="field">
          <label>واتساب (اختياري)</label>
          <input type="tel" value={whatsapp} onChange={(e) => setWhatsapp(e.target.value)} placeholder="+966 5..." dir="ltr" style={{ textAlign: "left" }} />
        </div>
        <div className="field">
          <label>رقم الجوال (للتحقق)</label>
          <input type="tel" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+966 5..." dir="ltr" style={{ textAlign: "left" }} />
        </div>
      </div>

      <button type="submit" className="submit-btn" disabled={loading}>
        {loading ? "جاري الحفظ..." : "نشر المتجر"}
      </button>

      <p className="form-foot">
        سيظهر متجرك بشارة "غير موثّق" بعد النشر. للحصول على شارة "موثّق" تواصل مع فريق مؤشر العود.
      </p>
    </form>
  );
}
