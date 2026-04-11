CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('Student', 'Adviser', 'Admin', 'Dean');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'consultation_status') THEN
    CREATE TYPE consultation_status AS ENUM (
      'Pending',
      'Pending Dean Approval',
      'Approved',
      'Rejected',
      'Completed',
      'Reschedule Requested'
    );
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role user_role NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  course_program VARCHAR(100),
  year_level VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(50),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS consultations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES users(id),
  full_name VARCHAR(100),
  student_number VARCHAR(50),
  course_program VARCHAR(100),
  year_level VARCHAR(50),
  phone_number VARCHAR(50),
  email_address VARCHAR(100),
  subject_class_title VARCHAR(100),
  consultation_date DATE,
  consultation_time VARCHAR(10),
  venue VARCHAR(100),
  advisor_name VARCHAR(100),
  purpose_categories JSONB NOT NULL DEFAULT '[]'::jsonb,
  detailed_concerns TEXT,
  issues_discussed TEXT,
  action_taken TEXT,
  recommendations TEXT,
  student_signature TEXT,
  faculty_signature TEXT,
  dean_signature TEXT,
  status consultation_status NOT NULL DEFAULT 'Pending',
  adviser_note TEXT,
  approved_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reschedule_date DATE,
  reschedule_time VARCHAR(10),
  reschedule_note TEXT,
  reschedule_venue VARCHAR(50),
  adviser_recommendation TEXT
);
