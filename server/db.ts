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
try {
  if (process.env.NODE_ENV === 'production') {
    const certPath = path.join(process.cwd(), 'rds-ca-2019-root.pem');
    console.log('Certificate path:', certPath);
    console.log('Certificate exists:', fs.existsSync(certPath));
    
    sslConfig = {
      rejectUnauthorized: true,
      ca: fs.readFileSync(certPath).toString(),
    };
  } else {
    sslConfig = {
      rejectUnauthorized: false,
    };
  }
} catch (error) {
  console.error('SSL configuration error:', error);
  // Fallback to basic SSL
  sslConfig = {
    rejectUnauthorized: false,
  };
}

// Parse connection string and add SSL parameters
const connectionString = process.env.DATABASE_URL;
const sslConnectionString = connectionString.includes('?') 
  ? `${connectionString}&sslmode=require`
  : `${connectionString}?sslmode=require`;

export const pool = new Pool({ 
  connectionString: sslConnectionString,
  ssl: sslConfig,
});
export const db = drizzle(pool, { schema });