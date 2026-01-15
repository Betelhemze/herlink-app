-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Profiles
CREATE TABLE profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  business_name VARCHAR(255),
  role VARCHAR(50),
  industry VARCHAR(100),
  location VARCHAR(255),
  bio TEXT,
  avatar_url VARCHAR(255),
  rating_avg DECIMAL DEFAULT 0,
  followers_count INT DEFAULT 0
);

-- Products
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255),
  description TEXT,
  price DECIMAL,
  category VARCHAR(100),
  image_url VARCHAR(255),
  rating_avg DECIMAL DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  target_id UUID, -- could be product_id or user_id
  target_type VARCHAR(50), -- "Product" or "User"
  rating INT,
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Events
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255),
  description TEXT,
  category VARCHAR(50),
  start_time TIMESTAMP,
  end_time TIMESTAMP,
  location_mode VARCHAR(50),
  location_details VARCHAR(255),
  banner_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Event Attendees
CREATE TABLE event_attendees (
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'Registered',
  PRIMARY KEY(event_id, user_id)
);

-- Collaborations
CREATE TABLE collaborations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  initiator_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255),
  description TEXT,
  type VARCHAR(50),
  status VARCHAR(50) DEFAULT 'Open',
  view_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Posts / Feed
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  image_url VARCHAR(255),
  type VARCHAR(50),
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  share_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Transactions (Mock Payments)
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL,
  currency VARCHAR(10) DEFAULT 'ETB',
  status VARCHAR(50),
  reference_id UUID,
  type VARCHAR(50), -- Product / Event
  provider VARCHAR(50) DEFAULT 'Telebirr',
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE post_likes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, user_id)
);