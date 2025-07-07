
const fs = require('fs');
const path = require('path');

const seederName = process.argv[2];

if (!seederName) {
  console.error('Please provide a name for the seeder.');
  process.exit(1);
}

const timestamp = new Date().toISOString().replace(/[-:.]/g, '');
const fileName = `${timestamp}-seed-${seederName}.js`;
const seederPath = path.join(__dirname, '..', 'seeders', fileName);

const template = `
'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    /**
     * Add seed commands here.
     *
     * Example:
     * await queryInterface.bulkInsert('People', [{
     *   name: 'John Doe',
     *   isBetaMember: false
     * }], {});
    */
  },

  down: async (queryInterface, Sequelize) => {
    /**
     * Add commands to revert seed here.
     *
     * Example:
     * await queryInterface.bulkDelete('People', null, {});
     */
  }
};
`;

fs.writeFileSync(seederPath, template);

console.log(`Created seeder: ${fileName}`);
