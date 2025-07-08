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
  return db.createTable('reminders', {
    id: { type: 'int', primaryKey: true, autoIncrement: true },
    user_id: {
      type: 'int',
      notNull: true,
      foreignKey: {
        name: 'reminders_user_id_fk',
        table: 'users',
        rules: {
          onDelete: 'CASCADE',
          onUpdate: 'RESTRICT'
        },
        mapping: 'id'
      }
    },
    reminder_text: { type: 'text', notNull: true },
    scheduled_time: { type: 'datetime', notNull: true },
    sent_at: { type: 'datetime', defaultValue: null },
    status: { type: 'string', length: 50, notNull: true, defaultValue: 'pending' },
    created_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
    updated_at: { type: 'datetime', defaultValue: new String('CURRENT_TIMESTAMP') },
  });
};

exports.down = function(db) {
  return db.dropTable('reminders');
};