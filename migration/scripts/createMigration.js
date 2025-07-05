const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
if (args.length < 1) {
  console.error('Usage: npm run create:migration <migration-name> [--model]');
  process.exit(1);
}

const migrationName = args[0];
const createModel = args.includes('--model');

try {
  // Create migration
  execSync(`npx sequelize-cli migration:generate --name ${migrationName}`);
  
  if (createModel) {
    // Create model
    execSync(`npx sequelize-cli model:generate --name ${migrationName} --attributes dummy:string`);
    
    // Remove dummy attribute from model
    const modelPath = path.join('models', `${migrationName.toLowerCase()}.js`);
    const modelContent = fs.readFileSync(modelPath, 'utf8')
      .replace(/dummy: DataTypes.STRING,\s*/, '');
    fs.writeFileSync(modelPath, modelContent);
  }
  
  console.log(`Migration ${migrationName} created successfully!`);
} catch (error) {
  console.error('Error creating migration:', error.message);
  process.exit(1);
}