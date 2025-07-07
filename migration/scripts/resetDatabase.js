require('dotenv').config();
const mysql = require('mysql2/promise');

async function resetDatabase() {
  const dbConfig = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
  };
  const dbName = process.env.DB_NAME;

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    await connection.query(`DROP DATABASE IF EXISTS \`${dbName}\``);
    console.log(`Database '${dbName}' dropped if it existed.`);
  } catch (error) {
    console.error('Error dropping database:', error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

resetDatabase();