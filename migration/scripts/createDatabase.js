require('dotenv').config()
const { Sequelize } = require('sequelize');

async function createDatabase() {
    const dbConfig = {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        dialect: 'mysql',
        logging: false,
    };
    console.log({ dbConfig })
    const dbName = process.env.DB_NAME;

    // Connect without specifying database
    const sequelize = new Sequelize('', dbConfig.username, dbConfig.password, dbConfig);

    try {
        await sequelize.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
        console.log(`Database '${dbName}' created or already exists.`);
    } catch (error) {
        console.error('Error creating database:', error.message);
        console.error('Error creating database:', error);
        process.exit(1);
    } finally {
        await sequelize.close();
    }
}

createDatabase();