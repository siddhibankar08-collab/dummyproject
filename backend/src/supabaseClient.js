const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_SECRET_KEY ||
  process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error(
    'Missing SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY/SUPABASE_SECRET_KEY/SUPABASE_ANON_KEY in backend environment.',
  );
}

if (
  supabaseUrl.includes('your-project-ref') ||
  supabaseKey.includes('your-secret') ||
  supabaseKey.includes('your-anon')
) {
  throw new Error(
    'Supabase environment variables still contain placeholder values. Update backend/.env with your real Supabase project URL and API key.',
  );
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});

module.exports = supabase;
