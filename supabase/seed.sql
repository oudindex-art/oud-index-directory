-- =====================================================
-- Seed Data — بيانات أولية
-- ٣٠ تاجر عود معروف عالمياً للبدء
-- شغّليه بعد schema.sql و policies.sql
-- =====================================================

insert into public.merchants (slug, name_ar, name_en, country, country_code, flag, region, types, description_ar, description_en, founded_year, verification_status, verified_at) values

-- === الخليج ===
('abdul-samad-al-qurashi', 'عبد الصمد القرشي', 'Abdul Samad Al Qurashi', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['هندي','كمبودي','عطور عود','بخور ومعمول'],
  'بيت عود سعودي عريق منذ ١٨٥٢م، يُعدّ من أقدم وأشهر بيوت العود في العالم العربي.',
  'A historic Saudi oud house since 1852, considered one of the oldest and most renowned oud houses in the Arab world.',
  1852, 'verified', now()),

('arabian-oud', 'العربية للعود', 'Arabian Oud', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['كمبودي','هندي','عطور عود','دهن العود'],
  'أكبر سلسلة محلات عود في العالم، تأسست عام ١٩٨٢. تنتشر فروعها في أكثر من ٣٥ دولة.',
  'The world''s largest oud retail chain, founded in 1982. Operates in over 35 countries.',
  1982, 'verified', now()),

('al-haramain', 'الحرمين', 'Al Haramain Perfumes', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['عطور عود','دهن العود','بخور ومعمول'],
  'بيت عطور وعود سعودي تأسس عام ١٩٧٠. مشهور بدهن العود المباركية والسيوفي.',
  'A Saudi perfume and oud house founded in 1970. Known for Mubarakiyah and Suyufi dehn al oud.',
  1970, 'verified', now()),

('ajmal-perfumes', 'أجمل للعطور', 'Ajmal Perfumes', 'الإمارات', 'AE', '🇦🇪', 'gulf',
  ARRAY['هندي','كمبودي','عطور عود','دهن العود'],
  'بيت أجمل تأسس عام ١٩٥١ في الهند ثم انتقل للإمارات. أكثر من ٧٠ عاماً في صناعة العود والعطور.',
  'Ajmal was founded in 1951 in India and later moved to UAE. Over 70 years in oud and perfumery.',
  1951, 'verified', now()),

('rasasi', 'الرصاصي', 'Rasasi', 'الإمارات', 'AE', '🇦🇪', 'gulf',
  ARRAY['عطور عود','دهن العود'],
  'بيت رصاصي العالمي للعطور الفاخرة، يجمع بين العراقة الشرقية والجودة العالمية.',
  'Global luxury perfume house combining oriental heritage with world-class quality.',
  1979, 'verified', now()),

('hind-al-oud', 'هند العود', 'Hind Al Oud', 'الإمارات', 'AE', '🇦🇪', 'gulf',
  ARRAY['دهن العود','عطور عود','بخور ومعمول'],
  'علامة إماراتية مميزة في عالم العود والعطور الفاخرة، معروفة بجودة الدهن العالية.',
  'Distinctive Emirati brand in luxury oud and perfumery, known for high-quality dehn al oud.',
  null, 'verified', now()),

('anfasic-dokhoon', 'أنفاسك دخون', 'Anfasic Dokhoon', 'الإمارات', 'AE', '🇦🇪', 'gulf',
  ARRAY['بخور ومعمول','عطور عود'],
  'متخصصة في المعمول والبخور الفاخر، حضور قوي في وسائل التواصل الاجتماعي.',
  'Specialists in premium ma''moul and bakhoor, strong social media presence.',
  null, 'pending', null),

('swiss-arabian', 'سويس عربيان', 'Swiss Arabian', 'الإمارات', 'AE', '🇦🇪', 'gulf',
  ARRAY['عطور عود'],
  'بيت عطور تأسس عام ١٩٧٤، يجمع التراث العربي بالحرفية السويسرية.',
  'Perfume house founded in 1974, blending Arabian heritage with Swiss craftsmanship.',
  1974, 'verified', now()),

('lattafa', 'لطافة', 'Lattafa Perfumes', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['عطور عود'],
  'بيت عطور سعودي صاعد بسرعة، اشتهر بالعطور بأسعار مناسبة وتركيبات قوية.',
  'Fast-rising Saudi perfume house, known for affordable yet powerful compositions.',
  null, 'verified', now()),

('amouage', 'أمواج', 'Amouage', 'عُمان', 'OM', '🇴🇲', 'gulf',
  ARRAY['عطور عود','دهن العود'],
  'بيت العطور العُماني الأرقى عالمياً، تأسس عام ١٩٨٣. عطوره من أفخم العطور في العالم.',
  'Oman''s finest luxury perfume house, founded in 1983. Its perfumes are among the world''s most prestigious.',
  1983, 'verified', now()),

('bawader-kuwait', 'بوادر', 'Bawader', 'الكويت', 'KW', '🇰🇼', 'gulf',
  ARRAY['دهن العود','بخور ومعمول'],
  'بيت عود كويتي معروف بالدهن الكمبودي عالي الجودة وخلطات المعمول الخاصة.',
  'Kuwaiti oud house known for high-quality Cambodian dehn and signature ma''moul blends.',
  null, 'pending', null),

('al-jazeera-perfumes', 'الجزيرة للعطور', 'Al Jazeera Perfumes', 'الكويت', 'KW', '🇰🇼', 'gulf',
  ARRAY['عطور عود','دهن العود'],
  'بيت عطور كويتي تقليدي، يخدم عملاء الكويت منذ عقود.',
  'Traditional Kuwaiti perfume house serving customers for decades.',
  null, 'pending', null),

('surrati', 'سراتي', 'Surrati', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['عطور عود','بخور ومعمول'],
  'علامة سعودية معروفة بعطور العود وخلطات البخور الفاخرة.',
  'Saudi brand known for oud perfumes and premium bakhoor blends.',
  null, 'verified', now()),

('asayel', 'أصايل', 'Asayel', 'السعودية', 'SA', '🇸🇦', 'gulf',
  ARRAY['دهن العود','بخور ومعمول'],
  'متخصصون في الدهن والمعمول الفاخر بأسلوب تقليدي.',
  'Specialists in traditional premium dehn and ma''moul.',
  null, 'pending', null),

-- === الغرب ===
('ensar-oud', 'إنصار عود', 'Ensar Oud', 'الولايات المتحدة', 'US', '🇺🇸', 'west',
  ARRAY['هندي','كمبودي','فيتنامي','دهن العود'],
  'بيت العود الأرقى في الغرب، أسسه إنصار بيكتوفيتش. مرجع عالمي في دهن العود الأصيل والمقطر تقليدياً.',
  'The premier oud house in the West, founded by Ensar Bektovic. Global reference for authentic, traditionally distilled oud oils.',
  2007, 'verified', now()),

('agar-aura', 'أجار أورا', 'Agar Aura', 'كندا', 'CA', '🇨🇦', 'west',
  ARRAY['دهن العود','هندي','كمبودي'],
  'بيت عود حرفي يديره طه سيد، معروف بالشفافية في المصدر وتقطير العود الفاخر.',
  'Artisan oud house run by Taha Syed, known for source transparency and premium distillation.',
  null, 'verified', now()),

('sultan-pasha-attars', 'سلطان باشا', 'Sultan Pasha Attars', 'المملكة المتحدة', 'GB', '🇬🇧', 'west',
  ARRAY['دهن العود','عطور عود'],
  'بيت عطور حرفي بريطاني، يصنع تركيبات شرقية فاخرة بأسلوب تقليدي.',
  'British artisan perfume house creating premium oriental compositions in the traditional style.',
  null, 'verified', now()),

('imperial-oud', 'إمبيريال عود', 'Imperial Oud', 'المملكة المتحدة', 'GB', '🇬🇧', 'west',
  ARRAY['دهن العود','هندي','كمبودي'],
  'بيت عود بريطاني متخصص في الدهن النادر من المصادر الأصلية.',
  'British oud house specializing in rare oils from original sources.',
  null, 'verified', now()),

('rising-phoenix-perfumery', 'رايزنق فينيكس', 'Rising Phoenix Perfumery', 'الولايات المتحدة', 'US', '🇺🇸', 'west',
  ARRAY['دهن العود','عطور عود'],
  'بيت عطور حرفي أسسه JK DeLapp، معروف بدهن العود والعطور الطبيعية المركّبة بدقة.',
  'Artisan perfume house by JK DeLapp, known for oud oils and meticulously composed natural perfumes.',
  null, 'verified', now()),

('mellifluence', 'مليفلوينس', 'Mellifluence', 'المملكة المتحدة', 'GB', '🇬🇧', 'west',
  ARRAY['دهن العود','عطور عود'],
  'بيت عطور حرفي يديره عبدالله صوفي، معروف بالمخلطات الشرقية الناعمة.',
  'Artisan house by Abdullah Sufi, known for refined oriental mukhallats.',
  null, 'pending', null),

-- === آسيا (الدول المنتجة) ===
('areej-le-dore', 'أريج لي دوريه', 'Areej Le Doré', 'تايلاند', 'TH', '🇹🇭', 'asia',
  ARRAY['دهن العود','عطور عود'],
  'بيت عطور حرفي أسسه آدم (Russian Adam)، يصنع تركيبات نادرة بأقل من ٢٠٠ زجاجة لكل إصدار.',
  'Artisan perfume house by Adam (Russian Adam), creating rare compositions in batches under 200 bottles.',
  2017, 'verified', now()),

('feel-oud', 'فيل عود', 'Feel Oud', 'فيتنام', 'VN', '🇻🇳', 'asia',
  ARRAY['فيتنامي','دهن العود'],
  'بيت عود متخصص في تقطير الدهن الفيتنامي مباشرة من المصدر في خانه هوا.',
  'Oud house specializing in Vietnamese oil distillation direct from source in Khanh Hoa.',
  null, 'pending', null),

('oriscent', 'أوريسنت', 'Oriscent', 'عُمان', 'OM', '🇴🇲', 'asia',
  ARRAY['دهن العود'],
  'أحد أوائل بيوت العود الغربية، تديره تريغف هاريس من ظفار. مرجع تاريخي في عالم الدهن.',
  'One of the earliest Western oud houses, run by Trygve Harris from Dhofar. Historical reference in dehn al oud.',
  null, 'pending', null),

('habibul-hab', 'حبيب الحب', 'Habibul Hab', 'ماليزيا', 'MY', '🇲🇾', 'asia',
  ARRAY['دهن العود','إندونيسي'],
  'متخصص في الدهن الماليزي والإندونيسي، حضور قوي في مجتمعات هواة العود.',
  'Specialist in Malaysian and Indonesian dehn, strong presence in oud enthusiast communities.',
  null, 'pending', null),

('kannauj-attar-wallahs', 'صنّاع كنوج', 'Kannauj Attar Wallahs', 'الهند', 'IN', '🇮🇳', 'asia',
  ARRAY['دهن العود','هندي'],
  'ورثة الصناعة التقليدية للعطور والدهن في كنوج، الهند. جذور تعود لـ٤٠٠ عام.',
  'Heirs to the traditional perfumery and oil-making craft in Kannauj, India. Roots going back 400 years.',
  null, 'pending', null),

('khanh-hoa-producers', 'منتجو خانه هوا', 'Khanh Hoa Producers', 'فيتنام', 'VN', '🇻🇳', 'asia',
  ARRAY['فيتنامي','دهن العود'],
  'تجمع منتجي العود في إقليم خانه هوا الفيتنامي، أحد أهم مناطق إنتاج العود في العالم.',
  'Collective of oud producers in Vietnam''s Khanh Hoa province, one of the world''s most important oud-producing regions.',
  null, 'pending', null),

('pursat-oud', 'بورسات', 'Pursat Oud', 'كمبوديا', 'KH', '🇰🇭', 'asia',
  ARRAY['كمبودي','دهن العود'],
  'منتجو العود من إقليم بورسات الكمبودي، مصدر تاريخي للعود الكمبودي الفاخر.',
  'Oud producers from Cambodia''s Pursat province, a historic source of premium Cambodian oud.',
  null, 'pending', null),

('kalimantan-producers', 'منتجو كاليمانتان', 'Kalimantan Producers', 'إندونيسيا', 'ID', '🇮🇩', 'asia',
  ARRAY['إندونيسي','دهن العود'],
  'منتجو العود من جزيرة كاليمانتان، الموطن الأكبر لشجرة العود الإندونيسية.',
  'Oud producers from Kalimantan island, the largest home of Indonesian agarwood trees.',
  null, 'pending', null);

-- =====================================================
-- ملاحظة: التقييمات السابقة من النموذج التجريبي يمكن إضافتها لاحقاً
-- بعد أن تنشئي حسابات مستخدمين تجريبية في Supabase Auth.
-- =====================================================
