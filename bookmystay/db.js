import { Pool } from 'pg';

const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Connection string
  ssl: {
    rejectUnauthorized: false,
  },
});

export default pool;
