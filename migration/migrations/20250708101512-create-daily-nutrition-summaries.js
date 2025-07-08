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
  return db.createTable('daily_nutrition_summaries', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    user_id: {
      type: 'int',
      notNull: true,
      foreignKey: {
        name: 'daily_nutrition_summaries_user_id_fk',
        table: 'users',
        rules: {
          onDelete: 'CASCADE',
          onUpdate: 'RESTRICT'
        },
        mapping: 'id'
      }
    },
    record_date: { type: 'date', notNull: true, unique: true },
    total_calories: { type: 'decimal', precision: 10, scale: 2, defaultValue: 0.0 },
    total_protein: { type: 'decimal', precision: 10, scale: 2, defaultValue: 0.0 },
    total_carbohydrates: { type: 'decimal', precision: 10, scale: 2, defaultValue: 0.0 },
    total_fats: { type: 'decimal', precision: 10, scale: 2, defaultValue: 0.0 },
    micronutrients_json: { type: 'text', defaultValue: null }, // Storing as JSON string
    created_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    updated_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
  });
};

exports.down = function(db) {
  return db.dropTable('daily_nutrition_summaries');
};