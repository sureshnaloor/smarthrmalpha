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

// Set Node.js to be more permissive with SSL certificates
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

// AWS Lightsail RDS SSL configuration with certificate bundle
console.log('Using SSL with RDS certificate bundle for AWS Lightsail RDS');
console.log('NODE_TLS_REJECT_UNAUTHORIZED set to 0');

// Debug: Log the current working directory and certificate path
const certPath = path.join(process.cwd(), 'rds-ca-2019-root.pem');
console.log('Current working directory:', process.cwd());
console.log('Certificate path:', certPath);
console.log('Certificate file exists:', fs.existsSync(certPath));

export const pool = new Pool({ 
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
    ca: fs.readFileSync(certPath).toString(),
  },
});
export const db = drizzle(pool, { schema });