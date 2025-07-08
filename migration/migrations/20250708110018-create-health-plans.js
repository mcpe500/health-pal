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
  return db.createTable('health_plans', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    user_id: {
      type: 'int',
      notNull: true,
      foreignKey: {
        name: 'health_plans_user_id_fk',
        table: 'users',
        rules: {
          onDelete: 'CASCADE',
          onUpdate: 'RESTRICT'
        },
        mapping: 'id'
      }
    },
    goal: { type: 'string', length: 255, notNull: true },
    plan_details: { type: 'text', notNull: true }, // JSON representation of the plan
    generated_date: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    created_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    updated_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
  });
};

exports.down = function(db) {
  return db.dropTable('health_plans');
};