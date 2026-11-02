require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

const app = express();
app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
});

// ---------- AUTH ----------
app.post('/register', async (req, res) => {
  try {
    const { nama, email, password } = req.body;
    if (!nama || !email || !password)
      return res.status(400).json({ message: 'Data tidak lengkap' });

    const hash = await bcrypt.hash(password, 10);
    const [r] = await pool.query(
      'INSERT INTO users (nama, email, password) VALUES (?, ?, ?)',
      [nama, email.trim(), hash]
    );
    res.status(201).json({
      message: 'Registrasi berhasil, silakan masuk',
      id: r.insertId,
      nama,
      email: email.trim(),
    });
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY')
      return res.status(409).json({ message: 'Email sudah terdaftar' });
    res.status(500).json({ message: e.message });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: 'Email dan password harus diisi' });

    const [rows] = await pool.query(
      'SELECT id, nama, email, password FROM users WHERE email = ?',
      [email.trim()]
    );
    if (rows.length === 0)
      return res.status(401).json({ message: 'Email atau password salah' });

    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ message: 'Email atau password salah' });

    res.json({ id: user.id, nama: user.nama, email: user.email });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- ROOMS ----------
app.get('/rooms', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM rooms');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- MENU ----------
app.get('/menu', async (req, res) => {
  try {
    const { kategori } = req.query;
    const [rows] = kategori
      ? await pool.query('SELECT * FROM menu_items WHERE kategori = ?', [kategori])
      : await pool.query('SELECT * FROM menu_items');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- RESERVATIONS ----------
app.post('/reservations', async (req, res) => {
  const conn = await pool.getConnection();
  try {
    const { user_id, room_id, tanggal, jam_mulai, jam_selesai, jumlah_orang, items = [] } = req.body;

    await conn.beginTransaction();

    const [[room]] = await conn.query('SELECT harga_per_jam FROM rooms WHERE id = ?', [room_id]);
    if (!room) throw new Error('Ruangan tidak ditemukan');

    const durasi =
      (new Date(`1970-01-01T${jam_selesai}`) - new Date(`1970-01-01T${jam_mulai}`)) / 3600000;
    if (durasi <= 0) throw new Error('Jam selesai harus setelah jam mulai');

    const [bentrok] = await conn.query(
      `SELECT id FROM reservations
       WHERE room_id = ? AND tanggal = ? AND status <> 'dibatalkan'
         AND jam_mulai < ? AND jam_selesai > ?`,
      [room_id, tanggal, jam_selesai, jam_mulai]
    );
    if (bentrok.length > 0) {
      await conn.rollback();
      return res.status(409).json({ message: 'Ruangan sudah dipesan pada jam tersebut' });
    }

    let total = room.harga_per_jam * durasi;
    const detail = [];
    for (const it of items) {
      const [[m]] = await conn.query('SELECT harga FROM menu_items WHERE id = ?', [it.menu_item_id]);
      if (!m) throw new Error(`Menu ${it.menu_item_id} tidak ditemukan`);
      const subtotal = m.harga * it.jumlah;
      total += subtotal;
      detail.push([it.menu_item_id, it.jumlah, subtotal]);
    }

    const [r] = await conn.query(
      `INSERT INTO reservations
       (user_id, room_id, tanggal, jam_mulai, jam_selesai, jumlah_orang, total_harga)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [user_id, room_id, tanggal, jam_mulai, jam_selesai, jumlah_orang, total]
    );

    for (const d of detail) {
      await conn.query(
        'INSERT INTO reservation_items (reservation_id, menu_item_id, jumlah, subtotal) VALUES (?, ?, ?, ?)',
        [r.insertId, ...d]
      );
    }

    await conn.commit();
    res.status(201).json({ id: r.insertId, total_harga: total });
  } catch (e) {
    await conn.rollback();
    res.status(400).json({ message: e.message });
  } finally {
    conn.release();
  }
});

app.get('/reservations', async (req, res) => {
  try {
    const { user_id } = req.query;
    if (!user_id) return res.status(400).json({ message: 'user_id wajib diisi' });

    const [reservs] = await pool.query(
      `SELECT r.*, rm.nama_ruangan
       FROM reservations r JOIN rooms rm ON rm.id = r.room_id
       WHERE r.user_id = ? ORDER BY r.tanggal DESC, r.jam_mulai DESC`,
      [user_id]
    );

    for (const r of reservs) {
      const [items] = await pool.query(
        `SELECT ri.jumlah, ri.subtotal, m.nama, m.kategori
         FROM reservation_items ri JOIN menu_items m ON m.id = ri.menu_item_id
         WHERE ri.reservation_id = ?`,
        [r.id]
      );
      r.items = items;
    }
    res.json(reservs);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API berjalan di http://localhost:${port}`));