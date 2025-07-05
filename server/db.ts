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

// Configure SSL based on environment
let sslConfig;
if (process.env.NODE_ENV === 'production') {
  // For AWS Lightsail RDS, use basic SSL without certificate verification
  sslConfig = {
    rejectUnauthorized: false,
  };
  console.log('Using production SSL configuration with rejectUnauthorized: false');
} else {
  sslConfig = {
    rejectUnauthorized: false,
  };
}

// Parse connection string and add SSL parameters
const connectionString = process.env.DATABASE_URL;
const sslConnectionString = connectionString.includes('?') 
  ? `${connectionString}&sslmode=prefer`
  : `${connectionString}?sslmode=prefer`;

export const pool = new Pool({ 
  connectionString: sslConnectionString,
  ssl: sslConfig,
});
export const db = drizzle(pool, { schema });