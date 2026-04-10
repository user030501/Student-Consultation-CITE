import cors from 'cors';
import express from 'express';
import pg from 'pg';

const { Pool } = pg;

const app = express();
const port = Number(process.env.PORT || 3000);
const connectionString =
  process.env.DATABASE_URL ||
  'postgresql://student_consultation:student_consultation@postgres:5432/student_consultation';
const corsOrigin = process.env.CORS_ORIGIN || '*';

const pool = new Pool({
  connectionString,
});

app.use(cors({ origin: corsOrigin === '*' ? true : corsOrigin }));
app.use(express.json({ limit: '2mb' }));

const adviserRoles = ['Adviser', 'Dean'];

function normalizePurposeCategories(value) {
  if (Array.isArray(value)) return value;
  if (typeof value === 'string' && value.length > 0) {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : [];
    } catch (_) {
      return [];
    }
  }
  return [];
}

function formatConsultation(row) {
  return {
    ...row,
    purpose_categories: normalizePurposeCategories(row.purpose_categories),
  };
}

async function query(text, params = []) {
  const result = await pool.query(text, params);
  return result.rows;
}

app.get('/api/health', async (_req, res) => {
  try {
    await query('SELECT 1');
    res.json({ ok: true });
  } catch (error) {
    res.status(500).json({ ok: false, error: error.message });
  }
});

app.post('/api/login', async (req, res) => {
  const username = String(req.body.username || '').trim().toLowerCase();
  const password = String(req.body.password || '').trim();

  if (!username || !password) {
    return res.status(400).json({ success: false, error: 'Username and password are required.' });
  }

  try {
    const rows = await query(
      `SELECT id, username, role, display_name, course_program, year_level
       FROM users
       WHERE LOWER(username) = $1 AND password = $2
       LIMIT 1`,
      [username, password],
    );

    if (rows.length === 0) {
      return res.json({ success: false, error: 'Invalid username or password.' });
    }

    return res.json({ success: true, user: rows[0] });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/register', async (req, res) => {
  const username = String(req.body.username || '').trim().toLowerCase();
  const password = String(req.body.password || '').trim();
  const role = String(req.body.role || '').trim() || 'Student';
  const displayName = String(req.body.display_name || '').trim();

  if (!username || !password || !displayName) {
    return res.status(400).json({ success: false, error: 'Username, password, and display name are required.' });
  }

  try {
    const rows = await query(
      `INSERT INTO users (
         username, password, role, display_name, course_program, year_level, email, phone
       ) VALUES ($1, $2, $3, $4, NULLIF($5, ''), NULLIF($6, ''), NULLIF($7, ''), NULLIF($8, ''))
       RETURNING id, username, role, display_name, course_program, year_level`,
      [
        username,
        password,
        role,
        displayName,
        String(req.body.course_program || '').trim(),
        String(req.body.year_level || '').trim(),
        String(req.body.email || '').trim(),
        String(req.body.phone || '').trim(),
      ],
    );

    return res.status(201).json({ success: true, user: rows[0] });
  } catch (error) {
    const duplicate = error.code === '23505';
    return res.status(duplicate ? 409 : 500).json({
      success: false,
      error: duplicate ? 'Username already exists.' : error.message,
    });
  }
});

app.get('/api/advisers', async (_req, res) => {
  try {
    const rows = await query(
      `SELECT id, username, role, display_name, course_program, year_level
       FROM users
       WHERE role = ANY($1::user_role[])
       ORDER BY display_name`,
      [adviserRoles],
    );
    return res.json({ data: rows });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.get('/api/consultations', async (_req, res) => {
  try {
    const rows = await query(
      `SELECT id, student_id, full_name, student_number, course_program, year_level,
              phone_number, email_address, subject_class_title, consultation_date,
              consultation_time, venue, advisor_name, purpose_categories,
              detailed_concerns, issues_discussed, action_taken, recommendations,
              student_signature, faculty_signature, dean_signature, status,
              adviser_note, approved_at, completed_at, submitted_at,
              reschedule_date, reschedule_time, reschedule_note, reschedule_venue,
              adviser_recommendation
       FROM consultations
       ORDER BY submitted_at DESC`,
    );
    return res.json({ data: rows.map(formatConsultation) });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.post('/api/consultations', async (req, res) => {
  const payload = req.body;

  try {
    const rows = await query(
      `INSERT INTO consultations (
         student_id, full_name, student_number, course_program, year_level,
         phone_number, email_address, subject_class_title, consultation_date,
         consultation_time, venue, advisor_name, purpose_categories,
         detailed_concerns, issues_discussed, action_taken, recommendations,
         student_signature, faculty_signature, dean_signature
       ) VALUES (
         $1, NULLIF($2, ''), NULLIF($3, ''), NULLIF($4, ''), NULLIF($5, ''),
         NULLIF($6, ''), NULLIF($7, ''), NULLIF($8, ''), $9,
         NULLIF($10, ''), NULLIF($11, ''), NULLIF($12, ''), $13::jsonb,
         NULLIF($14, ''), NULLIF($15, ''), NULLIF($16, ''), NULLIF($17, ''),
         NULLIF($18, ''), NULLIF($19, ''), NULLIF($20, '')
       )
       RETURNING id`,
      [
        payload.student_id || null,
        payload.full_name || '',
        payload.student_number || '',
        payload.course_program || '',
        payload.year_level || '',
        payload.phone_number || '',
        payload.email_address || '',
        payload.subject_class_title || '',
        payload.consultation_date || null,
        payload.consultation_time || '',
        payload.venue || '',
        payload.advisor_name || '',
        JSON.stringify(payload.purpose_categories || []),
        payload.detailed_concerns || '',
        payload.issues_discussed || '',
        payload.action_taken || '',
        payload.recommendations || '',
        payload.student_signature || '',
        payload.faculty_signature || '',
        payload.dean_signature || '',
      ],
    );

    return res.status(201).json({ success: true, id: rows[0].id });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/consultations/:id/status', async (req, res) => {
  const { id } = req.params;
  const action = String(req.body.action || '').trim();

  const updates = {
    approve: {
      sql: `UPDATE consultations
            SET status = 'Pending Dean Approval',
                adviser_note = COALESCE(NULLIF($2, ''), adviser_note),
                adviser_recommendation = COALESCE(NULLIF($3, ''), adviser_recommendation),
                faculty_signature = COALESCE(NULLIF($4, ''), faculty_signature),
                approved_at = CURRENT_TIMESTAMP
            WHERE id = $1`,
      params: [id, req.body.adviser_note, req.body.adviser_recommendation, req.body.adviser_signature],
    },
    dean_sign: {
      sql: `UPDATE consultations
            SET status = 'Approved',
                dean_signature = COALESCE(NULLIF($2, ''), dean_signature),
                approved_at = COALESCE(approved_at, CURRENT_TIMESTAMP)
            WHERE id = $1`,
      params: [id, req.body.dean_signature],
    },
    reject: {
      sql: `UPDATE consultations
            SET status = 'Rejected',
                adviser_note = COALESCE(NULLIF($2, ''), adviser_note),
                adviser_recommendation = COALESCE(NULLIF($3, ''), adviser_recommendation)
            WHERE id = $1`,
      params: [id, req.body.adviser_note, req.body.adviser_recommendation],
    },
    complete: {
      sql: `UPDATE consultations
            SET status = 'Completed',
                completed_at = CURRENT_TIMESTAMP
            WHERE id = $1`,
      params: [id],
    },
    approve_reschedule: {
      sql: `UPDATE consultations
            SET consultation_date = reschedule_date,
                consultation_time = reschedule_time,
                venue = COALESCE(reschedule_venue, venue),
                status = 'Approved',
                reschedule_date = NULL,
                reschedule_time = NULL,
                reschedule_note = NULL,
                reschedule_venue = NULL
            WHERE id = $1`,
      params: [id],
    },
  };

  const config = updates[action];
  if (!config) {
    return res.status(400).json({ success: false, error: 'Unsupported action.' });
  }

  try {
    await query(config.sql, config.params);
    return res.json({ success: true });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/api/consultations/:id/reschedule', async (req, res) => {
  const { id } = req.params;
  try {
    await query(
      `UPDATE consultations
       SET status = 'Reschedule Requested',
           reschedule_date = $2,
           reschedule_time = NULLIF($3, ''),
           reschedule_venue = NULLIF($4, ''),
           reschedule_note = NULLIF($5, '')
       WHERE id = $1`,
      [
        id,
        req.body.reschedule_date || null,
        req.body.reschedule_time || '',
        req.body.reschedule_venue || '',
        req.body.reschedule_note || '',
      ],
    );
    return res.json({ success: true });
  } catch (error) {
    return res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`API listening on port ${port}`);
});
