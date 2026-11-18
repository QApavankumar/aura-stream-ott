-- ==============================================================================
-- AURA STREAM OTT — PRODUCTION SUPABASE SCHEMA & SEED SCRIPT
-- ==============================================================================
-- Run this complete script in your Supabase SQL Editor:
-- (Dashboard -> SQL Editor -> New Query -> Paste & Run)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. VIEWER PROFILES TABLE (Supports multi-profile accounts & Kids PIN)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_icon TEXT DEFAULT 'person',
    theme_color_hex TEXT DEFAULT '#00F2FE',
    is_kids BOOLEAN DEFAULT FALSE,
    is_primary BOOLEAN DEFAULT FALSE,
    content_rating TEXT DEFAULT '4K Ultra HD • All Access',
    kids_pin TEXT DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. MOVIES & TITLES CATALOG TABLE
CREATE TABLE IF NOT EXISTS public.movies (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    synopsis TEXT,
    backdrop_url TEXT NOT NULL,
    poster_url TEXT NOT NULL,
    genres TEXT[] DEFAULT '{}',
    rating TEXT DEFAULT '9.0',
    year TEXT DEFAULT '2026',
    maturity_rating TEXT DEFAULT '16+',
    duration TEXT DEFAULT '2h 15m',
    stream_url TEXT DEFAULT 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    badge TEXT DEFAULT NULL,
    is_hero BOOLEAN DEFAULT FALSE,
    is_live_match BOOLEAN DEFAULT FALSE,
    is_popular_4k BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. WATCH HISTORY / CONTINUE WATCHING TABLE (Cross-Device Sync)
CREATE TABLE IF NOT EXISTS public.watch_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    movie_id TEXT REFERENCES public.movies(id) ON DELETE CASCADE,
    progress DOUBLE PRECISION DEFAULT 0.0,
    remaining_time TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(profile_id, movie_id)
);

-- 5. WATCHLIST / MY LIST TABLE
CREATE TABLE IF NOT EXISTS public.watchlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    movie_id TEXT REFERENCES public.movies(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(profile_id, movie_id)
);

-- 6. USER HARDWARE & STREAMING PREFERENCES TABLE
CREATE TABLE IF NOT EXISTS public.user_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    streaming_quality TEXT DEFAULT 'Auto 4K HDR',
    spatial_audio BOOLEAN DEFAULT TRUE,
    hardware_acceleration BOOLEAN DEFAULT TRUE,
    smart_downloads BOOLEAN DEFAULT TRUE,
    wifi_only_downloads BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watch_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- Movies are publicly readable by any authenticated viewer or guest
DROP POLICY IF EXISTS "Public Read Movies" ON public.movies;
CREATE POLICY "Public Read Movies" ON public.movies
    FOR SELECT USING (true);

-- Profiles are isolated per authenticated user
DROP POLICY IF EXISTS "Users can manage own profiles" ON public.profiles;
CREATE POLICY "Users can manage own profiles" ON public.profiles
    FOR ALL USING (auth.uid() = user_id);

-- Watch History isolated per user
DROP POLICY IF EXISTS "Users can manage own watch history" ON public.watch_history;
CREATE POLICY "Users can manage own watch history" ON public.watch_history
    FOR ALL USING (auth.uid() = user_id);

-- Watchlist isolated per user
DROP POLICY IF EXISTS "Users can manage own watchlist" ON public.watchlist;
CREATE POLICY "Users can manage own watchlist" ON public.watchlist
    FOR ALL USING (auth.uid() = user_id);

-- Settings isolated per user
DROP POLICY IF EXISTS "Users can manage own settings" ON public.user_settings;
CREATE POLICY "Users can manage own settings" ON public.user_settings
    FOR ALL USING (auth.uid() = user_id);

-- ==============================================================================
-- REALTIME SUBSCRIPTIONS
-- ==============================================================================
-- Broadcast watch history & watchlist changes for real-time multi-device sync safely
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'watch_history'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.watch_history;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'watchlist'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.watchlist;
  END IF;
END $$;

-- ==============================================================================
-- SEED DATA: PRE-POPULATE HIGH-FIDELITY MOVIES & CHANNELS
-- ==============================================================================
INSERT INTO public.movies (id, title, synopsis, backdrop_url, poster_url, genres, rating, year, maturity_rating, duration, stream_url, badge, is_hero, is_popular_4k, is_live_match)
VALUES
-- Hero Banner Title
(
    'chrono_horizon',
    'CHRONO HORIZON',
    'The boundaries of space-time shatter in the deep orbit of Saturn as an expedition uncovers an ancient celestial beacon.',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1600&q=80',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&q=80',
    ARRAY['Sci-Fi', 'Action', '4K UHD'],
    '9.9',
    '2026',
    '16+',
    '2h 30m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'LIVE PREMIERE',
    TRUE,
    FALSE,
    FALSE
),
-- Rail 1: Live Channels & Matches
(
    'live_01',
    'Champions League: Real Madrid vs Man City',
    'Semifinal Leg 2 • Santiago Bernabéu Stadium • Dolby Atmos Broadcast',
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80',
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
    ARRAY['Live Sports', 'Football'],
    '10.0',
    '2026',
    'All',
    '90m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'LIVE',
    FALSE,
    FALSE,
    TRUE
),
(
    'live_02',
    'Premier League: Arsenal vs Liverpool',
    'Emirates Stadium • Multicam 4K HDR live feed with crowd audio.',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=80',
    ARRAY['Live Sports', 'Football'],
    '9.8',
    '2026',
    'All',
    '90m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'LIVE',
    FALSE,
    FALSE,
    TRUE
),
-- Rail 2: Popular in 4K UHD
(
    'pop_01',
    'Quantum Singularity',
    'Theoretical physicists accidentally open a stable wormhole in the Swiss Alps, sparking a global race for cosmic energy.',
    'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1600&q=80',
    'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=600&q=80',
    ARRAY['Sci-Fi', 'Thriller', '4K UHD'],
    '9.8',
    '2026',
    '16+',
    '2h 45m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'Tags',
    FALSE,
    TRUE,
    FALSE
),
(
    'pop_02',
    'Blade of the Ronin',
    'In a cyber-drenched neo-feudal Tokyo, an exiled synthetic swordsman fights to dismantle the AI megacorporation that built him.',
    'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=1600&q=80',
    'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=600&q=80',
    ARRAY['Action', 'Cyberpunk', '4K UHD'],
    '9.5',
    '2025',
    '18+',
    '1h 40m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'Tags',
    FALSE,
    TRUE,
    FALSE
),
(
    'pop_03',
    'Orbital Protocol: Redux',
    'Astronauts on a deep-space research platform race against a decaying orbit while an unidentified transmission invades the ship.',
    'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1600&q=80',
    'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&q=80',
    ARRAY['Sci-Fi', 'Thriller', '4K UHD'],
    '9.2',
    '2026',
    '16+',
    '2h 10m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'Tags',
    FALSE,
    TRUE,
    FALSE
),
(
    'pop_04',
    'Shadow Nexus: 2099',
    'Underground rebels hack into the central consciousness matrix of the megacity to free captive synthetic intelligences.',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1600&q=80',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&q=80',
    ARRAY['Action', 'Cyberpunk', '4K UHD'],
    '9.6',
    '2026',
    '18+',
    '1h 55m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'Tags',
    FALSE,
    TRUE,
    FALSE
),
(
    'pop_05',
    'The Infinite Dimension',
    'An exploratory voyage into supermassive black holes exploring multi-dimensional realities and gravitational acoustic waves.',
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1600&q=80',
    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&q=80',
    ARRAY['Documentary', 'Cosmic', '4K UHD'],
    '9.9',
    '2026',
    'All',
    '1h 38m',
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    'Tags',
    FALSE,
    TRUE,
    FALSE
)
ON CONFLICT (id) DO NOTHING;
