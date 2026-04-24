-- SQLite Schema for Farmiti

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS weather_alerts;
DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS scheme_enrollments;
DROP TABLE IF EXISTS schemes;
DROP TABLE IF EXISTS price_history;
DROP TABLE IF EXISTS market_prices;
DROP TABLE IF EXISTS disease_detections;
DROP TABLE IF EXISTS crop_recommendation_history;
DROP TABLE IF EXISTS farmer_crops;
DROP TABLE IF EXISTS farm_details;
DROP TABLE IF EXISTS farmers;
DROP TABLE IF EXISTS calendar_events;

CREATE TABLE farmers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT UNIQUE NOT NULL,
  email TEXT,
  password_hash TEXT NOT NULL,
  avatar_url TEXT,
  state TEXT DEFAULT 'Tamil Nadu',
  district TEXT,
  village TEXT,
  pincode TEXT,
  gender TEXT,
  dob DATE,
  language_pref TEXT DEFAULT 'en',
  weather_sms BOOLEAN DEFAULT 0,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE farm_details (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER UNIQUE,
  land_size REAL,
  land_type TEXT,
  soil_type TEXT,
  water_source TEXT,
  primary_crop TEXT,
  bank_name TEXT,
  account_no TEXT,
  ifsc TEXT,
  aadhaar TEXT,
  latitude REAL,
  longitude REAL,
  soil_report TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE farmer_crops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  crop_name TEXT NOT NULL,
  acres REAL,
  season TEXT,
  status TEXT DEFAULT 'Growing',
  planted_at DATE,
  expected_harvest DATE,
  notes TEXT,
  img_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE crop_recommendation_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  soil_type TEXT,
  area REAL,
  rainfall REAL,
  ph REAL,
  season TEXT,
  irrigation TEXT,
  recommendations TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE disease_detections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  image_url TEXT,
  crop_name TEXT,
  disease_name TEXT,
  confidence REAL,
  severity TEXT,
  analysis_result TEXT,
  treatment_status TEXT DEFAULT 'Pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE market_prices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  crop_name TEXT NOT NULL,
  category TEXT,
  price REAL,
  prev_price REAL,
  unit TEXT DEFAULT '₹/Qtl',
  market TEXT,
  state TEXT,
  img_url TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE price_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  crop_id INTEGER,
  price REAL,
  recorded_at DATE,
  FOREIGN KEY (crop_id) REFERENCES market_prices(id) ON DELETE CASCADE
);

CREATE TABLE schemes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  full_name TEXT,
  category TEXT,
  amount TEXT,
  ministry TEXT,
  deadline TEXT,
  description TEXT,
  requirements TEXT,
  benefits TEXT,
  website_url TEXT,
  img_url TEXT,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE scheme_enrollments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  scheme_id INTEGER,
  status TEXT DEFAULT 'applied',
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT,
  UNIQUE(farmer_id, scheme_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE,
  FOREIGN KEY (scheme_id) REFERENCES schemes(id)
);

CREATE TABLE chat_messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE weather_alerts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  type TEXT,
  title TEXT,
  description TEXT,
  severity TEXT,
  area TEXT,
  actions TEXT,
  is_read BOOLEAN DEFAULT 0,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE calendar_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  event_date DATE NOT NULL,
  start_time TEXT,
  end_time TEXT,
  description TEXT,
  type TEXT,
  status TEXT DEFAULT 'upcoming',
  reminder_mins INTEGER DEFAULT 10,
  notified BOOLEAN DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);

CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  farmer_id INTEGER,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  link TEXT,
  data TEXT,
  is_read BOOLEAN DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id) REFERENCES farmers(id) ON DELETE CASCADE
);
