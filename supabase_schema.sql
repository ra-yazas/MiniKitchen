-- =============================================================================
-- MiniKitchen - Supabase Database Schema & Seed Script
-- Run this in your Supabase Project -> SQL Editor
-- =============================================================================

-- 1. Enable pgcrypto extension for UUID generation if needed
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 2. TABLE: menu_items
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.menu_items (
    id TEXT PRIMARY KEY DEFAULT ('MK-ITEM-' || substr(md5(random()::text), 1, 6)),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('burgers', 'pizzas', 'tacos-bites', 'bowls-noodles', 'desserts-drinks')),
    price NUMERIC(10, 2) NOT NULL,
    rating NUMERIC(3, 1) DEFAULT 5.0,
    reviews_count INTEGER DEFAULT 1,
    image TEXT NOT NULL,
    description TEXT NOT NULL,
    is_available BOOLEAN DEFAULT true,
    is_vegetarian BOOLEAN DEFAULT false,
    is_spicy BOOLEAN DEFAULT false,
    is_popular BOOLEAN DEFAULT false,
    prep_time TEXT DEFAULT '15-20 min',
    calories INTEGER DEFAULT 600,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 3. TABLE: reservations
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.reservations (
    id TEXT PRIMARY KEY DEFAULT ('MK-' || floor(1000 + random() * 9000)::text),
    customer_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    date DATE NOT NULL,
    time TEXT NOT NULL,
    guests INTEGER NOT NULL DEFAULT 2 CHECK (guests >= 1 AND guests <= 20),
    seating_area TEXT DEFAULT 'Indoor Main Dining',
    occasion TEXT DEFAULT 'Standard Dining',
    special_notes TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 4. TABLE: reviews
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.reviews (
    id TEXT PRIMARY KEY DEFAULT ('rev-' || substr(md5(random()::text), 1, 6)),
    author TEXT NOT NULL,
    role TEXT,
    rating INTEGER DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
    avatar TEXT,
    content TEXT NOT NULL,
    date TEXT DEFAULT 'Recent',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================
-- Enable RLS on all tables
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Drop old policies if re-running
DROP POLICY IF EXISTS "Public can view menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Allow all access to menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Public can view reviews" ON public.reviews;
DROP POLICY IF EXISTS "Public can insert reservations" ON public.reservations;
DROP POLICY IF EXISTS "Public can read reservations for status lookup" ON public.reservations;
DROP POLICY IF EXISTS "Allow all access to reservations" ON public.reservations;

-- Menu Items Policies: Anyone can view; allow modifications for admin frontend
CREATE POLICY "Public can view menu items" 
    ON public.menu_items FOR SELECT 
    USING (true);

CREATE POLICY "Allow all access to menu items" 
    ON public.menu_items FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- Reviews Policies: Anyone can view
CREATE POLICY "Public can view reviews" 
    ON public.reviews FOR SELECT 
    USING (true);

-- Reservations Policies: Anyone can read, insert, and update (for frontend booking & admin management)
CREATE POLICY "Public can insert reservations" 
    ON public.reservations FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Public can read reservations for status lookup" 
    ON public.reservations FOR SELECT 
    USING (true);

CREATE POLICY "Allow all access to reservations" 
    ON public.reservations FOR ALL 
    USING (true) 
    WITH CHECK (true);

-- =============================================================================
-- 6. ENABLE REALTIME SUBSCRIPTIONS
-- =============================================================================
-- Allows instant live synchronization across clients without page refreshes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'menu_items'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.menu_items;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'reservations'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.reservations;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- Silently continue if publication permissions are restricted in your tier
    NULL;
END $$;

-- =============================================================================
-- 7. INITIAL REAL SEED DATA (Clean artisanal menu catalog)
-- =============================================================================
DELETE FROM public.menu_items;
DELETE FROM public.reviews;

INSERT INTO public.menu_items (id, name, category, price, rating, reviews_count, image, description, is_available, is_vegetarian, is_spicy, is_popular, prep_time, calories)
VALUES
('MK-ITEM-1', 'Artisan Golden Sunrise Burger', 'burgers', 4300.00, 4.9, 142, 
 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=700&q=80', 
 'Brioche bun, prime wagyu patty, sunny-side organic egg, aged cheddar, crisp greens, and house-made truffle aioli.', 
 true, false, false, true, '15-20 min', 780),

('MK-ITEM-2', 'Rustic Chicken & Basil Pizza', 'pizzas', 4550.00, 4.8, 128, 
 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=700&q=80', 
 'Slow-fermented stone baked crust, San Marzano tomato reduction, herb roasted chicken, buffalo mozzarella, and fresh basil.', 
 true, false, false, true, '18-22 min', 890),

('MK-ITEM-3', 'Crispy Southern Chicken Fry', 'tacos-bites', 3850.00, 4.9, 215, 
 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?auto=format&fit=crop&w=700&q=80', 
 'Triple-dredged buttermilk fried chicken tenders with spiced paprika crust, honey drizzle, and zesty pickled slaw.', 
 true, false, true, true, '12-16 min', 640),

('MK-ITEM-4', 'Smoked Provolone Melt Sandwich', 'burgers', 3600.00, 4.7, 96, 
 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=700&q=80', 
 'Toasted sourdough, artisan smoked beef pastrami, caramelized sweet onions, molten provolone cheese, and dijonnaise.', 
 true, false, false, false, '10-14 min', 590),

('MK-ITEM-5', 'Smoky Chipotle Beef Taco Trio', 'tacos-bites', 4350.00, 4.9, 158, 
 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?auto=format&fit=crop&w=700&q=80', 
 'Three warm heirloom corn tortillas, slow-braised chipotle barbacoa beef, avocado salsa verde, radish, and cilantro.', 
 true, false, true, true, '12-15 min', 540),

('MK-ITEM-6', 'Signature Shoyu Tonkotsu Ramen', 'bowls-noodles', 5250.00, 5.0, 184, 
 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&w=700&q=80', 
 'Rich 18-hour broth, springy handmade noodles, tender chashu pork belly, seasoned molten egg, wood ear mushroom, and scallions.', 
 true, false, false, true, '14-18 min', 720),

('MK-ITEM-7', 'Green Goddess Avocado Grain Bowl', 'bowls-noodles', 4400.00, 4.8, 89, 
 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=700&q=80', 
 'Tri-color organic quinoa, hass avocado roses, edamame, roasted sweet potatoes, heirloom cherry tomatoes, and tahini green dressing.', 
 true, true, false, false, '10-12 min', 460),

('MK-ITEM-8', 'Truffle Parmesan Hand-Cut Fries', 'tacos-bites', 2400.00, 4.9, 312, 
 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=700&q=80', 
 'Double-cooked Idaho potatoes tossed in white truffle oil, freshly grated 24-month Parmigiano-Reggiano, and rosemary sea salt.', 
 true, true, false, true, '8-10 min', 410),

('MK-ITEM-9', 'Belgian Berry & Whipped Cream Waffle', 'desserts-drinks', 3150.00, 4.9, 167, 
 'https://images.unsplash.com/photo-1562376552-0d160a2f238d?auto=format&fit=crop&w=700&q=80', 
 'Fluffy golden pearl-sugar waffle topped with macerated wild berries, organic Madagascar vanilla bean whipped cream, and pure maple syrup.', 
 true, true, false, true, '10-12 min', 520),

('MK-ITEM-10', 'Matcha Blossom Foam Cold Brew', 'desserts-drinks', 1750.00, 4.7, 94, 
 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=700&q=80', 
 'Single-origin Ethiopian slow cold brew topped with velvety Uji ceremonial matcha cream foam and hints of jasmine blossoms.', 
 true, true, false, false, '5 min', 140),

('MK-ITEM-11', 'Margherita Burrata Speciale', 'pizzas', 4950.00, 5.0, 176, 
 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?auto=format&fit=crop&w=700&q=80', 
 'Charred blistered crust, whole Pugliese creamy burrata center, organic confit cherry tomatoes, cold-pressed olive oil, and balsamic glaze.', 
 true, true, false, true, '16-20 min', 820),

('MK-ITEM-12', 'Molten Belgian Dark Lava Cake', 'desserts-drinks', 2850.00, 4.9, 204, 
 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=700&q=80', 
 'Warm 70% Callebaut dark chocolate cake with an oozy liquid ganache core, dusted with gold cocoa and served with gelato.', 
 true, true, false, true, '12 min', 610);

INSERT INTO public.reviews (id, author, role, rating, avatar, content, date)
VALUES
('rev-1', 'Priya Jayawardena', 'Food Columnist, Colombo 07', 5, 
 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80', 
 'MiniKitchen balances playful aesthetics with serious culinary technique. The Artisan Golden Sunrise Burger and Tonkotsu broth are world-class.', '2 days ago'),

('rev-2', 'Dilani & Kasun Mendis', 'Verified Local Diners, Mount Lavinia', 5, 
 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=200&q=80', 
 'The ambiance is breathtaking! Warm coral tones, cozy lighting, and the service was so gracious. Booked our anniversary table online seamlessly.', '1 week ago'),

('rev-3', 'Ruwan Senaratne', 'Gastronomy Blogger, Kandy', 5, 
 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80', 
 'The truffle parmesan fries and buttermilk chicken tenders are addictive. Easily the top dining destination in the district right now.', '2 weeks ago');

-- =============================================================================
-- 8. TABLE: admin_users (Staff & Management Authentication System)
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT DEFAULT 'Staff',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow admin auth lookup" ON public.admin_users;
DROP POLICY IF EXISTS "Allow admin registration" ON public.admin_users;
DROP POLICY IF EXISTS "Allow admin updates" ON public.admin_users;

CREATE POLICY "Allow admin auth lookup"
    ON public.admin_users FOR SELECT
    USING (true);

CREATE POLICY "Allow admin registration"
    ON public.admin_users FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow admin updates"
    ON public.admin_users FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Function: Register New Admin / Staff Member
CREATE OR REPLACE FUNCTION public.register_admin_user(
    p_username TEXT,
    p_email TEXT,
    p_password TEXT,
    p_full_name TEXT,
    p_role TEXT DEFAULT 'Staff'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    new_user public.admin_users;
BEGIN
    -- Validate username uniqueness
    IF EXISTS (SELECT 1 FROM public.admin_users WHERE LOWER(username) = LOWER(TRIM(p_username))) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Username is already registered');
    END IF;

    -- Validate email uniqueness
    IF EXISTS (SELECT 1 FROM public.admin_users WHERE LOWER(email) = LOWER(TRIM(p_email))) THEN
        RETURN jsonb_build_object('success', false, 'message', 'Email address is already in use');
    END IF;

    -- Insert record with secure blowfish crypt hashing
    INSERT INTO public.admin_users (username, email, full_name, password_hash, role)
    VALUES (
        LOWER(TRIM(p_username)),
        LOWER(TRIM(p_email)),
        TRIM(p_full_name),
        crypt(p_password, gen_salt('bf', 10)),
        p_role
    )
    RETURNING * INTO new_user;

    RETURN jsonb_build_object(
        'success', true,
        'user', jsonb_build_object(
            'id', new_user.id,
            'username', new_user.username,
            'email', new_user.email,
            'fullName', new_user.full_name,
            'role', new_user.role,
            'createdAt', new_user.created_at
        )
    );
END;
$$;

-- Function: Secure Admin Sign In
CREATE OR REPLACE FUNCTION public.login_admin_user(
    p_username TEXT,
    p_password TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    found_user public.admin_users;
BEGIN
    SELECT * INTO found_user
    FROM public.admin_users
    WHERE LOWER(username) = LOWER(TRIM(p_username))
       OR LOWER(email) = LOWER(TRIM(p_username));

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'Invalid credentials. User does not exist.');
    END IF;

    -- Verify password hash
    IF found_user.password_hash = crypt(p_password, found_user.password_hash) THEN
        UPDATE public.admin_users
        SET last_login = NOW()
        WHERE id = found_user.id;

        RETURN jsonb_build_object(
            'success', true,
            'user', jsonb_build_object(
                'id', found_user.id,
                'username', found_user.username,
                'email', found_user.email,
                'fullName', found_user.full_name,
                'role', found_user.role,
                'lastLogin', NOW()
            )
        );
    ELSE
        RETURN jsonb_build_object('success', false, 'message', 'Incorrect password. Access denied.');
    END IF;
END;
$$;

-- Seed default initial administrator accounts:
-- Account 1: admin / AdminPassword2026! (Head Chef)
INSERT INTO public.admin_users (username, email, full_name, password_hash, role)
VALUES (
    'admin',
    'admin@minikitchen.lk',
    'Chef Niroshan',
    crypt('AdminPassword2026!', gen_salt('bf', 10)),
    'Head Chef'
)
ON CONFLICT (username) DO NOTHING;

-- Account 2: yasasmanager / AdminPassword2026! (Restaurant Manager)
INSERT INTO public.admin_users (username, email, full_name, password_hash, role)
VALUES (
    'yasasmanager',
    'yasas@minikitchen.lk',
    'Yasas Manager',
    crypt('AdminPassword2026!', gen_salt('bf', 10)),
    'Restaurant Manager'
)
ON CONFLICT (username) DO NOTHING;

