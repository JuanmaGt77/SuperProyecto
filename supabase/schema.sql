-- ============================================================
-- ServiLink — Schema completo PostgreSQL + PostGIS
-- Ejecuta este script en el SQL Editor de Supabase.
-- ============================================================

-- 1. Extensiones
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================
-- 2. TABLAS
-- ============================================================

-- Users (extiende auth.users)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  avatar_public_id TEXT,
  role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'provider', 'admin')),
  is_active BOOLEAN DEFAULT true,
  is_blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS client_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  address TEXT,
  location GEOGRAPHY(POINT, 4326),
  preferred_payment TEXT DEFAULT 'cash',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  icon_url TEXT,
  color_hex TEXT DEFAULT '#1A56DB',
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS provider_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  bio TEXT,
  years_experience INT DEFAULT 0,
  base_location GEOGRAPHY(POINT, 4326),
  current_location GEOGRAPHY(POINT, 4326),
  coverage_radius_km FLOAT DEFAULT 10.0,
  work_zones TEXT[],
  base_rate DECIMAL(10,2),
  is_available BOOLEAN DEFAULT false,
  is_verified BOOLEAN DEFAULT false,
  verification_status TEXT DEFAULT 'pending'
    CHECK (verification_status IN ('pending','in_review','approved','rejected','suspended')),
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES users(id),
  avg_rating DECIMAL(3,2) DEFAULT 0.0,
  total_reviews INT DEFAULT 0,
  total_jobs INT DEFAULT 0,
  schedule JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS provider_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID REFERENCES provider_profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES service_categories(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(provider_id, category_id)
);

CREATE TABLE IF NOT EXISTS provider_gallery (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID REFERENCES provider_profiles(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  public_id TEXT NOT NULL,
  caption TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS provider_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID REFERENCES provider_profiles(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL CHECK (doc_type IN ('id_front','id_back','selfie','certification')),
  image_url TEXT NOT NULL,
  public_id TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS uploaded_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  public_id TEXT NOT NULL,
  image_type TEXT NOT NULL CHECK (image_type IN (
    'avatar','gallery','service_request','chat','review','document','report'
  )),
  related_id UUID,
  related_table TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES users(id),
  category_id UUID REFERENCES service_categories(id),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  location GEOGRAPHY(POINT, 4326),
  address TEXT,
  urgency TEXT DEFAULT 'normal' CHECK (urgency IN ('normal','urgent','scheduled')),
  scheduled_at TIMESTAMPTZ,
  estimated_budget DECIMAL(10,2),
  status TEXT DEFAULT 'created' CHECK (status IN (
    'created','waiting_provider','quote_sent','quote_accepted',
    'provider_on_way','provider_arrived','in_progress','completed',
    'payment_pending','paid','cancelled','reported'
  )),
  payment_method TEXT DEFAULT 'cash',
  total_amount DECIMAL(10,2),
  platform_fee DECIMAL(10,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id UUID REFERENCES service_requests(id) ON DELETE CASCADE,
  previous_status TEXT,
  new_status TEXT NOT NULL,
  changed_by UUID REFERENCES users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id UUID REFERENCES service_requests(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES users(id) ON DELETE CASCADE,
  price DECIMAL(10,2) NOT NULL,
  description TEXT NOT NULL,
  includes_materials BOOLEAN DEFAULT false,
  estimated_duration TEXT,
  conditions TEXT,
  proposed_date TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending','accepted','rejected','cancelled','expired'
  )),
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id UUID REFERENCES service_requests(id),
  client_id UUID REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES users(id) ON DELETE CASCADE,
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  client_unread INT DEFAULT 0,
  provider_unread INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  image_url TEXT,
  image_public_id TEXT,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text','image','system')),
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id UUID REFERENCES service_requests(id) ON DELETE CASCADE,
  client_id UUID REFERENCES users(id),
  provider_id UUID REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  platform_fee DECIMAL(10,2) DEFAULT 0,
  provider_amount DECIMAL(10,2),
  method TEXT DEFAULT 'cash' CHECK (method IN ('cash','card','paypal','transfer','wallet')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','paid','cancelled','refunded')),
  paid_at TIMESTAMPTZ,
  external_ref TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  request_id UUID REFERENCES service_requests(id),
  client_id UUID REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID REFERENCES users(id) ON DELETE CASCADE,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  image_url TEXT,
  recommend BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reported_user_id UUID REFERENCES users(id),
  request_id UUID REFERENCES service_requests(id),
  reason TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open','in_review','resolved','dismissed')),
  resolved_by UUID REFERENCES users(id),
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL,
  related_id UUID,
  related_table TEXT,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES users(id),
  action_type TEXT NOT NULL,
  target_user_id UUID REFERENCES users(id),
  target_table TEXT,
  target_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS platform_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key TEXT UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. ÍNDICES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_provider_location
  ON provider_profiles USING GIST (current_location);
CREATE INDEX IF NOT EXISTS idx_provider_available
  ON provider_profiles (is_available, verification_status)
  WHERE is_available = true AND verification_status = 'approved';
CREATE INDEX IF NOT EXISTS idx_request_location
  ON service_requests USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_request_status ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_request_client ON service_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_request_provider ON service_requests(provider_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat ON messages(chat_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chats_users ON chats(client_id, provider_id);

-- ============================================================
-- 4. SEED DATA — Categorías iniciales
-- ============================================================
INSERT INTO service_categories (name, slug, color_hex, sort_order) VALUES
  ('Mecánico Automotriz', 'mecanico', '#EF4444', 1),
  ('Albañil', 'albanil', '#F97316', 2),
  ('Electricista', 'electricista', '#EAB308', 3),
  ('Soldador', 'soldador', '#3B82F6', 4),
  ('Plomero', 'plomero', '#22C55E', 5)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO platform_settings (key, value, description) VALUES
  ('platform_fee_percent', '10', 'Comisión de la plataforma en %'),
  ('max_coverage_radius_km', '50', 'Radio máximo de cobertura'),
  ('quote_expiry_hours', '24', 'Horas antes de expirar cotización')
ON CONFLICT (key) DO NOTHING;

-- ============================================================
-- 5. RPC — Buscar prestadores cercanos
-- ============================================================
CREATE OR REPLACE FUNCTION get_nearby_providers(
  lat FLOAT,
  lng FLOAT,
  radius_km FLOAT DEFAULT 10,
  category_slug TEXT DEFAULT NULL
)
RETURNS TABLE (
  provider_id UUID,
  user_id UUID,
  full_name TEXT,
  avatar_url TEXT,
  avg_rating DECIMAL,
  distance_km FLOAT,
  is_available BOOLEAN,
  base_rate DECIMAL,
  category_name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    pp.id,
    pp.user_id,
    u.full_name,
    u.avatar_url,
    pp.avg_rating,
    ROUND((ST_Distance(
      pp.current_location::geography,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography
    ) / 1000)::NUMERIC, 2)::FLOAT AS distance_km,
    pp.is_available,
    pp.base_rate,
    sc.name AS category_name
  FROM provider_profiles pp
  JOIN users u ON u.id = pp.user_id
  JOIN provider_categories pc ON pc.provider_id = pp.id
  JOIN service_categories sc ON sc.id = pc.category_id
  WHERE pp.verification_status = 'approved'
    AND pp.is_available = true
    AND u.is_active = true
    AND u.is_blocked = false
    AND ST_DWithin(
      pp.current_location::geography,
      ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
      radius_km * 1000
    )
    AND (category_slug IS NULL OR sc.slug = category_slug)
  ORDER BY distance_km ASC, pp.avg_rating DESC;
END;
$$;

CREATE OR REPLACE FUNCTION update_provider_location(
  provider_user_id UUID,
  lat FLOAT,
  lng FLOAT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE provider_profiles
  SET current_location = ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
      updated_at = NOW()
  WHERE user_id = provider_user_id;
END;
$$;

-- ============================================================
-- 6. ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Users: cada uno ve su propio perfil; admins ven todos
CREATE POLICY "users_self_select" ON users FOR SELECT
  USING (auth.uid() = id OR EXISTS(
    SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role = 'admin'
  ));

CREATE POLICY "users_self_update" ON users FOR UPDATE
  USING (auth.uid() = id);

-- Provider profiles públicos si están aprobados
CREATE POLICY "provider_public_select" ON provider_profiles FOR SELECT
  USING (verification_status = 'approved' OR user_id = auth.uid()
    OR EXISTS(SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "provider_self_update" ON provider_profiles FOR UPDATE
  USING (user_id = auth.uid());

-- Service requests: cliente y prestador asignado
CREATE POLICY "requests_participants_select" ON service_requests FOR SELECT
  USING (client_id = auth.uid() OR provider_id = auth.uid()
    OR EXISTS(SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "requests_client_insert" ON service_requests FOR INSERT
  WITH CHECK (client_id = auth.uid());

CREATE POLICY "requests_participants_update" ON service_requests FOR UPDATE
  USING (client_id = auth.uid() OR provider_id = auth.uid());

-- Messages: solo participantes del chat
CREATE POLICY "messages_participants_select" ON messages FOR SELECT
  USING (EXISTS(
    SELECT 1 FROM chats c
    WHERE c.id = chat_id
    AND (c.client_id = auth.uid() OR c.provider_id = auth.uid())
  ));

CREATE POLICY "messages_send" ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid() AND EXISTS(
    SELECT 1 FROM chats c
    WHERE c.id = chat_id
    AND (c.client_id = auth.uid() OR c.provider_id = auth.uid())
  ));

-- Chats: solo participantes
CREATE POLICY "chats_participants_select" ON chats FOR SELECT
  USING (client_id = auth.uid() OR provider_id = auth.uid());

-- Documents: solo dueño y admins
CREATE POLICY "docs_owner_select" ON provider_documents FOR SELECT
  USING (provider_id IN (
    SELECT id FROM provider_profiles WHERE user_id = auth.uid()
  ) OR EXISTS(SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'));

-- ============================================================
-- 7. TRIGGER — Actualiza avg_rating del prestador al crear review
-- ============================================================
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE provider_profiles pp
  SET
    avg_rating = (
      SELECT ROUND(AVG(rating)::NUMERIC, 2)
      FROM reviews WHERE provider_id = NEW.provider_id
    ),
    total_reviews = (
      SELECT COUNT(*) FROM reviews WHERE provider_id = NEW.provider_id
    ),
    updated_at = NOW()
  WHERE pp.user_id = NEW.provider_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_rating ON reviews;
CREATE TRIGGER trigger_update_rating
  AFTER INSERT ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_provider_rating();

-- ============================================================
-- 8. TRIGGER — Crea registro en users al confirmar email
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
