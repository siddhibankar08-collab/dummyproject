const crypto = require('crypto');

const tokenSecret =
  process.env.AUTH_TOKEN_SECRET ||
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  process.env.SUPABASE_SECRET_KEY ||
  'replace-this-secret-in-env';

function base64Url(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

function signToken(user) {
  const header = base64Url({ alg: 'HS256', typ: 'JWT' });
  const payload = base64Url({
    sub: user.id,
    email: user.email,
    name: user.name,
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 7,
  });
  const unsignedToken = `${header}.${payload}`;
  const signature = crypto
    .createHmac('sha256', tokenSecret)
    .update(unsignedToken)
    .digest('base64url');

  return `${unsignedToken}.${signature}`;
}

function verifyToken(token) {
  const parts = typeof token === 'string' ? token.split('.') : [];

  if (parts.length !== 3) {
    return null;
  }

  const [header, payload, signature] = parts;
  const expectedSignature = crypto
    .createHmac('sha256', tokenSecret)
    .update(`${header}.${payload}`)
    .digest('base64url');

  if (
    signature.length !== expectedSignature.length ||
    !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expectedSignature))
  ) {
    return null;
  }

  try {
    const decoded = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));

    if (!decoded.sub || decoded.exp < Math.floor(Date.now() / 1000)) {
      return null;
    }

    return decoded;
  } catch (error) {
    return null;
  }
}

module.exports = { signToken, verifyToken };
