const crypto = require('crypto');
const express = require('express');

const { signToken } = require('../authTokens');
const supabase = require('../supabaseClient');

const router = express.Router();

function normalizeEmail(email) {
  return typeof email === 'string' ? email.trim().toLowerCase() : '';
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  const hash = crypto
    .pbkdf2Sync(password, salt, 100000, 64, 'sha512')
    .toString('hex');

  return `${salt}:${hash}`;
}

function verifyPassword(password, storedHash) {
  const [salt, hash] = storedHash.split(':');

  if (!salt || !hash) {
    return false;
  }

  const passwordHash = hashPassword(password, salt).split(':')[1];
  return crypto.timingSafeEqual(Buffer.from(hash), Buffer.from(passwordHash));
}

function toPublicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    created_at: user.created_at,
  };
}

function sendSupabaseError(res, error) {
  return res.status(500).json({
    error: 'Supabase request failed.',
    details: error.message,
  });
}

router.post('/signup', async (req, res) => {
  const name = typeof req.body.name === 'string' ? req.body.name.trim() : '';
  const email = normalizeEmail(req.body.email);
  const password = typeof req.body.password === 'string' ? req.body.password : '';

  if (!name) {
    return res.status(400).json({ error: 'Name is required.' });
  }

  if (!isValidEmail(email)) {
    return res.status(400).json({ error: 'A valid email is required.' });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: 'Password must be at least 6 characters.' });
  }

  const { data: existingUser, error: lookupError } = await supabase
    .from('users')
    .select('id')
    .eq('email', email)
    .maybeSingle();

  if (lookupError) {
    return sendSupabaseError(res, lookupError);
  }

  if (existingUser) {
    return res.status(409).json({ error: 'An account with this email already exists.' });
  }

  const { data: user, error } = await supabase
    .from('users')
    .insert({
      name,
      email,
      password_hash: hashPassword(password),
    })
    .select('id,name,email,created_at')
    .single();

  if (error) {
    return sendSupabaseError(res, error);
  }

  return res.status(201).json({
    user: toPublicUser(user),
    token: signToken(user),
  });
});

router.post('/login', async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const password = typeof req.body.password === 'string' ? req.body.password : '';

  if (!isValidEmail(email) || !password) {
    return res.status(400).json({ error: 'Email and password are required.' });
  }

  const { data: user, error } = await supabase
    .from('users')
    .select('id,name,email,password_hash,created_at')
    .eq('email', email)
    .maybeSingle();

  if (error) {
    return sendSupabaseError(res, error);
  }

  if (!user || !verifyPassword(password, user.password_hash)) {
    return res.status(401).json({ error: 'Invalid email or password.' });
  }

  return res.json({
    user: toPublicUser(user),
    token: signToken(user),
  });
});

module.exports = router;
