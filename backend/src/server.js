require('dotenv').config();

const cors = require('cors');
const express = require('express');
const http = require('http');

const authenticate = require('./middleware/authenticate');
const authRouter = require('./routes/auth');
const tasksRouter = require('./routes/tasks');

const app = express();
const port = process.env.PORT || 4000;
const host = process.env.HOST || '0.0.0.0';

app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRouter);
app.use('/api/tasks', authenticate, tasksRouter);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Unexpected server error.' });
});

const server = http.createServer(app);

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`Port ${port} is already in use.`);
  } else if (error.code === 'EACCES' || error.code === 'EPERM') {
    console.error(`Cannot listen on ${host}:${port}: ${error.message}`);
  } else {
    console.error('Backend failed to start:', error);
  }

  process.exit(1);
});

server.listen(port, host, () => {
  console.log(`Backend running on http://${host}:${port}`);
});
