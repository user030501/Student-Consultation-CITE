INSERT INTO users (
  id, username, password, role, display_name, course_program, year_level, email, phone, created_at
) VALUES
  ('252b0b4f-1bbc-11f1-917b-0a0027000013', 'admin', 'admin123', 'Admin', 'Administrator', NULL, NULL, NULL, NULL, '2026-03-09 13:30:31+00'),
  ('4529a56d-ca86-4f02-9774-0e58113b9764', 'stephen', 'cohay123', 'Student', 'Stephen Cohay', 'BSIT', 'Year 4', NULL, NULL, '2026-03-14 11:53:40+00'),
  ('8b978901-0d49-43fe-9bf8-46fa8f9f3b0b', 'ryan', 'ryan123', 'Adviser', 'Ryan Billera', NULL, NULL, NULL, NULL, '2026-03-21 16:23:43+00')
ON CONFLICT (username) DO NOTHING;

INSERT INTO consultations (
  id, student_id, full_name, student_number, course_program, year_level,
  phone_number, email_address, subject_class_title, consultation_date,
  consultation_time, venue, advisor_name, purpose_categories,
  detailed_concerns, issues_discussed, action_taken, recommendations,
  student_signature, faculty_signature, dean_signature, status,
  adviser_note, approved_at, completed_at, submitted_at,
  reschedule_date, reschedule_time, reschedule_note, reschedule_venue,
  adviser_recommendation
) VALUES (
  '03d6f438-e138-476e-b41f-5ba3e0d64cd9',
  '4529a56d-ca86-4f02-9774-0e58113b9764',
  'Stephen Cohay',
  '123',
  'BSIT',
  'Year 4',
  '09123',
  'qwe@gmail.com',
  '',
  '2026-03-22',
  '6:34',
  'In-person',
  'Ryan Billera',
  '["Academic Performance"]'::jsonb,
  'qwe',
  'qwe',
  'qweqw',
  'eqwe',
  'qweqw',
  '',
  NULL,
  'Rejected',
  'please reschedule',
  NULL,
  NULL,
  '2026-03-21 16:24:29+00',
  NULL,
  NULL,
  NULL,
  NULL,
  'please visit the guidance office first'
)
ON CONFLICT (id) DO NOTHING;
