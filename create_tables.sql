-- SmartHRM Database Tables Creation Script
-- Run this script in your PostgreSQL database to create all necessary tables

-- Sessions table (for authentication)
CREATE TABLE IF NOT EXISTS sessions (
    sid VARCHAR PRIMARY KEY,
    sess JSONB NOT NULL,
    expire TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS IDX_session_expire ON sessions(expire);

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR PRIMARY KEY NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password VARCHAR NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    profile_image_url VARCHAR,
    role VARCHAR NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Employees table
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR NOT NULL REFERENCES users(id),
    employee_id VARCHAR NOT NULL UNIQUE,
    department VARCHAR NOT NULL,
    position VARCHAR NOT NULL,
    start_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    status VARCHAR NOT NULL DEFAULT 'active',
    manager_id INTEGER REFERENCES employees(id),
    is_admin BOOLEAN NOT NULL DEFAULT false,
    phone VARCHAR,
    address TEXT,
    emergency_contact JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Pay records table
CREATE TABLE IF NOT EXISTS pay_records (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    gross_pay DECIMAL(10,2) NOT NULL,
    net_pay DECIMAL(10,2) NOT NULL,
    deductions JSONB,
    pay_date DATE NOT NULL,
    pay_type VARCHAR NOT NULL DEFAULT 'regular',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Time off requests table
CREATE TABLE IF NOT EXISTS time_off_requests (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    type VARCHAR NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days INTEGER NOT NULL,
    reason TEXT,
    status VARCHAR NOT NULL DEFAULT 'pending',
    approver_id INTEGER REFERENCES employees(id),
    request_date TIMESTAMP DEFAULT NOW(),
    response_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Leave balances table
CREATE TABLE IF NOT EXISTS leave_balances (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    casual_leave_balance DECIMAL(5,2) NOT NULL DEFAULT 0,
    vacation_leave_balance DECIMAL(5,2) NOT NULL DEFAULT 0,
    last_accrual_date DATE DEFAULT NOW(),
    last_quarter_accrual DATE,
    year INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Leave accrual history table
CREATE TABLE IF NOT EXISTS leave_accrual_history (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    accrual_type VARCHAR NOT NULL,
    accrual_amount DECIMAL(4,2) NOT NULL,
    accrual_date DATE NOT NULL,
    working_days_completed INTEGER,
    quarter_completed INTEGER,
    reason TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    title VARCHAR NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR NOT NULL DEFAULT 'info',
    sender_id INTEGER NOT NULL REFERENCES employees(id),
    recipient_id INTEGER REFERENCES employees(id),
    is_read BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    scheduled_for TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Cost centers table
CREATE TABLE IF NOT EXISTS cost_centers (
    id SERIAL PRIMARY KEY,
    code VARCHAR NOT NULL UNIQUE,
    name VARCHAR NOT NULL,
    description TEXT,
    department VARCHAR,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Timesheet entries table
CREATE TABLE IF NOT EXISTS timesheet_entries (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    cost_center_id INTEGER NOT NULL REFERENCES cost_centers(id),
    work_date DATE NOT NULL,
    hours_worked DECIMAL(4,2) NOT NULL,
    overtime_hours DECIMAL(4,2) NOT NULL DEFAULT 0,
    break_hours DECIMAL(4,2) NOT NULL DEFAULT 0,
    check_in_time VARCHAR,
    check_out_time VARCHAR,
    remarks TEXT,
    upload_batch_id VARCHAR,
    is_manual_entry BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Payroll components table
CREATE TABLE IF NOT EXISTS payroll_components (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    cost_center_id INTEGER REFERENCES cost_centers(id),
    basic_salary_per_day DECIMAL(10,2) NOT NULL,
    transport_allowance_per_day DECIMAL(8,2) NOT NULL DEFAULT 0,
    food_allowance_per_day DECIMAL(8,2) NOT NULL DEFAULT 0,
    accommodation_allowance_per_day DECIMAL(8,2) NOT NULL DEFAULT 0,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Payroll calculations table
CREATE TABLE IF NOT EXISTS payroll_calculations (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    payroll_period VARCHAR NOT NULL,
    total_days_worked DECIMAL(4,1) NOT NULL,
    total_hours_worked DECIMAL(6,2) NOT NULL,
    overtime_hours DECIMAL(6,2) NOT NULL DEFAULT 0,
    leave_days_taken DECIMAL(4,1) NOT NULL DEFAULT 0,
    basic_salary DECIMAL(12,2) NOT NULL,
    transport_allowance DECIMAL(10,2) NOT NULL DEFAULT 0,
    food_allowance DECIMAL(10,2) NOT NULL DEFAULT 0,
    accommodation_allowance DECIMAL(10,2) NOT NULL DEFAULT 0,
    overtime_pay DECIMAL(10,2) NOT NULL DEFAULT 0,
    gross_salary DECIMAL(12,2) NOT NULL,
    deductions DECIMAL(10,2) NOT NULL DEFAULT 0,
    net_salary DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Employee documents table
CREATE TABLE IF NOT EXISTS employee_documents (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    document_type VARCHAR NOT NULL,
    document_name VARCHAR NOT NULL,
    file_path VARCHAR NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR,
    uploaded_by INTEGER REFERENCES employees(id),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    verified_by INTEGER REFERENCES employees(id),
    verified_at TIMESTAMP,
    expires_at DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- CSV uploads table
CREATE TABLE IF NOT EXISTS csv_uploads (
    id SERIAL PRIMARY KEY,
    filename VARCHAR NOT NULL,
    original_filename VARCHAR NOT NULL,
    file_path VARCHAR NOT NULL,
    file_size INTEGER NOT NULL,
    upload_status VARCHAR NOT NULL DEFAULT 'pending',
    total_records INTEGER,
    processed_records INTEGER DEFAULT 0,
    error_records INTEGER DEFAULT 0,
    error_log TEXT,
    uploaded_by INTEGER REFERENCES employees(id),
    uploaded_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP
);

-- KPI definitions table
CREATE TABLE IF NOT EXISTS kpi_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
    category VARCHAR NOT NULL,
    measurement_unit VARCHAR,
    target_value DECIMAL(10,2),
    weight_percentage DECIMAL(5,2),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_by INTEGER REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Review cycles table
CREATE TABLE IF NOT EXISTS review_cycles (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR NOT NULL DEFAULT 'draft',
    created_by INTEGER REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Employee KPIs table
CREATE TABLE IF NOT EXISTS employee_kpis (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    kpi_id INTEGER NOT NULL REFERENCES kpi_definitions(id),
    review_cycle_id INTEGER NOT NULL REFERENCES review_cycles(id),
    target_value DECIMAL(10,2),
    actual_value DECIMAL(10,2),
    score DECIMAL(5,2),
    comments TEXT,
    self_assessment_score DECIMAL(5,2),
    self_assessment_comments TEXT,
    manager_assessment_score DECIMAL(5,2),
    manager_assessment_comments TEXT,
    final_score DECIMAL(5,2),
    final_comments TEXT,
    status VARCHAR NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Performance reviews table
CREATE TABLE IF NOT EXISTS performance_reviews (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    reviewer_id INTEGER NOT NULL REFERENCES employees(id),
    review_cycle_id INTEGER NOT NULL REFERENCES review_cycles(id),
    review_date DATE NOT NULL,
    overall_rating DECIMAL(3,1),
    strengths TEXT,
    areas_for_improvement TEXT,
    goals_for_next_period TEXT,
    employee_comments TEXT,
    manager_comments TEXT,
    hr_comments TEXT,
    status VARCHAR NOT NULL DEFAULT 'draft',
    submitted_at TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by INTEGER REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Performance improvement plans table
CREATE TABLE IF NOT EXISTS performance_improvement_plans (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    performance_review_id INTEGER REFERENCES performance_reviews(id),
    plan_type VARCHAR NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    objectives TEXT NOT NULL,
    action_items TEXT NOT NULL,
    success_criteria TEXT,
    support_resources TEXT,
    progress_notes TEXT,
    status VARCHAR NOT NULL DEFAULT 'active',
    created_by INTEGER REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_employees_user_id ON employees(user_id);
CREATE INDEX IF NOT EXISTS idx_employees_employee_id ON employees(employee_id);
CREATE INDEX IF NOT EXISTS idx_pay_records_employee_id ON pay_records(employee_id);
CREATE INDEX IF NOT EXISTS idx_time_off_requests_employee_id ON time_off_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_balances_employee_id ON leave_balances(employee_id);
CREATE INDEX IF NOT EXISTS idx_timesheet_entries_employee_id ON timesheet_entries(employee_id);
CREATE INDEX IF NOT EXISTS idx_timesheet_entries_work_date ON timesheet_entries(work_date);
CREATE INDEX IF NOT EXISTS idx_payroll_calculations_employee_id ON payroll_calculations(employee_id);
CREATE INDEX IF NOT EXISTS idx_payroll_calculations_payroll_period ON payroll_calculations(payroll_period);

-- Insert default cost center
INSERT INTO cost_centers (code, name, description, department) 
VALUES ('DEFAULT', 'Default Cost Center', 'Default cost center for new employees', 'General')
ON CONFLICT (code) DO NOTHING; 