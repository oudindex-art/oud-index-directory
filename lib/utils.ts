// دوال مساعدة عامة

export function initialsOf(name: string): string {
  return name
    .replace(/[^؀-ۿa-zA-Z\s]/g, "")
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((w) => w[0])
    .join("")
    .toUpperCase();
}

export function formatStars(rating: number): string {
  const full = Math.round(rating);
  return "★".repeat(full) + "☆".repeat(5 - full);
}

export function timeAgo(dateString: string): string {
  const date = new Date(dateString);
  const now = new Date();
  const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);

  const intervals: Array<[number, string, string]> = [
    [60, "ثانية", "ثوانٍ"],
    [3600, "دقيقة", "دقائق"],
    [86400, "ساعة", "ساعات"],
    [2592000, "يوم", "أيام"],
    [31536000, "شهر", "أشهر"],
  ];

  if (seconds < 60) return "الآن";
  for (let i = 0; i < intervals.length - 1; i++) {
    const [next, single, plural] = intervals[i + 1];
    const [prev] = intervals[i];
    if (seconds < next) {
      const value = Math.floor(seconds / prev);
      return `قبل ${value} ${value > 10 ? plural : single}`;
    }
  }
  const years = Math.floor(seconds / 31536000);
  return `قبل ${years} سنوات`;
}

export const COUNTRY_FLAGS: Record<string, string> = {
  SA: "🇸🇦", AE: "🇦🇪", KW: "🇰🇼", QA: "🇶🇦", OM: "🇴🇲", BH: "🇧🇭", YE: "🇾🇪",
  IN: "🇮🇳", KH: "🇰🇭", VN: "🇻🇳", ID: "🇮🇩", MY: "🇲🇾", TH: "🇹🇭",
  US: "🇺🇸", GB: "🇬🇧", CA: "🇨🇦", FR: "🇫🇷", DE: "🇩🇪", RU: "🇷🇺", TR: "🇹🇷",
};

export function detectRegion(country: string): "gulf" | "asia" | "west" | "other" {
  const gulf = ["السعودية","الإمارات","الكويت","قطر","عُمان","البحرين","اليمن"];
  const asia = ["الهند","كمبوديا","فيتنام","إندونيسيا","ماليزيا","تايلاند"];
  const west = ["الولايات المتحدة","المملكة المتحدة","كندا","فرنسا","ألمانيا","روسيا"];
  if (gulf.includes(country)) return "gulf";
  if (asia.includes(country)) return "asia";
  if (west.includes(country)) return "west";
  return "other";
}

// توليد slug من النص الإنجليزي
export function slugify(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}
