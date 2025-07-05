import { Pool } from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import * as schema from "@shared/schema";
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';

// Load environment variables
dotenv.config();

if (!process.env.DATABASE_URL) {
  throw new Error(
    "DATABASE_URL must be set. Did you forget to provision a database?",
  );
}

// For now, disable SSL completely to test connection
console.log('Using SSL: false for database connection');

export const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: false,
});
export const db = drizzle(pool, { schema });