require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

const app = express();
app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'db_reservasipml',
  waitForConnections: true,
  connectionLimit: 10,
});

// ---------- AUTH ----------
app.post('/register', async (req, res) => {
  try {
    const { nama, email, password, role } = req.body;
    if (!nama || !email || !password)
      return res.status(400).json({ message: 'Data tidak lengkap' });

    const userRole = role === 'admin' ? 'admin' : 'pelanggan';
    const hash = await bcrypt.hash(password, 10);
    const [r] = await pool.query(
      'INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)',
      [nama, email.trim(), hash, userRole]
    );
    res.status(201).json({
      message: 'Registrasi berhasil, silakan masuk',
      id: r.insertId,
      nama,
      email: email.trim(),
      role: userRole,
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
      'SELECT id, nama, email, password, role FROM users WHERE email = ?',
      [email.trim()]
    );
    if (rows.length === 0)
      return res.status(401).json({ message: 'Email atau password salah' });

    const user = rows[0];
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ message: 'Email atau password salah' });

    res.json({
      id: user.id,
      nama: user.nama,
      email: user.email,
      role: user.role || 'pelanggan',
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- ROOMS ----------
app.get('/rooms', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM rooms ORDER BY id ASC');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.post('/rooms', async (req, res) => {
  try {
    const { nama_ruangan, kapasitas, harga_per_jam, gambar, deskripsi } = req.body;
    if (!nama_ruangan) return res.status(400).json({ message: 'Nama ruangan wajib diisi' });

    const [r] = await pool.query(
      'INSERT INTO rooms (nama_ruangan, kapasitas, harga_per_jam, gambar, deskripsi) VALUES (?, ?, ?, ?, ?)',
      [nama_ruangan, kapasitas || 10, harga_per_jam || 50000, gambar || null, deskripsi || '']
    );
    res.status(201).json({ id: r.insertId, message: 'Ruangan berhasil ditambahkan' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.put('/rooms/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nama_ruangan, kapasitas, harga_per_jam, gambar, deskripsi } = req.body;
    await pool.query(
      'UPDATE rooms SET nama_ruangan = ?, kapasitas = ?, harga_per_jam = ?, gambar = ?, deskripsi = ? WHERE id = ?',
      [nama_ruangan, kapasitas, harga_per_jam, gambar, deskripsi, id]
    );
    res.json({ message: 'Ruangan berhasil diperbarui' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.delete('/rooms/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM rooms WHERE id = ?', [id]);
    res.json({ message: 'Ruangan berhasil dihapus' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- MENU ----------
app.get('/menu', async (req, res) => {
  try {
    const { kategori } = req.query;
    const [rows] = kategori
      ? await pool.query('SELECT * FROM menu_items WHERE kategori = ? ORDER BY id ASC', [kategori])
      : await pool.query('SELECT * FROM menu_items ORDER BY id ASC');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.post('/menu', async (req, res) => {
  try {
    const { nama, kategori, harga, gambar } = req.body;
    if (!nama || !kategori || !harga)
      return res.status(400).json({ message: 'Data menu tidak lengkap' });

    const [r] = await pool.query(
      'INSERT INTO menu_items (nama, kategori, harga, gambar) VALUES (?, ?, ?, ?)',
      [nama, kategori, harga, gambar || null]
    );
    res.status(201).json({ id: r.insertId, message: 'Menu berhasil ditambahkan' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.put('/menu/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, kategori, harga, gambar } = req.body;
    await pool.query(
      'UPDATE menu_items SET nama = ?, kategori = ?, harga = ?, gambar = ? WHERE id = ?',
      [nama, kategori, harga, gambar, id]
    );
    res.json({ message: 'Menu berhasil diperbarui' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

app.delete('/menu/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('DELETE FROM menu_items WHERE id = ?', [id]);
    res.json({ message: 'Menu berhasil dihapus' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- RESERVATIONS ----------
app.post('/reservations', async (req, res) => {
  const conn = await pool.getConnection();
  try {
    let {
      user_id,
      room_id,
      ruangan_nama,
      customer_name,
      tanggal,
      jam_mulai,
      jam_selesai,
      jumlah_orang,
      catatan,
      total_harga,
      items = [],
    } = req.body;

    // Fallback user_id if not provided
    if (!user_id) {
      const [[firstUser]] = await conn.query('SELECT id FROM users LIMIT 1');
      user_id = firstUser ? firstUser.id : 1;
    }

    // Resolve room_id if room name is provided
    if (!room_id && ruangan_nama) {
      const [[foundRoom]] = await conn.query(
        'SELECT id, harga_per_jam FROM rooms WHERE nama_ruangan LIKE ? LIMIT 1',
        [`%${ruangan_nama}%`]
      );
      if (foundRoom) {
        room_id = foundRoom.id;
      }
    }

    if (!room_id) {
      const [[defaultRoom]] = await conn.query('SELECT id FROM rooms LIMIT 1');
      room_id = defaultRoom ? defaultRoom.id : 1;
    }

    // Convert tanggal to YYYY-MM-DD if needed
    let dateStr = tanggal;
    if (!dateStr || isNaN(Date.parse(dateStr))) {
      dateStr = new Date().toISOString().split('T')[0];
    } else {
      const d = new Date(dateStr);
      dateStr = d.toISOString().split('T')[0];
    }

    // Default jam
    if (!jam_mulai) jam_mulai = '12:00:00';
    if (jam_mulai.length === 5) jam_mulai += ':00';

    if (!jam_selesai) {
      const [h, m] = jam_mulai.split(':');
      const endH = (parseInt(h, 10) + 2) % 24;
      jam_selesai = `${String(endH).padStart(2, '0')}:${m}:00`;
    } else if (jam_selesai.length === 5) {
      jam_selesai += ':00';
    }

    // Parse jumlah_orang
    let orangCount = 2;
    if (typeof jumlah_orang === 'number') {
      orangCount = jumlah_orang;
    } else if (typeof jumlah_orang === 'string') {
      const match = jumlah_orang.match(/\d+/);
      if (match) orangCount = parseInt(match[0], 10);
    }

    await conn.beginTransaction();

    const [[room]] = await conn.query('SELECT harga_per_jam FROM rooms WHERE id = ?', [room_id]);
    const hargaPerJam = room ? room.harga_per_jam : 50000;

    let computedTotal = total_harga;
    if (!computedTotal) {
      const durasi =
        (new Date(`1970-01-01T${jam_selesai}`) - new Date(`1970-01-01T${jam_mulai}`)) / 3600000;
      const validDurasi = durasi > 0 ? durasi : 2;
      computedTotal = hargaPerJam * validDurasi;
    }

    const detail = [];
    for (const it of items) {
      if (it.menu_item_id) {
        const [[m]] = await conn.query('SELECT harga FROM menu_items WHERE id = ?', [it.menu_item_id]);
        if (m) {
          const subtotal = m.harga * (it.jumlah || 1);
          computedTotal += subtotal;
          detail.push([it.menu_item_id, it.jumlah || 1, subtotal]);
        }
      }
    }

    const [r] = await conn.query(
      `INSERT INTO reservations
       (user_id, room_id, customer_name, tanggal, jam_mulai, jam_selesai, jumlah_orang, total_harga, status, catatan)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Menunggu Konfirmasi', ?)`,
      [user_id, room_id, customer_name || 'Pelanggan', dateStr, jam_mulai, jam_selesai, orangCount, computedTotal, catatan || '']
    );

    for (const d of detail) {
      await conn.query(
        'INSERT INTO reservation_items (reservation_id, menu_item_id, jumlah, subtotal) VALUES (?, ?, ?, ?)',
        [r.insertId, ...d]
      );
    }

    await conn.commit();
    res.status(201).json({
      id: r.insertId,
      total_harga: computedTotal,
      message: 'Reservasi berhasil dibuat',
    });
  } catch (e) {
    await conn.rollback();
    res.status(400).json({ message: e.message });
  } finally {
    conn.release();
  }
});

// GET /reservations (If user_id provided: for that user. If omitted: all reservations for Admin!)
app.get('/reservations', async (req, res) => {
  try {
    const { user_id, status } = req.query;

    let sql = `
      SELECT r.*, rm.nama_ruangan, rm.gambar as room_gambar, u.nama as user_nama, u.email as user_email
      FROM reservations r
      LEFT JOIN rooms rm ON rm.id = r.room_id
      LEFT JOIN users u ON u.id = r.user_id
    `;
    const params = [];
    const whereClauses = [];

    if (user_id) {
      whereClauses.push('r.user_id = ?');
      params.push(user_id);
    }
    if (status && status !== 'Semua') {
      whereClauses.push('r.status LIKE ?');
      params.push(`%${status}%`);
    }

    if (whereClauses.length > 0) {
      sql += ' WHERE ' + whereClauses.join(' AND ');
    }
    sql += ' ORDER BY r.tanggal DESC, r.jam_mulai DESC';

    const [reservs] = await pool.query(sql, params);

    for (const r of reservs) {
      const [items] = await pool.query(
        `SELECT ri.jumlah, ri.subtotal, m.nama, m.kategori, m.harga, m.gambar
         FROM reservation_items ri 
         JOIN menu_items m ON m.id = ri.menu_item_id
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

// Update status reservasi (Admin Action)
app.put('/reservations/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    if (!status) return res.status(400).json({ message: 'Status wajib diisi' });

    await pool.query('UPDATE reservations SET status = ? WHERE id = ?', [status, id]);
    res.json({ message: 'Status reservasi berhasil diperbarui' });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// Delete reservasi
app.delete('/reservations/:id', async (req, res) => {
  const conn = await pool.getConnection();
  try {
    const { id } = req.params;
    await conn.beginTransaction();
    await conn.query('DELETE FROM reservation_items WHERE reservation_id = ?', [id]);
    await conn.query('DELETE FROM reservations WHERE id = ?', [id]);
    await conn.commit();
    res.json({ message: 'Reservasi berhasil dihapus' });
  } catch (e) {
    await conn.rollback();
    res.status(500).json({ message: e.message });
  } finally {
    conn.release();
  }
});

// ---------- ADMIN STATS ----------
app.get('/admin/stats', async (req, res) => {
  try {
    const [[totalRes]] = await pool.query('SELECT COUNT(*) as count FROM reservations');
    const [[pendingRes]] = await pool.query(
      "SELECT COUNT(*) as count FROM reservations WHERE status LIKE '%Menunggu%' OR status LIKE '%pending%'"
    );
    const [[confirmedRes]] = await pool.query(
      "SELECT COUNT(*) as count FROM reservations WHERE status LIKE '%Berhasil%' OR status LIKE '%dikonfirmasi%'"
    );
    const [[completedRes]] = await pool.query(
      "SELECT COUNT(*) as count FROM reservations WHERE status LIKE '%Selesai%'"
    );
    const [[cancelledRes]] = await pool.query(
      "SELECT COUNT(*) as count FROM reservations WHERE status LIKE '%Batal%'"
    );
    const [[roomCount]] = await pool.query('SELECT COUNT(*) as count FROM rooms');
    const [[menuCount]] = await pool.query('SELECT COUNT(*) as count FROM menu_items');
    const [[revenue]] = await pool.query(
      "SELECT COALESCE(SUM(total_harga), 0) as total FROM reservations WHERE status NOT LIKE '%Batal%'"
    );

    res.json({
      total_reservations: totalRes.count,
      pending_reservations: pendingRes.count,
      confirmed_reservations: confirmedRes.count,
      completed_reservations: completedRes.count,
      cancelled_reservations: cancelledRes.count,
      total_rooms: roomCount.count,
      total_menu: menuCount.count,
      total_revenue: revenue.total,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// ---------- ADMIN USERS ----------
app.get('/admin/users', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, nama, email, role FROM users ORDER BY id ASC');
    res.json(rows);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API berjalan di http://localhost:${port}`));
