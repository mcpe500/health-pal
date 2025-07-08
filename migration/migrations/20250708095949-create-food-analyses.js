'use strict';

var dbm;
var type;
var seed;

/**
 * We receive the dbmigrate dependency from dbmigrate initially.
 * This enables us to not have to rely on NODE_PATH.
 */
exports.setup = function(options, seedLink) {
  dbm = options.dbmigrate;
  type = dbm.dataType;
  seed = seedLink;
};

exports.up = function(db) {
  return db.createTable('food_analyses', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    food_photo_id: {
      type: 'int',
      notNull: true,
      foreignKey: {
        name: 'food_analyses_food_photo_id_fk',
        table: 'food_photos',
        rules: {
          onDelete: 'CASCADE',
          onUpdate: 'RESTRICT'
        },
        mapping: 'id'
      }
    },
    detected_items: { type: 'text', notNull: true },
    total_calories: { type: 'decimal', precision: 10, scale: 2, notNull: true },
    analysis_date: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    created_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    updated_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
  });
};

exports.down = function(db) {
  return db.dropTable('food_analyses');
};