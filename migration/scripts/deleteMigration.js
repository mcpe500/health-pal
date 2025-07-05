const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
if (args.length < 1) {
  console.error('Usage: npm run delete:migration <migration-name> [--model]');
  process.exit(1);
}

const migrationName = args[0];
const deleteModel = args.includes('--model');

try {
  // Find and delete migration file
  const migrationsDir = path.join('migrations');
  const migrationFile = fs.readdirSync(migrationsDir)
    .find(file => file.includes(migrationName));
  
  if (migrationFile) {
    fs.unlinkSync(path.join(migrationsDir, migrationFile));
    console.log(`Migration ${migrationName} deleted successfully!`);
  } else {
    console.log(`Migration ${migrationName} not found.`);
  }

  if (deleteModel) {
    // Delete model file
    const modelPath = path.join('models', `${migrationName.toLowerCase()}.js`);
    if (fs.existsSync(modelPath)) {
      fs.unlinkSync(modelPath);
      console.log(`Model ${migrationName} deleted successfully!`);
    } else {
      console.log(`Model ${migrationName} not found.`);
    }
  }
} catch (error) {
  console.error('Error deleting migration:', error.message);
  process.exit(1);
}