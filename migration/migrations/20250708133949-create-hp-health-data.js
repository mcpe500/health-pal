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
  return db.createTable('hp_health_data', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    user_id: {
      type: 'int',
      notNull: true,
      foreignKey: {
        name: 'hp_health_data_user_id_fk',
        table: 'users',
        rules: {
          onDelete: 'CASCADE',
          onUpdate: 'RESTRICT'
        },
        mapping: 'id'
      }
    },
    data_type: { type: 'string', length: 100, notNull: true },
    value: { type: 'decimal', precision: 10, scale: 2, notNull: true },
    unit: { type: 'string', length: 50, notNull: true },
    timestamp: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    created_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    updated_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
  });
};

exports.down = function(db) {
  return db.dropTable('hp_health_data');
};