require('dotenv').config()
const sqlite3 = require('sqlite3').verbose()
const { open } = require('sqlite')
const path = require('path')
const fs = require('fs')

const DB_PATH = path.join(__dirname, 'database.sqlite')
const SCHEMA_PATH = path.join(__dirname, 'schema_sqlite.sql')

let dbPromise = null

async function getDb() {
  if (!dbPromise) {
    const dbExists = fs.existsSync(DB_PATH)
    dbPromise = open({
      filename: DB_PATH,
      driver: sqlite3.Database
    }).then(async (db) => {
      // Enable foreign keys
      await db.run('PRAGMA foreign_keys = ON')

      if (!dbExists) {
        console.log('📦 Database file not found, creating and running schema...')
        try {
          const schema = fs.readFileSync(SCHEMA_PATH, 'utf8')
          // SQLite node package might struggle with multiple statements in run(),
          // so exec() is better for running full schema scripts.
          await db.exec(schema)
          console.log('✅ SQLite database initialized successfully!')
        } catch (err) {
          console.error('❌ Failed to initialize SQLite schema:', err)
        }
      } else {
        console.log('✅ SQLite connected →', DB_PATH)
      }
      return db
    })
  }
  return dbPromise
}

// Convert $1 $2 OR ? placeholders for consistency.
// SQLite natively supports ?, ?1, $name, etc.
// The existing app uses ? for mysql, which works fine in sqlite too.
// If it uses $1, $2, we convert to ? since mysql was doing that.
const toSQLite = (sql) => {
  return sql
    .replace(/\$\d+/g, '?')
    .replace(/CURDATE\(\)/gi, "date('now')")
    .replace(/NOW\(\)/gi, "CURRENT_TIMESTAMP")
}
const stripReturning = (sql) => sql.replace(/\s+RETURNING\s+[\w\s,.*]+$/i, '')

/**
 * Execute a query.
 * Returns { rows, insertId, affectedRows } to mimic mysql2
 */
const query = async (text, params = []) => {
  const db = await getDb()
  const sql = toSQLite(stripReturning(text))
  try {
    const isSelect = /^\s*SELECT/i.test(sql)
    if (isSelect) {
      const rows = await db.all(sql, params)
      return { rows, insertId: null, affectedRows: rows.length }
    } else {
      const result = await db.run(sql, params)
      // sqlite result object has .lastID and .changes
      return { 
        rows: [], 
        insertId: result.lastID || null, 
        affectedRows: result.changes || 0 
      }
    }
  } catch (err) {
    console.error('❌ DB query error:', err.message, '\n   SQL:', sql.substring(0, 200))
    throw err
  }
}

/**
 * Execute multiple queries in a transaction.
 */
const transaction = async (callback) => {
  const db = await getDb()
  try {
    await db.run('BEGIN TRANSACTION')

    const clientQuery = async (text, params = []) => {
      const sql = toSQLite(stripReturning(text))
      const isSelect = /^\s*SELECT/i.test(sql)
      if (isSelect) {
        const rows = await db.all(sql, params)
        return { rows, insertId: null, affectedRows: rows.length }
      } else {
        const result = await db.run(sql, params)
        return { 
          rows: [], 
          insertId: result.lastID || null, 
          affectedRows: result.changes || 0 
        }
      }
    }

    const result = await callback({ query: clientQuery })
    await db.run('COMMIT')
    return result
  } catch (err) {
    await db.run('ROLLBACK')
    console.error('❌ Transaction rolled back:', err.message)
    throw err
  }
}

// Test connection on startup
getDb().catch(console.error)

module.exports = { query, transaction }
