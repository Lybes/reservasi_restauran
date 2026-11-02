require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function setupDatabase() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'db_reservasipml',
  });

  console.log('Connected to MySQL database:', process.env.DB_NAME);

  // 1. Add 'role' column to users if not exists
  const [cols] = await conn.query("SHOW COLUMNS FROM users LIKE 'role'");
  if (cols.length === 0) {
    console.log("Adding 'role' column to users table...");
    await conn.query("ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'pelanggan'");
    console.log("Column 'role' added successfully.");
  } else {
    console.log("Column 'role' already exists in users.");
  }

  // 2. Add 'customer_name' and 'catatan' to reservations if not exist
  const [resCols] = await conn.query("SHOW COLUMNS FROM reservations LIKE 'customer_name'");
  if (resCols.length === 0) {
    console.log("Adding 'customer_name' and 'catatan' columns to reservations table...");
    await conn.query("ALTER TABLE reservations ADD COLUMN customer_name VARCHAR(100) NULL");
    await conn.query("ALTER TABLE reservations ADD COLUMN catatan TEXT NULL");
    console.log("Columns added to reservations table.");
  }

  // 3. Make sure existing user has role 'pelanggan'
  await conn.query("UPDATE users SET role = 'pelanggan' WHERE role IS NULL OR role = ''");

  // 4. Create or update Admin user
  const adminEmail = 'admin@tabebuya.com';
  const [adminRows] = await conn.query('SELECT id FROM users WHERE email = ?', [adminEmail]);
  const adminHashed = await bcrypt.hash('admin123', 10);

  if (adminRows.length === 0) {
    console.log('Creating default admin user...');
    await conn.query(
      'INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)',
      ['Admin Tabebuya', adminEmail, adminHashed, 'admin']
    );
    console.log(`Admin user created: ${adminEmail} (password: admin123)`);
  } else {
    await conn.query(
      "UPDATE users SET role = 'admin', password = ? WHERE email = ?",
      [adminHashed, adminEmail]
    );
    console.log(`Admin user verified: ${adminEmail}`);
  }

  // Also create a second admin for convenience if needed, e.g. admin@gmail.com
  const adminGmail = 'admin@gmail.com';
  const [adminGmailRows] = await conn.query('SELECT id FROM users WHERE email = ?', [adminGmail]);
  if (adminGmailRows.length === 0) {
    await conn.query(
      'INSERT INTO users (nama, email, password, role) VALUES (?, ?, ?, ?)',
      ['Administrator', adminGmail, adminHashed, 'admin']
    );
    console.log(`Admin user created: ${adminGmail} (password: admin123)`);
  } else {
    await conn.query("UPDATE users SET role = 'admin' WHERE email = ?", [adminGmail]);
  }

  // 5. Sync / populate rooms with Tabebuya restaurant rooms
  const tabebuyaRooms = [
    {
      nama_ruangan: 'Indoor',
      kapasitas: 24,
      harga_per_jam: 50000,
      gambar: 'indoor.png',
      deskripsi: 'Ruangan indoor utama dengan suasana hangat dan pencahayaan lembut. Cocok untuk makan bersama keluarga atau teman.'
    },
    {
      nama_ruangan: 'Outdoor',
      kapasitas: 32,
      harga_per_jam: 75000,
      gambar: 'outdoor.png',
      deskripsi: 'Area makan terbuka dengan pemandangan luar dan udara segar. Cocok untuk suasana santai atau romantis.'
    },
    {
      nama_ruangan: 'VVIP',
      kapasitas: 12,
      harga_per_jam: 150000,
      gambar: 'vvip.png',
      deskripsi: 'Ruangan eksklusif dengan pencahayaan mewah dan interior premium. Ideal untuk acara khusus atau tamu VIP.'
    }
  ];

  for (const r of tabebuyaRooms) {
    const [existing] = await conn.query('SELECT id FROM rooms WHERE nama_ruangan = ?', [r.nama_ruangan]);
    if (existing.length === 0) {
      await conn.query(
        'INSERT INTO rooms (nama_ruangan, kapasitas, harga_per_jam, gambar, deskripsi) VALUES (?, ?, ?, ?, ?)',
        [r.nama_ruangan, r.kapasitas, r.harga_per_jam, r.gambar, r.deskripsi]
      );
      console.log(`Room '${r.nama_ruangan}' inserted.`);
    } else {
      await conn.query(
        'UPDATE rooms SET kapasitas = ?, harga_per_jam = ?, gambar = ?, deskripsi = ? WHERE id = ?',
        [r.kapasitas, r.harga_per_jam, r.gambar, r.deskripsi, existing[0].id]
      );
      console.log(`Room '${r.nama_ruangan}' updated.`);
    }
  }

  // 6. Populate menu items if missing
  const menuItems = [
    // Makanan
    { nama: 'Chicken Skin', kategori: 'makanan', harga: 12500, gambar: 'chikenskin.jpg' },
    { nama: 'Gorengan Keranjang', kategori: 'makanan', harga: 8000, gambar: 'gorengan.jpg' },
    { nama: 'French Fries Mayo', kategori: 'makanan', harga: 8500, gambar: 'french.jpg' },
    { nama: 'Calamary', kategori: 'makanan', harga: 10000, gambar: 'calamary.jpg' },
    { nama: 'Onion Ring', kategori: 'makanan', harga: 15000, gambar: 'onion.jpg' },
    { nama: 'Cheese French Fries', kategori: 'makanan', harga: 20000, gambar: 'kentangkeju.jpg' },
    { nama: 'Ice Cream Goreng', kategori: 'makanan', harga: 15000, gambar: 'icegoreng.jpg' },
    { nama: 'Cireng', kategori: 'makanan', harga: 5000, gambar: 'cireng.jpg' },
    { nama: 'Zaitun Kaya Toast', kategori: 'makanan', harga: 15000, gambar: 'zaitunkayatoast.jpg' },
    { nama: 'Zaitun Fritter', kategori: 'makanan', harga: 25000, gambar: 'zaitunfritte.jpg' },
    // Minuman
    { nama: 'Es Teh', kategori: 'minuman', harga: 5500, gambar: 'esteh.jpg' },
    { nama: 'Teh Tarik', kategori: 'minuman', harga: 8000, gambar: 'tehtarik.jpg' },
    { nama: 'Susu Tape', kategori: 'minuman', harga: 10500, gambar: 'susutape.jpg' },
    { nama: 'Americano', kategori: 'minuman', harga: 10000, gambar: 'blend.jpg' },
    { nama: 'Kopi Kalcer', kategori: 'minuman', harga: 15000, gambar: 'kopikalcer.jpg' },
    { nama: 'Kopi Butterscott', kategori: 'minuman', harga: 20000, gambar: 'kopibutter.jpg' },
    { nama: 'Juz Mangga', kategori: 'minuman', harga: 15000, gambar: 'juzmangga.jpg' },
    { nama: 'Juz Apel', kategori: 'minuman', harga: 5000, gambar: 'juzapel.jpg' },
    { nama: 'Juz Jambu', kategori: 'minuman', harga: 15000, gambar: 'juzjambu.jpg' },
    { nama: 'Juz Timun', kategori: 'minuman', harga: 25000, gambar: 'juztimun.jpg' }
  ];

  for (const m of menuItems) {
    const [existing] = await conn.query('SELECT id FROM menu_items WHERE nama = ?', [m.nama]);
    if (existing.length === 0) {
      await conn.query(
        'INSERT INTO menu_items (nama, kategori, harga, gambar) VALUES (?, ?, ?, ?)',
        [m.nama, m.kategori, m.harga, m.gambar]
      );
    } else {
      await conn.query(
        'UPDATE menu_items SET kategori = ?, harga = ?, gambar = ? WHERE id = ?',
        [m.kategori, m.harga, m.gambar, existing[0].id]
      );
    }
  }
  console.log(`Menu items synchronized (${menuItems.length} items).`);

  // 7. Seed sample reservations for testing if none exist
  const [existingReservs] = await conn.query('SELECT id FROM reservations');
  if (existingReservs.length === 0) {
    console.log('Seeding sample reservations for admin testing...');
    const [[customer]] = await conn.query("SELECT id, nama FROM users WHERE role = 'pelanggan' LIMIT 1");
    const [[roomVvip]] = await conn.query("SELECT id FROM rooms WHERE nama_ruangan = 'VVIP' LIMIT 1");
    const [[roomIndoor]] = await conn.query("SELECT id FROM rooms WHERE nama_ruangan = 'Indoor' LIMIT 1");
    const [[roomOutdoor]] = await conn.query("SELECT id FROM rooms WHERE nama_ruangan = 'Outdoor' LIMIT 1");

    const custId = customer ? customer.id : 1;
    const custName = customer ? customer.nama : 'Fransiscus';

    // Sample 1: Menunggu Konfirmasi
    const [r1] = await conn.query(
      `INSERT INTO reservations 
       (user_id, room_id, customer_name, tanggal, jam_mulai, jam_selesai, jumlah_orang, total_harga, status, catatan)
       VALUES (?, ?, ?, CURDATE(), '18:00:00', '20:00:00', 4, 300000, 'Menunggu Konfirmasi', 'Ulang tahun, mohon meja dekat jendela')`,
      [custId, roomVvip ? roomVvip.id : 1, custName]
    );

    // Sample 2: Dikonfirmasi / Berhasil
    const [r2] = await conn.query(
      `INSERT INTO reservations 
       (user_id, room_id, customer_name, tanggal, jam_mulai, jam_selesai, jumlah_orang, total_harga, status, catatan)
       VALUES (?, ?, ?, CURDATE(), '13:00:00', '15:00:00', 2, 100000, 'Berhasil', 'Meeting santai')`,
      [custId, roomIndoor ? roomIndoor.id : 2, custName]
    );

    // Sample 3: Selesai
    await conn.query(
      `INSERT INTO reservations 
       (user_id, room_id, customer_name, tanggal, jam_mulai, jam_selesai, jumlah_orang, total_harga, status, catatan)
       VALUES (?, ?, ?, DATE_SUB(CURDATE(), INTERVAL 1 DAY), '19:00:00', '21:00:00', 6, 150000, 'Selesai', 'Makan malam keluarga')`,
      [custId, roomOutdoor ? roomOutdoor.id : 3, 'Budi Santoso']
    );

    // Add items for sample 1
    const [m1] = await conn.query("SELECT id, harga FROM menu_items WHERE nama = 'Zaitun Kaya Toast' LIMIT 1");
    const [m2] = await conn.query("SELECT id, harga FROM menu_items WHERE nama = 'Kopi Butterscott' LIMIT 1");
    if (m1.length > 0 && r1.insertId) {
      await conn.query(
        'INSERT INTO reservation_items (reservation_id, menu_item_id, jumlah, subtotal) VALUES (?, ?, ?, ?)',
        [r1.insertId, m1[0].id, 2, m1[0].harga * 2]
      );
    }
    if (m2.length > 0 && r1.insertId) {
      await conn.query(
        'INSERT INTO reservation_items (reservation_id, menu_item_id, jumlah, subtotal) VALUES (?, ?, ?, ?)',
        [r1.insertId, m2[0].id, 4, m2[0].harga * 4]
      );
    }
    console.log('Sample reservations seeded successfully.');
  }

  await conn.end();
  console.log('Database setup completed successfully!');
}

setupDatabase().catch(err => {
  console.error('Setup failed:', err);
  process.exit(1);
});
