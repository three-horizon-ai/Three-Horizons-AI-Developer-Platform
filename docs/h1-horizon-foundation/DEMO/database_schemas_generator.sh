#!/bin/bash
# 🗄️ Database Schemas & Migration Generator
# Creates database schemas, migrations, and seed data

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Create PostgreSQL schemas and migrations
create_postgresql_schemas() {
    log "Creating PostgreSQL schemas and migrations..."
    
    local DATA_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/data/sql"
    
    # Main schema file
    cat > "$DATA_DIR/schema.sql" << 'EOF'
-- {{values.name | title}} E-commerce Platform Database Schema
-- PostgreSQL version 15+

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create schemas for different services
CREATE SCHEMA IF NOT EXISTS users;
CREATE SCHEMA IF NOT EXISTS orders;
CREATE SCHEMA IF NOT EXISTS payments;
CREATE SCHEMA IF NOT EXISTS notifications;

-- ============================================================================
-- USERS SCHEMA
-- ============================================================================

-- Users table
CREATE TABLE users.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    avatar_url TEXT,
    
    -- Authentication
    password_hash VARCHAR(255),
    email_verified BOOLEAN DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    password_reset_token VARCHAR(255),
    password_reset_expires TIMESTAMPTZ,
    
    -- Profile
    preferences JSONB DEFAULT '{}',
    shipping_addresses JSONB DEFAULT '[]',
    billing_addresses JSONB DEFAULT '[]',
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'moderator')),
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ,
    login_count INTEGER DEFAULT 0,
    
    -- Search
    search_vector TSVECTOR
);

-- User sessions table
CREATE TABLE users.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users.users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User preferences table
CREATE TABLE users.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users.users(id) ON DELETE CASCADE,
    language VARCHAR(10) DEFAULT '{{values.frontend.language}}',
    currency VARCHAR(3) DEFAULT 'USD',
    timezone VARCHAR(50) DEFAULT 'UTC',
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    marketing_emails BOOLEAN DEFAULT FALSE,
    theme VARCHAR(20) DEFAULT 'system' CHECK (theme IN ('light', 'dark', 'system')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- ORDERS SCHEMA
-- ============================================================================

-- Orders table
CREATE TABLE orders.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id UUID NOT NULL,
    
    -- Order details
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    currency VARCHAR(3) DEFAULT 'USD',
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Addresses
    shipping_address JSONB NOT NULL,
    billing_address JSONB NOT NULL,
    
    -- Metadata
    notes TEXT,
    internal_notes TEXT,
    tracking_number VARCHAR(100),
    shipping_carrier VARCHAR(50),
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    estimated_delivery TIMESTAMPTZ
);

-- Order items table
CREATE TABLE orders.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    
    -- Product details (snapshot at time of order)
    product_id VARCHAR(100) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    product_sku VARCHAR(100),
    product_image TEXT,
    variant_info JSONB,
    
    -- Pricing
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order history/events table
CREATE TABLE orders.order_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders.orders(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    description TEXT,
    metadata JSONB,
    created_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- PAYMENTS SCHEMA
-- ============================================================================

-- Payment methods table
CREATE TABLE payments.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'pix')),
    
    -- Card details (encrypted/tokenized)
    last_four VARCHAR(4),
    brand VARCHAR(20),
    exp_month INTEGER,
    exp_year INTEGER,
    
    -- External references
    provider VARCHAR(20) NOT NULL, -- stripe, paypal, etc.
    provider_payment_method_id VARCHAR(255),
    
    -- Status
    is_default BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired')),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    payment_method_id UUID REFERENCES payments.payment_methods(id),
    
    -- Payment details
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded')),
    
    -- Provider details
    provider VARCHAR(20) NOT NULL,
    provider_payment_id VARCHAR(255),
    provider_payment_intent_id VARCHAR(255),
    
    -- Metadata
    failure_reason TEXT,
    refund_reason TEXT,
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ
);

-- Payment events table
CREATE TABLE payments.payment_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL REFERENCES payments.payments(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    provider_event_id VARCHAR(255),
    raw_data JSONB,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- NOTIFICATIONS SCHEMA
-- ============================================================================

-- Notification templates table
CREATE TABLE notifications.notification_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('email', 'sms', 'push', 'in_app')),
    subject_template TEXT,
    body_template TEXT NOT NULL,
    variables JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications queue table
CREATE TABLE notifications.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    template_id UUID REFERENCES notifications.notification_templates(id),
    
    -- Content
    type VARCHAR(20) NOT NULL CHECK (type IN ('email', 'sms', 'push', 'in_app')),
    recipient VARCHAR(255) NOT NULL,
    subject TEXT,
    body TEXT NOT NULL,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'sending', 'sent', 'failed', 'cancelled')),
    priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    
    -- Scheduling
    scheduled_at TIMESTAMPTZ DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    
    -- Metadata
    metadata JSONB,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users.users(email);
CREATE INDEX idx_users_status ON users.users(status);
CREATE INDEX idx_users_created_at ON users.users(created_at);
CREATE INDEX idx_users_search_vector ON users.users USING GIN(search_vector);
CREATE INDEX idx_user_sessions_token ON users.user_sessions(session_token);
CREATE INDEX idx_user_sessions_user_id ON users.user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires ON users.user_sessions(expires_at);

-- Orders indexes
CREATE INDEX idx_orders_user_id ON orders.orders(user_id);
CREATE INDEX idx_orders_status ON orders.orders(status);
CREATE INDEX idx_orders_created_at ON orders.orders(created_at);
CREATE INDEX idx_orders_order_number ON orders.orders(order_number);
CREATE INDEX idx_order_items_order_id ON orders.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON orders.order_items(product_id);
CREATE INDEX idx_order_events_order_id ON orders.order_events(order_id);
CREATE INDEX idx_order_events_created_at ON orders.order_events(created_at);

-- Payments indexes
CREATE INDEX idx_payment_methods_user_id ON payments.payment_methods(user_id);
CREATE INDEX idx_payment_methods_status ON payments.payment_methods(status);
CREATE INDEX idx_payments_order_id ON payments.payments(order_id);
CREATE INDEX idx_payments_status ON payments.payments(status);
CREATE INDEX idx_payments_created_at ON payments.payments(created_at);
CREATE INDEX idx_payment_events_payment_id ON payments.payment_events(payment_id);
CREATE INDEX idx_payment_events_processed ON payments.payment_events(processed);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications.notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications.notifications(status);
CREATE INDEX idx_notifications_scheduled_at ON notifications.notifications(scheduled_at);
CREATE INDEX idx_notifications_type ON notifications.notifications(type);

-- ============================================================================
-- TRIGGERS AND FUNCTIONS
-- ============================================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create update triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON users.user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders.orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_order_items_updated_at BEFORE UPDATE ON orders.order_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON payments.payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notification_templates_updated_at BEFORE UPDATE ON notifications.notification_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications.notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Search vector update trigger for users
CREATE OR REPLACE FUNCTION update_user_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := to_tsvector('english', 
        COALESCE(NEW.first_name, '') || ' ' ||
        COALESCE(NEW.last_name, '') || ' ' ||
        COALESCE(NEW.email, '')
    );
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_search_vector_trigger 
    BEFORE INSERT OR UPDATE ON users.users 
    FOR EACH ROW EXECUTE FUNCTION update_user_search_vector();

-- Order number generation function
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                           LPAD(EXTRACT(EPOCH FROM NOW())::text, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER generate_order_number_trigger 
    BEFORE INSERT ON orders.orders 
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Order summary view
CREATE VIEW orders.order_summary AS
SELECT 
    o.id,
    o.order_number,
    o.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email AS customer_email,
    o.status,
    o.total_amount,
    o.currency,
    o.created_at,
    o.updated_at,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity) AS total_quantity
FROM orders.orders o
LEFT JOIN users.users u ON o.user_id = u.id
LEFT JOIN orders.order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.first_name, u.last_name, u.email;

-- Payment summary view
CREATE VIEW payments.payment_summary AS
SELECT 
    p.id,
    p.order_id,
    o.order_number,
    p.amount,
    p.currency,
    p.status,
    p.provider,
    p.created_at,
    p.processed_at
FROM payments.payments p
LEFT JOIN orders.orders o ON p.order_id = o.id;

-- ============================================================================
-- INITIAL DATA
-- ============================================================================

-- Insert notification templates
INSERT INTO notifications.notification_templates (name, type, subject_template, body_template, variables) VALUES
('welcome_email', 'email', 'Welcome to {{values.name | title}}!', 'Hello {{first_name}}, welcome to our platform!', '["first_name"]'),
('order_confirmation', 'email', 'Order Confirmation - {{order_number}}', 'Your order {{order_number}} has been confirmed. Total: {{total_amount}}', '["order_number", "total_amount"]'),
('order_shipped', 'email', 'Your Order Has Shipped - {{order_number}}', 'Your order {{order_number}} has been shipped. Tracking: {{tracking_number}}', '["order_number", "tracking_number"]'),
('payment_failed', 'email', 'Payment Failed - {{order_number}}', 'Payment for order {{order_number}} failed. Please update your payment method.', '["order_number"]'),
('password_reset', 'email', 'Reset Your Password', 'Click here to reset your password: {{reset_link}}', '["reset_link"]');

-- Create admin user
INSERT INTO users.users (id, email, first_name, last_name, role, email_verified, status) VALUES
('00000000-0000-0000-0000-000000000001', 'admin@{{values.name}}.com', 'Admin', 'User', 'admin', TRUE, 'active');

-- Create demo user
INSERT INTO users.users (id, email, first_name, last_name, role, email_verified, status) VALUES
('00000000-0000-0000-0000-000000000002', 'demo@{{values.name}}.com', 'Demo', 'User', 'customer', TRUE, 'active');
EOF

    # Seed data file
    cat > "$DATA_DIR/seed.sql" << 'EOF'
-- {{values.name | title}} E-commerce Platform Seed Data
-- Demo data for development and testing

-- Sample users
INSERT INTO users.users (email, first_name, last_name, role, email_verified, status, created_at) VALUES
('sarah.chen@example.com', 'Sarah', 'Chen', 'customer', TRUE, 'active', NOW() - INTERVAL '30 days'),
('mike.rodriguez@example.com', 'Mike', 'Rodriguez', 'customer', TRUE, 'active', NOW() - INTERVAL '15 days'),
('lisa.thompson@example.com', 'Lisa', 'Thompson', 'customer', TRUE, 'active', NOW() - INTERVAL '7 days'),
('john.doe@example.com', 'John', 'Doe', 'customer', TRUE, 'active', NOW() - INTERVAL '3 days'),
('jane.smith@example.com', 'Jane', 'Smith', 'customer', TRUE, 'active', NOW() - INTERVAL '1 day');

-- Sample orders
WITH sample_users AS (
    SELECT id, email FROM users.users WHERE email LIKE '%@example.com'
),
sample_orders AS (
    INSERT INTO orders.orders (
        user_id, 
        status, 
        subtotal, 
        tax_amount, 
        shipping_amount, 
        total_amount,
        shipping_address,
        billing_address,
        created_at
    )
    SELECT 
        u.id,
        CASE 
            WHEN random() < 0.7 THEN 'delivered'
            WHEN random() < 0.8 THEN 'shipped'
            WHEN random() < 0.9 THEN 'processing'
            ELSE 'pending'
        END,
        ROUND((random() * 200 + 50)::numeric, 2),
        ROUND((random() * 20 + 5)::numeric, 2),
        ROUND((random() * 15 + 5)::numeric, 2),
        ROUND((random() * 235 + 60)::numeric, 2),
        '{"street": "123 Main St", "city": "San Francisco", "state": "CA", "zip": "94105", "country": "US"}',
        '{"street": "123 Main St", "city": "San Francisco", "state": "CA", "zip": "94105", "country": "US"}',
        NOW() - (random() * INTERVAL '30 days')
    FROM sample_users u
    CROSS JOIN generate_series(1, 3) -- 3 orders per user
    RETURNING id, total_amount
)
-- Sample order items
INSERT INTO orders.order_items (
    order_id,
    product_id,
    product_name,
    product_sku,
    unit_price,
    quantity,
    total_amount
)
SELECT 
    so.id,
    'prod_' || (random() * 1000)::int,
    CASE (random() * 10)::int
        WHEN 0 THEN 'Laptop Pro 16"'
        WHEN 1 THEN 'Wireless Headphones'
        WHEN 2 THEN 'Smart Watch'
        WHEN 3 THEN 'Coffee Mug'
        WHEN 4 THEN 'Developer T-Shirt'
        WHEN 5 THEN 'Mechanical Keyboard'
        WHEN 6 THEN '4K Monitor'
        WHEN 7 THEN 'Desk Lamp'
        WHEN 8 THEN 'Backpack'
        ELSE 'Book: Cloud Native'
    END,
    'SKU' || (random() * 10000)::int,
    ROUND((random() * 100 + 10)::numeric, 2),
    (random() * 3 + 1)::int,
    ROUND((so.total_amount / 2)::numeric, 2)
FROM sample_orders so;

-- Sample payments
INSERT INTO payments.payments (
    order_id,
    amount,
    status,
    provider,
    provider_payment_id,
    processed_at
)
SELECT 
    o.id,
    o.total_amount,
    CASE o.status
        WHEN 'delivered' THEN 'succeeded'
        WHEN 'shipped' THEN 'succeeded'
        WHEN 'processing' THEN 'succeeded'
        ELSE 'pending'
    END,
    'stripe',
    'pi_' || substr(md5(random()::text), 1, 16),
    CASE o.status
        WHEN 'pending' THEN NULL
        ELSE o.created_at + INTERVAL '5 minutes'
    END
FROM orders.orders o;

-- Sample notifications
INSERT INTO notifications.notifications (
    user_id,
    template_id,
    type,
    recipient,
    subject,
    body,
    status,
    sent_at
)
SELECT 
    u.id,
    nt.id,
    'email',
    u.email,
    'Welcome to {{values.name | title}}!',
    'Hello ' || u.first_name || ', welcome to our platform!',
    'sent',
    u.created_at + INTERVAL '1 hour'
FROM users.users u
CROSS JOIN notifications.notification_templates nt
WHERE nt.name = 'welcome_email'
AND u.email LIKE '%@example.com';

-- Sample order events
INSERT INTO orders.order_events (order_id, event_type, description, metadata)
SELECT 
    o.id,
    'status_change',
    'Order status changed to ' || o.status,
    json_build_object('previous_status', 'pending', 'new_status', o.status)
FROM orders.orders o
WHERE o.status != 'pending';

-- Update statistics
ANALYZE users.users;
ANALYZE orders.orders;
ANALYZE orders.order_items;
ANALYZE payments.payments;
ANALYZE notifications.notifications;
EOF

    success "PostgreSQL schemas and seed data created successfully!"
}

# Create MongoDB schemas and seed data
create_mongodb_schemas() {
    log "Creating MongoDB schemas and seed data..."
    
    local MONGO_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/data/mongo"
    
    # MongoDB initialization script
    cat > "$MONGO_DIR/init.js" << 'EOF'
// {{values.name | title}} E-commerce Platform MongoDB Initialization
// Database: {{values.name}}_catalog

// Switch to the catalog database
db = db.getSiblingDB('{{values.name}}_catalog');

// Create collections with validation schemas
db.createCollection('categories', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'slug', 'isActive'],
      properties: {
        name: {
          bsonType: 'string',
          description: 'Category name is required'
        },
        slug: {
          bsonType: 'string',
          pattern: '^[a-z0-9-]+$',
          description: 'Slug must be lowercase with hyphens'
        },
        description: {
          bsonType: 'string'
        },
        image: {
          bsonType: 'string'
        },
        parentCategory: {
          bsonType: 'objectId'
        },
        isActive: {
          bsonType: 'bool'
        },
        sortOrder: {
          bsonType: 'int'
        },
        metadata: {
          bsonType: 'object'
        }
      }
    }
  }
});

db.createCollection('products', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'slug', 'price', 'categoryId', 'isActive'],
      properties: {
        name: {
          bsonType: 'string',
          description: 'Product name is required'
        },
        slug: {
          bsonType: 'string',
          pattern: '^[a-z0-9-]+$'
        },
        description: {
          bsonType: 'string'
        },
        shortDescription: {
          bsonType: 'string'
        },
        price: {
          bsonType: 'number',
          minimum: 0
        },
        compareAtPrice: {
          bsonType: 'number',
          minimum: 0
        },
        images: {
          bsonType: 'array',
          items: {
            bsonType: 'string'
          }
        },
        categoryId: {
          bsonType: 'objectId'
        },
        categoryName: {
          bsonType: 'string'
        },
        stock: {
          bsonType: 'int',
          minimum: 0
        },
        sku: {
          bsonType: 'string'
        },
        rating: {
          bsonType: 'number',
          minimum: 0,
          maximum: 5
        },
        reviewCount: {
          bsonType: 'int',
          minimum: 0
        },
        tags: {
          bsonType: 'array',
          items: {
            bsonType: 'string'
          }
        },
        variants: {
          bsonType: 'array'
        },
        specifications: {
          bsonType: 'object'
        },
        isActive: {
          bsonType: 'bool'
        },
        isFeatured: {
          bsonType: 'bool'
        },
        weight: {
          bsonType: 'number'
        },
        dimensions: {
          bsonType: 'object'
        }
      }
    }
  }
});

db.createCollection('product_reviews', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['productId', 'userId', 'rating', 'title', 'content'],
      properties: {
        productId: {
          bsonType: 'objectId'
        },
        userId: {
          bsonType: 'string'
        },
        userName: {
          bsonType: 'string'
        },
        rating: {
          bsonType: 'int',
          minimum: 1,
          maximum: 5
        },
        title: {
          bsonType: 'string'
        },
        content: {
          bsonType: 'string'
        },
        helpful: {
          bsonType: 'int',
          minimum: 0
        },
        verified: {
          bsonType: 'bool'
        },
        images: {
          bsonType: 'array'
        }
      }
    }
  }
});

// Create indexes
db.categories.createIndex({ slug: 1 }, { unique: true });
db.categories.createIndex({ name: 1 });
db.categories.createIndex({ isActive: 1, sortOrder: 1 });
db.categories.createIndex({ parentCategory: 1, isActive: 1 });

db.products.createIndex({ slug: 1 }, { unique: true });
db.products.createIndex({ sku: 1 }, { unique: true });
db.products.createIndex({ name: "text", description: "text", tags: "text" });
db.products.createIndex({ categoryId: 1, isActive: 1 });
db.products.createIndex({ price: 1 });
db.products.createIndex({ rating: -1 });
db.products.createIndex({ isFeatured: -1, createdAt: -1 });
db.products.createIndex({ isActive: 1, stock: 1 });
db.products.createIndex({ tags: 1 });

db.product_reviews.createIndex({ productId: 1, createdAt: -1 });
db.product_reviews.createIndex({ userId: 1 });
db.product_reviews.createIndex({ rating: 1 });
db.product_reviews.createIndex({ verified: 1 });

print('✅ Collections and indexes created successfully');
EOF

    # Seed data script
    cat > "$MONGO_DIR/seed.js" << 'EOF'
// {{values.name | title}} E-commerce Platform MongoDB Seed Data

db = db.getSiblingDB('{{values.name}}_catalog');

// Insert categories
const categories = [
  {
    _id: ObjectId(),
    name: 'Electronics',
    slug: 'electronics',
    description: 'Latest electronic devices and gadgets',
    image: '/images/categories/electronics.jpg',
    isActive: true,
    sortOrder: 1,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Books',
    slug: 'books',
    description: 'Technical books and learning resources',
    image: '/images/categories/books.jpg',
    isActive: true,
    sortOrder: 2,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Apparel',
    slug: 'apparel',
    description: 'Clothing and accessories',
    image: '/images/categories/apparel.jpg',
    isActive: true,
    sortOrder: 3,
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Office',
    slug: 'office',
    description: 'Office supplies and equipment',
    image: '/images/categories/office.jpg',
    isActive: true,
    sortOrder: 4,
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

db.categories.insertMany(categories);

// Get category IDs for products
const electronicsCategory = db.categories.findOne({ slug: 'electronics' });
const booksCategory = db.categories.findOne({ slug: 'books' });
const apparelCategory = db.categories.findOne({ slug: 'apparel' });
const officeCategory = db.categories.findOne({ slug: 'office' });

// Insert products
const products = [
  {
    _id: ObjectId(),
    name: 'Laptop Pro 16"',
    slug: 'laptop-pro-16',
    description: 'High-performance laptop for developers and designers. Features the latest processor, ample RAM, and a stunning display perfect for coding and creative work.',
    shortDescription: 'High-performance laptop for developers',
    price: 2499.99,
    compareAtPrice: 2799.99,
    images: [
      '/images/products/laptop-pro-1.jpg',
      '/images/products/laptop-pro-2.jpg',
      '/images/products/laptop-pro-3.jpg'
    ],
    categoryId: electronicsCategory._id,
    categoryName: 'Electronics',
    stock: 50,
    sku: 'LAPTOP-PRO-16',
    rating: 4.8,
    reviewCount: 127,
    tags: ['laptop', 'computer', 'developer', 'high-performance'],
    specifications: {
      'Processor': 'M2 Pro chip',
      'Memory': '16GB unified memory',
      'Storage': '512GB SSD',
      'Display': '16-inch Liquid Retina XDR',
      'Graphics': 'Integrated graphics',
      'Weight': '2.1 kg'
    },
    isActive: true,
    isFeatured: true,
    weight: 2.1,
    dimensions: {
      length: 35.57,
      width: 24.81,
      height: 1.68
    },
    createdAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Wireless Headphones',
    slug: 'wireless-headphones',
    description: 'Premium noise-canceling wireless headphones with exceptional sound quality and all-day battery life.',
    shortDescription: 'Premium noise-canceling headphones',
    price: 299.99,
    compareAtPrice: 349.99,
    images: [
      '/images/products/headphones-1.jpg',
      '/images/products/headphones-2.jpg'
    ],
    categoryId: electronicsCategory._id,
    categoryName: 'Electronics',
    stock: 100,
    sku: 'HEADPHONES-WL-01',
    rating: 4.6,
    reviewCount: 89,
    tags: ['headphones', 'wireless', 'noise-canceling', 'audio'],
    specifications: {
      'Battery Life': '30 hours',
      'Connectivity': 'Bluetooth 5.0',
      'Noise Canceling': 'Active',
      'Weight': '250g',
      'Frequency Response': '20Hz - 20kHz'
    },
    isActive: true,
    isFeatured: true,
    weight: 0.25,
    createdAt: new Date(Date.now() - 25 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Smart Watch',
    slug: 'smart-watch',
    description: 'Advanced fitness tracking smartwatch with health monitoring, GPS, and smartphone integration.',
    shortDescription: 'Advanced fitness tracking smartwatch',
    price: 399.99,
    images: [
      '/images/products/smartwatch-1.jpg',
      '/images/products/smartwatch-2.jpg'
    ],
    categoryId: electronicsCategory._id,
    categoryName: 'Electronics',
    stock: 75,
    sku: 'WATCH-SMART-01',
    rating: 4.4,
    reviewCount: 156,
    tags: ['smartwatch', 'fitness', 'health', 'gps'],
    variants: [
      {
        name: 'Black Sport Band',
        price: 399.99,
        sku: 'WATCH-SMART-01-BLK',
        stock: 40
      },
      {
        name: 'White Sport Band',
        price: 399.99,
        sku: 'WATCH-SMART-01-WHT',
        stock: 35
      }
    ],
    specifications: {
      'Display': '1.9" Retina',
      'Battery Life': '18 hours',
      'Water Resistance': '50 meters',
      'Sensors': 'Heart rate, GPS, Accelerometer',
      'Compatibility': 'iOS and Android'
    },
    isActive: true,
    isFeatured: false,
    weight: 0.045,
    createdAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Three Horizons Coffee Mug',
    slug: 'three-horizons-mug',
    description: 'Premium ceramic coffee mug featuring the Three Horizons logo. Perfect for your morning coffee while coding.',
    shortDescription: 'Three Horizons branded coffee mug',
    price: 19.99,
    images: [
      '/images/products/mug-1.jpg',
      '/images/products/mug-2.jpg'
    ],
    categoryId: officeCategory._id,
    categoryName: 'Office',
    stock: 200,
    sku: 'MUG-TH-01',
    rating: 4.9,
    reviewCount: 45,
    tags: ['mug', 'coffee', 'three-horizons', 'merchandise'],
    specifications: {
      'Material': 'Ceramic',
      'Capacity': '350ml',
      'Dishwasher Safe': 'Yes',
      'Microwave Safe': 'Yes'
    },
    isActive: true,
    isFeatured: false,
    weight: 0.3,
    createdAt: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Developer T-Shirt',
    slug: 'developer-tshirt',
    description: 'Comfortable cotton t-shirt with developer-inspired design. Available in multiple sizes.',
    shortDescription: 'Developer lifestyle t-shirt',
    price: 29.99,
    images: [
      '/images/products/tshirt-1.jpg',
      '/images/products/tshirt-2.jpg'
    ],
    categoryId: apparelCategory._id,
    categoryName: 'Apparel',
    stock: 150,
    sku: 'TSHIRT-DEV-01',
    rating: 4.5,
    reviewCount: 78,
    tags: ['tshirt', 'developer', 'coding', 'apparel'],
    variants: [
      { name: 'Small', price: 29.99, sku: 'TSHIRT-DEV-01-S', stock: 30 },
      { name: 'Medium', price: 29.99, sku: 'TSHIRT-DEV-01-M', stock: 50 },
      { name: 'Large', price: 29.99, sku: 'TSHIRT-DEV-01-L', stock: 40 },
      { name: 'XL', price: 29.99, sku: 'TSHIRT-DEV-01-XL', stock: 30 }
    ],
    specifications: {
      'Material': '100% Cotton',
      'Fit': 'Regular',
      'Care': 'Machine wash cold'
    },
    isActive: true,
    isFeatured: false,
    weight: 0.2,
    createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  },
  {
    _id: ObjectId(),
    name: 'Cloud Native Development Guide',
    slug: 'cloud-native-book',
    description: 'Comprehensive guide to cloud-native development practices, covering containers, microservices, and DevOps.',
    shortDescription: 'Guide to cloud-native development',
    price: 49.99,
    images: [
      '/images/products/book-1.jpg'
    ],
    categoryId: booksCategory._id,
    categoryName: 'Books',
    stock: 80,
    sku: 'BOOK-CN-01',
    rating: 4.7,
    reviewCount: 23,
    tags: ['book', 'cloud-native', 'development', 'devops'],
    specifications: {
      'Pages': '450',
      'Format': 'Paperback',
      'Language': 'English',
      'Publisher': 'Tech Publications'
    },
    isActive: true,
    isFeatured: true,
    weight: 0.6,
    createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
    updatedAt: new Date()
  }
];

db.products.insertMany(products);

// Insert sample reviews
const sampleProducts = db.products.find().toArray();
const reviews = [];

sampleProducts.forEach(product => {
  const reviewCount = Math.floor(Math.random() * 5) + 1;
  for (let i = 0; i < reviewCount; i++) {
    reviews.push({
      _id: ObjectId(),
      productId: product._id,
      userId: 'user_' + Math.floor(Math.random() * 1000),
      userName: ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Brown', 'Charlie Wilson'][Math.floor(Math.random() * 5)],
      rating: Math.floor(Math.random() * 2) + 4, // 4 or 5 stars
      title: ['Great product!', 'Excellent quality', 'Highly recommended', 'Love it!', 'Perfect for my needs'][Math.floor(Math.random() * 5)],
      content: 'This is a sample review for the product. The quality is excellent and I would recommend it to others.',
      helpful: Math.floor(Math.random() * 20),
      verified: Math.random() > 0.3,
      createdAt: new Date(Date.now() - Math.floor(Math.random() * 30) * 24 * 60 * 60 * 1000),
      updatedAt: new Date()
    });
  }
});

if (reviews.length > 0) {
  db.product_reviews.insertMany(reviews);
}

print('✅ Seed data inserted successfully');
print('Categories:', db.categories.countDocuments());
print('Products:', db.products.countDocuments());
print('Reviews:', db.product_reviews.countDocuments());
EOF

    success "MongoDB schemas and seed data created successfully!"
}

# Create database migration scripts
create_migration_scripts() {
    log "Creating database migration scripts..."
    
    local MIGRATIONS_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/data/migrations"
    
    # Migration runner script
    cat > "$MIGRATIONS_DIR/migrate.sh" << 'EOF'
#!/bin/bash
# 🔄 Database Migration Runner for {{values.name | title}}

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }

# Configuration
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-{{values.name}}}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}

MONGO_HOST=${MONGO_HOST:-localhost}
MONGO_PORT=${MONGO_PORT:-27017}
MONGO_DB=${MONGO_DB:-{{values.name}}_catalog}
MONGO_USER=${MONGO_USER:-admin}
MONGO_PASSWORD=${MONGO_PASSWORD:-admin}

# Check if databases are accessible
check_postgres() {
    log "Checking PostgreSQL connection..."
    
    if PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c '\q' 2>/dev/null; then
        success "PostgreSQL is accessible"
        return 0
    else
        error "Cannot connect to PostgreSQL"
        return 1
    fi
}

check_mongo() {
    log "Checking MongoDB connection..."
    
    if mongosh --host $MONGO_HOST:$MONGO_PORT --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin --eval "db.runCommand('ismaster')" >/dev/null 2>&1; then
        success "MongoDB is accessible"
        return 0
    else
        error "Cannot connect to MongoDB"
        return 1
    fi
}

# Create databases if they don't exist
create_databases() {
    log "Creating databases if needed..."
    
    # Create PostgreSQL database
    PGPASSWORD=$POSTGRES_PASSWORD createdb -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_DB 2>/dev/null || true
    
    log "Databases created/verified"
}

# Run PostgreSQL migrations
migrate_postgres() {
    log "Running PostgreSQL migrations..."
    
    # Run schema creation
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -f ../sql/schema.sql
    
    # Run seed data
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -f ../sql/seed.sql
    
    success "PostgreSQL migrations completed"
}

# Run MongoDB migrations
migrate_mongo() {
    log "Running MongoDB migrations..."
    
    # Run initialization script
    mongosh --host $MONGO_HOST:$MONGO_PORT --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin ../mongo/init.js
    
    # Run seed data
    mongosh --host $MONGO_HOST:$MONGO_PORT --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin ../mongo/seed.js
    
    success "MongoDB migrations completed"
}

# Main migration function
run_migrations() {
    echo -e "${BLUE}"
    cat << 'BANNER'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🔄 Database Migration Runner                              ║
║                                                              ║
║    Initializing databases for {{values.name | title}}        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    
    # Check connections
    check_postgres || exit 1
    check_mongo || exit 1
    
    # Create databases
    create_databases
    
    # Run migrations
    migrate_postgres
    migrate_mongo
    
    success "All database migrations completed successfully!"
    
    echo -e "\n📊 Database Summary:"
    echo -e "  • PostgreSQL: $POSTGRES_DB (schemas: users, orders, payments, notifications)"
    echo -e "  • MongoDB: $MONGO_DB (collections: categories, products, reviews)"
}

# Rollback function
rollback_migrations() {
    log "Rolling back migrations..."
    
    # Drop PostgreSQL schemas
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "
        DROP SCHEMA IF EXISTS notifications CASCADE;
        DROP SCHEMA IF EXISTS payments CASCADE;
        DROP SCHEMA IF EXISTS orders CASCADE;
        DROP SCHEMA IF EXISTS users CASCADE;
    "
    
    # Drop MongoDB collections
    mongosh --host $MONGO_HOST:$MONGO_PORT --username $MONGO_USER --password $MONGO_PASSWORD --authenticationDatabase admin --eval "
        db = db.getSiblingDB('$MONGO_DB');
        db.dropDatabase();
    "
    
    success "Rollback completed"
}

# Parse command line arguments
case "${1:-migrate}" in
    "migrate"|"up")
        run_migrations
        ;;
    "rollback"|"down")
        rollback_migrations
        ;;
    "reset")
        rollback_migrations
        run_migrations
        ;;
    "check")
        check_postgres && check_mongo
        ;;
    *)
        echo "Usage: $0 [migrate|rollback|reset|check]"
        echo ""
        echo "Commands:"
        echo "  migrate   - Run all migrations (default)"
        echo "  rollback  - Rollback all migrations"
        echo "  reset     - Rollback and then migrate"
        echo "  check     - Check database connections"
        exit 1
        ;;
esac
EOF

    chmod +x "$MIGRATIONS_DIR/migrate.sh"

    # Create backup script
    cat > "$MIGRATIONS_DIR/backup.sh" << 'EOF'
#!/bin/bash
# 💾 Database Backup Script for {{values.name | title}}

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Configuration
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-{{values.name}}}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}

MONGO_HOST=${MONGO_HOST:-localhost}
MONGO_PORT=${MONGO_PORT:-27017}
MONGO_DB=${MONGO_DB:-{{values.name}}_catalog}
MONGO_USER=${MONGO_USER:-admin}
MONGO_PASSWORD=${MONGO_PASSWORD:-admin}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup PostgreSQL
backup_postgres() {
    log "Backing up PostgreSQL database..."
    
    PGPASSWORD=$POSTGRES_PASSWORD pg_dump \
        -h $POSTGRES_HOST \
        -p $POSTGRES_PORT \
        -U $POSTGRES_USER \
        -d $POSTGRES_DB \
        --verbose \
        --clean \
        --create \
        > "$BACKUP_DIR/postgres_backup.sql"
    
    success "PostgreSQL backup completed: $BACKUP_DIR/postgres_backup.sql"
}

# Backup MongoDB
backup_mongo() {
    log "Backing up MongoDB database..."
    
    mongodump \
        --host $MONGO_HOST:$MONGO_PORT \
        --username $MONGO_USER \
        --password $MONGO_PASSWORD \
        --authenticationDatabase admin \
        --db $MONGO_DB \
        --out "$BACKUP_DIR/mongo_backup"
    
    success "MongoDB backup completed: $BACKUP_DIR/mongo_backup"
}

# Main backup function
main() {
    log "Starting database backup..."
    
    backup_postgres
    backup_mongo
    
    # Create backup metadata
    cat > "$BACKUP_DIR/backup_info.txt" << INFO
Backup Information
==================
Date: $(date)
PostgreSQL Database: $POSTGRES_DB
MongoDB Database: $MONGO_DB
Backup Directory: $BACKUP_DIR

Files:
- postgres_backup.sql (PostgreSQL dump)
- mongo_backup/ (MongoDB dump directory)
INFO
    
    # Compress backup
    tar -czf "${BACKUP_DIR}.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"
    rm -rf "$BACKUP_DIR"
    
    success "Backup completed: ${BACKUP_DIR}.tar.gz"
}

main "$@"
EOF

    chmod +x "$MIGRATIONS_DIR/backup.sh"

    success "Database migration scripts created successfully!"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🗄️ Database Schemas & Migration Generator                 ║
║                                                              ║
║    Creating database schemas, migrations, and seed data     ║
║    for the Three Horizons e-commerce demo                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    create_postgresql_schemas
    create_mongodb_schemas
    create_migration_scripts
    
    success "Database schemas and migrations generated successfully!"
    
    echo -e "\n${GREEN}✅ Database configurations are ready!${NC}"
    echo -e "\n📁 Database assets created:"
    echo -e "  • PostgreSQL schemas with proper indexes and triggers"
    echo -e "  • MongoDB collections with validation schemas"
    echo -e "  • Comprehensive seed data for both databases"
    echo -e "  • Migration and backup scripts"
    echo -e "\n🚀 Ready for monitoring setup and final integration!"
    echo -e "\n📝 Next steps:"
    echo -e "  1. Run: ./data/migrations/migrate.sh"
    echo -e "  2. Verify data with: ./data/migrations/migrate.sh check"
    echo -e "  3. Continue with monitoring configuration"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi