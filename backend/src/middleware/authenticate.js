const { verifyToken } = require('../authTokens');

function authenticate(req, res, next) {
  const authHeader = req.get('authorization') || '';
  const [scheme, token] = authHeader.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Authorization bearer token is required.' });
  }

  const payload = verifyToken(token);

  if (!payload) {
    return res.status(401).json({ error: 'Invalid or expired authorization token.' });
  }

  req.user = {
    id: payload.sub,
    email: payload.email,
    name: payload.name,
  };

  return next();
}

module.exports = authenticate;
