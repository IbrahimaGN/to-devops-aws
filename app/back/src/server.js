const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'tododb',
  user: process.env.DB_USER || 'todo_user',
  password: process.env.DB_PASSWORD || 'changeme_local_only',
});

async function initDb(retries = 10) {
  for (let i = 1; i <= retries; i++) {
    try {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS todos (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          done BOOLEAN NOT NULL DEFAULT false,
          created_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
      `);
      console.log('Connecte a PostgreSQL, table todos prete.');
      return;
    } catch (err) {
      console.log(`DB pas encore prete (essai ${i}/${retries}): ${err.message}`);
      await new Promise((r) => setTimeout(r, 3000));
    }
  }
  console.error('Impossible de se connecter a la DB apres plusieurs essais.');
}

// --- Healthcheck (utilise par le HEALTHCHECK du Dockerfile) ---
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// --- CRUD Todos ---
app.get('/todos', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM todos ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/todos', async (req, res) => {
  const { title } = req.body;
  if (!title || !title.trim()) {
    return res.status(400).json({ error: 'Le champ title est requis' });
  }
  try {
    const result = await pool.query(
      'INSERT INTO todos (title) VALUES ($1) RETURNING *',
      [title.trim()]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.patch('/todos/:id', async (req, res) => {
  const { id } = req.params;
  const { done } = req.body;
  try {
    const result = await pool.query(
      'UPDATE todos SET done = $1 WHERE id = $2 RETURNING *',
      [done, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Todo introuvable' });
    }
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/todos/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM todos WHERE id = $1', [id]);
    res.status(204).send();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`API Todo Back demarree sur le port ${PORT}`);
  initDb();
});
