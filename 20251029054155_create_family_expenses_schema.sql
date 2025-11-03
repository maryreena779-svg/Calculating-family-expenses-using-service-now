/*
  # Family Expense Tracker Schema

  ## Overview
  This migration creates the core schema for tracking family expenses, including
  categories, expense records, and family member management.

  ## New Tables
  
  ### `family_members`
  Stores information about family members who can log expenses
  - `id` (uuid, primary key) - Unique identifier for each family member
  - `name` (text, required) - Full name of the family member
  - `color` (text, required) - Color code for visual identification in UI
  - `created_at` (timestamptz) - Timestamp when the member was added
  
  ### `expense_categories`
  Predefined categories for organizing expenses
  - `id` (uuid, primary key) - Unique identifier for each category
  - `name` (text, required) - Category name (e.g., Groceries, Utilities)
  - `icon` (text, required) - Icon name from lucide-react
  - `color` (text, required) - Color code for category visualization
  - `created_at` (timestamptz) - Timestamp when category was created
  
  ### `expenses`
  Main table for tracking all family expenses
  - `id` (uuid, primary key) - Unique identifier for each expense
  - `description` (text, required) - Description of the expense
  - `amount` (numeric, required) - Expense amount in decimal format
  - `category_id` (uuid, required, foreign key) - Reference to expense_categories
  - `member_id` (uuid, required, foreign key) - Reference to family_members
  - `expense_date` (date, required) - Date when expense occurred
  - `notes` (text) - Optional additional notes
  - `created_at` (timestamptz) - Timestamp when record was created
  - `updated_at` (timestamptz) - Timestamp when record was last updated

  ## Security
  
  ### Row Level Security (RLS)
  All tables have RLS enabled with policies that:
  - Allow public read access for viewing expenses
  - Allow public insert access for adding new expenses
  - Allow public update access for modifying expenses
  - Allow public delete access for removing expenses
  
  Note: This is a simplified single-family application. For production use with
  multiple families, additional authentication and authorization would be required.

  ## Indexes
  - Index on `expenses.category_id` for faster category filtering
  - Index on `expenses.member_id` for faster member-specific queries
  - Index on `expenses.expense_date` for faster date-range queries

  ## Default Data
  The migration includes seed data for:
  - Common expense categories (Groceries, Utilities, Entertainment, etc.)
  - Sample family members to get started
*/

-- Create family_members table
CREATE TABLE IF NOT EXISTS family_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  color text NOT NULL DEFAULT '#3B82F6',
  created_at timestamptz DEFAULT now()
);

-- Create expense_categories table
CREATE TABLE IF NOT EXISTS expense_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  icon text NOT NULL DEFAULT 'DollarSign',
  color text NOT NULL DEFAULT '#10B981',
  created_at timestamptz DEFAULT now()
);

-- Create expenses table
CREATE TABLE IF NOT EXISTS expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  description text NOT NULL,
  amount numeric(10, 2) NOT NULL CHECK (amount >= 0),
  category_id uuid NOT NULL REFERENCES expense_categories(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES family_members(id) ON DELETE CASCADE,
  expense_date date NOT NULL DEFAULT CURRENT_DATE,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_member_id ON expenses(member_id);
CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON expenses(expense_date);

-- Enable Row Level Security
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Create policies for family_members
CREATE POLICY "Anyone can view family members"
  ON family_members FOR SELECT
  USING (true);

CREATE POLICY "Anyone can add family members"
  ON family_members FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update family members"
  ON family_members FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete family members"
  ON family_members FOR DELETE
  USING (true);

-- Create policies for expense_categories
CREATE POLICY "Anyone can view categories"
  ON expense_categories FOR SELECT
  USING (true);

CREATE POLICY "Anyone can add categories"
  ON expense_categories FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update categories"
  ON expense_categories FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete categories"
  ON expense_categories FOR DELETE
  USING (true);

-- Create policies for expenses
CREATE POLICY "Anyone can view expenses"
  ON expenses FOR SELECT
  USING (true);

CREATE POLICY "Anyone can add expenses"
  ON expenses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update expenses"
  ON expenses FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete expenses"
  ON expenses FOR DELETE
  USING (true);

-- Insert default expense categories
INSERT INTO expense_categories (name, icon, color) VALUES
  ('Groceries', 'ShoppingCart', '#10B981'),
  ('Utilities', 'Zap', '#F59E0B'),
  ('Entertainment', 'Film', '#8B5CF6'),
  ('Transportation', 'Car', '#3B82F6'),
  ('Healthcare', 'Heart', '#EF4444'),
  ('Education', 'BookOpen', '#6366F1'),
  ('Dining Out', 'Utensils', '#EC4899'),
  ('Shopping', 'ShoppingBag', '#14B8A6'),
  ('Home', 'Home', '#F97316'),
  ('Other', 'DollarSign', '#6B7280')
ON CONFLICT (name) DO NOTHING;