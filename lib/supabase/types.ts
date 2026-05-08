// أنواع TypeScript لقاعدة البيانات
// يمكن توليدها تلقائياً بـ: npm run db:types
// لكنها مكتوبة يدوياً هنا للبدء السريع.

export type MerchantRegion = "gulf" | "asia" | "west" | "other";
export type VerificationStatus = "pending" | "in_review" | "verified" | "rejected";
export type UserRole = "customer" | "merchant" | "admin";

export interface Merchant {
  id: string;
  slug: string;
  name_ar: string;
  name_en: string | null;
  country: string;
  country_code: string | null;
  flag: string | null;
  region: MerchantRegion;
  city: string | null;
  types: string[];
  description_ar: string | null;
  description_en: string | null;
  founded_year: number | null;
  website: string | null;
  instagram: string | null;
  whatsapp: string | null;
  email: string | null;
  phone: string | null;
  verification_status: VerificationStatus;
  verified_at: string | null;
  verified_by: string | null;
  owner_id: string | null;
  claimed_at: string | null;
  reviews_count: number;
  average_rating: number;
  views_count: number;
  created_at: string;
  updated_at: string;
}

export interface Review {
  id: string;
  merchant_id: string;
  reviewer_id: string | null;
  reviewer_name: string;
  rating: number;
  text: string;
  is_verified_buyer: boolean;
  proof_of_purchase_url: string | null;
  merchant_reply: string | null;
  merchant_reply_at: string | null;
  is_hidden: boolean;
  hidden_reason: string | null;
  reports_count: number;
  helpful_count: number;
  created_at: string;
  updated_at: string;
}

export interface Profile {
  id: string;
  email: string;
  full_name: string | null;
  phone: string | null;
  phone_verified: boolean;
  avatar_url: string | null;
  role: UserRole;
  created_at: string;
  updated_at: string;
}

export interface VerificationRequest {
  id: string;
  merchant_id: string;
  submitted_by: string;
  commercial_registration_url: string | null;
  national_id_url: string | null;
  selfie_url: string | null;
  business_address: string | null;
  business_phone: string | null;
  video_call_scheduled_at: string | null;
  video_call_completed_at: string | null;
  status: VerificationStatus;
  reviewed_at: string | null;
  reviewed_by: string | null;
  reviewer_notes: string | null;
  rejection_reason: string | null;
  created_at: string;
}

// النوع الكامل لـ Supabase
export type Database = {
  public: {
    Tables: {
      merchants: {
        Row: Merchant;
        Insert: Omit<Merchant, "id" | "created_at" | "updated_at" | "reviews_count" | "average_rating" | "views_count"> & {
          id?: string;
        };
        Update: Partial<Merchant>;
      };
      reviews: {
        Row: Review;
        Insert: Omit<Review, "id" | "created_at" | "updated_at" | "reports_count" | "helpful_count"> & {
          id?: string;
        };
        Update: Partial<Review>;
      };
      profiles: {
        Row: Profile;
        Insert: Profile;
        Update: Partial<Profile>;
      };
      verification_requests: {
        Row: VerificationRequest;
        Insert: Omit<VerificationRequest, "id" | "created_at"> & { id?: string };
        Update: Partial<VerificationRequest>;
      };
    };
  };
};
