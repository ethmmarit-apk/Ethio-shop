-- Ethio Marketplace Database Schema

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table with Ethiopian-specific fields
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    phone_verified BOOLEAN DEFAULT FALSE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) CHECK (user_type IN ('buyer', 'seller', 'admin')) NOT NULL,
    
    -- Ethiopian address
    region VARCHAR(100),
    city VARCHAR(100),
    subcity VARCHAR(100),
    woreda VARCHAR(50),
    kebele VARCHAR(50),
    house_number VARCHAR(50),
    
    profile_image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INTEGER DEFAULT 0,
    verification_status VARCHAR(20) DEFAULT 'pending',
    
    password_hash TEXT NOT NULL,
    fcm_token TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    
    INDEX idx_user_email (email),
    INDEX idx_user_phone (phone),
    INDEX idx_user_type (user_type)
);

-- Categories table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_en VARCHAR(100) NOT NULL,
    name_am VARCHAR(100),
    description TEXT,
    icon_url TEXT,
    parent_category_id UUID REFERENCES categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES users(id) NOT NULL,
    category_id UUID REFERENCES categories(id) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price_etb DECIMAL(12,2) NOT NULL,
    
    condition VARCHAR(50) CHECK (condition IN ('new', 'used_like_new', 'used_good', 'used_fair')),
    location_region VARCHAR(100),
    location_city VARCHAR(100),
    
    quantity INTEGER DEFAULT 1,
    is_negotiable BOOLEAN DEFAULT TRUE,
    delivery_available BOOLEAN DEFAULT FALSE,
    delivery_fee_etb DECIMAL(8,2) DEFAULT 0,
    
    primary_image_url TEXT NOT NULL,
    image_urls TEXT[],
    
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'sold', 'reserved', 'inactive')),
    
    view_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_product_seller (seller_id),
    INDEX idx_product_category (category_id),
    INDEX idx_product_status (status)
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    buyer_id UUID REFERENCES users(id) NOT NULL,
    seller_id UUID REFERENCES users(id) NOT NULL,
    
    total_amount_etb DECIMAL(12,2) NOT NULL,
    delivery_fee_etb DECIMAL(8,2) DEFAULT 0,
    tax_amount_etb DECIMAL(10,2) DEFAULT 0,
    grand_total_etb DECIMAL(12,2) NOT NULL,
    
    delivery_region VARCHAR(100),
    delivery_city VARCHAR(100),
    delivery_subcity VARCHAR(100),
    delivery_woreda VARCHAR(50),
    delivery_kebele VARCHAR(50),
    delivery_house_number VARCHAR(50),
    delivery_phone VARCHAR(20),
    
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN (
        'pending', 'confirmed', 'processing', 'shipped', 
        'delivered', 'cancelled', 'refunded'
    )),
    
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    payment_reference TEXT,
    
    notes TEXT,
    cancelled_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_order_buyer (buyer_id),
    INDEX idx_order_seller (seller_id),
    INDEX idx_order_status (status)
);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price_etb DECIMAL(12,2) NOT NULL,
    subtotal_etb DECIMAL(12,2) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Chat conversations
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id),
    buyer_id UUID REFERENCES users(id) NOT NULL,
    seller_id UUID REFERENCES users(id) NOT NULL,
    last_message TEXT,
    last_message_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(product_id, buyer_id, seller_id)
);

-- Chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES chat_conversations(id) NOT NULL,
    sender_id UUID REFERENCES users(id) NOT NULL,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    reviewer_id UUID REFERENCES users(id) NOT NULL,
    reviewed_user_id UUID REFERENCES users(id) NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(order_id, reviewer_id)
);

-- Favorites
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, product_id)
);

-- Insert sample categories
INSERT INTO categories (name_en, name_am, description) VALUES
('Electronics', 'ኤሌክትሮኒክስ', 'Phones, computers, electronics'),
('Fashion', 'ፋሽን', 'Clothing, shoes, accessories'),
('Home & Garden', 'ቤት እና አትክልት', 'Furniture, home decor'),
('Vehicles', 'ተሽከርካሪዎች', 'Cars, motorcycles, bicycles'),
('Real Estate', 'ሪል እስቴት', 'Houses, apartments, land'),
('Jobs', 'ስራዎች', 'Employment opportunities'),
('Services', 'አገልግሎቶች', 'Professional services'),
('Agriculture', 'ግብርና', 'Farm equipment, animals, crops');

-- Insert sample admin user (password: Admin123!)
INSERT INTO users (email, phone, first_name, last_name, user_type, password_hash) VALUES
('admin@ethiomarketplace.com', '+251911111111', 'Admin', 'User', 'admin', '$2a$10$YourHashedPasswordHere');