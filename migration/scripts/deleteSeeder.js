
const fs = require('fs');
const path = require('path');

const seederName = process.argv[2];

if (!seederName) {
  console.error('Please provide the name of the seeder to delete.');
  process.exit(1);
}

const seedersDir = path.join(__dirname, '..', 'seeders');
const files = fs.readdirSync(seedersDir);

const fileToDelete = files.find(file => file.includes(seederName));

if (!fileToDelete) {
  console.error(`Seeder with name "${seederName}" not found.`);
  process.exit(1);
}

const seederPath = path.join(seedersDir, fileToDelete);

fs.unlinkSync(seederPath);

console.log(`Deleted seeder: ${fileToDelete}`);
