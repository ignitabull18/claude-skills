-- API Knowledge System Database Schema
-- For use with Supabase PostgreSQL
-- Version: 1.0

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- APIs Table
-- Stores high-level information about each API
CREATE TABLE IF NOT EXISTS apis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  base_url TEXT NOT NULL,
  auth_type TEXT, -- 'api_key', 'oauth', 'bearer', 'basic', 'none'
  documentation_url TEXT,
  description TEXT,
  version TEXT,
  ingested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Metadata
  provider TEXT, -- Company/organization that provides the API
  category TEXT, -- 'payment', 'email', 'sms', 'crm', 'analytics', etc.
  is_free BOOLEAN DEFAULT false,
  requires_approval BOOLEAN DEFAULT false, -- Does API access require approval?
  
  UNIQUE(name, version)
);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_apis_category ON apis(category);
CREATE INDEX IF NOT EXISTS idx_apis_provider ON apis(provider);
CREATE INDEX IF NOT EXISTS idx_apis_is_free ON apis(is_free);

-- Endpoints Table
-- Stores individual API endpoints
CREATE TABLE IF NOT EXISTS endpoints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  
  -- Endpoint details
  method TEXT NOT NULL, -- 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'
  path TEXT NOT NULL, -- e.g., '/v1/customers'
  description TEXT,
  
  -- Rate limiting
  rate_limit INTEGER, -- Requests per time period
  rate_limit_period TEXT, -- 'second', 'minute', 'hour', 'day', 'month'
  
  -- Cost
  cost_per_call NUMERIC(10,6), -- Cost in USD per API call
  cost_currency TEXT DEFAULT 'USD',
  
  -- Response
  response_format TEXT, -- 'json', 'xml', 'csv', etc.
  success_status_code INTEGER DEFAULT 200,
  
  -- Additional metadata
  is_deprecated BOOLEAN DEFAULT false,
  requires_auth BOOLEAN DEFAULT true,
  pagination_type TEXT, -- 'offset', 'cursor', 'page', 'none'
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(api_id, method, path)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_endpoints_api ON endpoints(api_id);
CREATE INDEX IF NOT EXISTS idx_endpoints_method ON endpoints(method);
CREATE INDEX IF NOT EXISTS idx_endpoints_deprecated ON endpoints(is_deprecated) WHERE is_deprecated = true;

-- Parameters Table
-- Stores parameters for each endpoint
CREATE TABLE IF NOT EXISTS parameters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint_id UUID NOT NULL REFERENCES endpoints(id) ON DELETE CASCADE,
  
  -- Parameter details
  name TEXT NOT NULL,
  param_type TEXT NOT NULL, -- 'query', 'path', 'body', 'header', 'cookie'
  data_type TEXT NOT NULL, -- 'string', 'integer', 'number', 'boolean', 'array', 'object'
  
  -- Validation
  required BOOLEAN DEFAULT false,
  default_value TEXT,
  enum_values TEXT[], -- For enums
  pattern TEXT, -- Regex pattern for validation
  min_value NUMERIC,
  max_value NUMERIC,
  min_length INTEGER,
  max_length INTEGER,
  
  -- Documentation
  description TEXT,
  example TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_parameters_endpoint ON parameters(endpoint_id);
CREATE INDEX IF NOT EXISTS idx_parameters_required ON parameters(required) WHERE required = true;

-- Quirks Table
-- Stores API quirks and their handling logic
CREATE TABLE IF NOT EXISTS quirks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  
  -- Quirk classification
  quirk_type TEXT NOT NULL, -- 'time', 'currency', 'encoding', 'pagination', 'rate_limit', 'custom'
  severity TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'critical'
  
  -- Details
  field_name TEXT, -- Which field/parameter has this quirk?
  description TEXT NOT NULL,
  
  -- Handling
  conversion_function TEXT, -- Code snippet to handle the quirk
  conversion_language TEXT, -- 'python', 'javascript', 'go', etc.
  
  -- Examples
  example_input TEXT,
  example_output TEXT,
  
  -- Discovery
  discovered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  discovered_by TEXT, -- 'auto', 'manual', 'user'
  
  -- Validation
  is_verified BOOLEAN DEFAULT false
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_quirks_api ON quirks(api_id);
CREATE INDEX IF NOT EXISTS idx_quirks_type ON quirks(quirk_type);
CREATE INDEX IF NOT EXISTS idx_quirks_severity ON quirks(severity);

-- Workflows Table
-- Stores user-defined workflows
CREATE TABLE IF NOT EXISTS workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic info
  name TEXT NOT NULL,
  description TEXT,
  
  -- Workflow definition
  steps JSONB NOT NULL, -- Array of workflow steps with API calls
  
  -- Cost analysis
  estimated_cost NUMERIC(10,2),
  cost_currency TEXT DEFAULT 'USD',
  cost_per_execution NUMERIC(10,4),
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by TEXT, -- User identifier
  
  -- Execution stats (for future use)
  execution_count INTEGER DEFAULT 0,
  last_executed_at TIMESTAMP WITH TIME ZONE,
  average_duration_ms INTEGER
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_workflows_created_by ON workflows(created_by);
CREATE INDEX IF NOT EXISTS idx_workflows_created_at ON workflows(created_at DESC);

-- Workflow APIs Table (junction table)
-- Links workflows to the APIs they use
CREATE TABLE IF NOT EXISTS workflow_apis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID NOT NULL REFERENCES workflows(id) ON DELETE CASCADE,
  api_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  
  -- Order and details
  step_order INTEGER NOT NULL,
  calls_per_execution INTEGER DEFAULT 1,
  
  UNIQUE(workflow_id, api_id, step_order)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_workflow_apis_workflow ON workflow_apis(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_apis_api ON workflow_apis(api_id);

-- API Relationships Table
-- Tracks common API pairings and integrations
CREATE TABLE IF NOT EXISTS api_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- The two APIs in relationship
  api_1_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  api_2_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  
  -- Relationship details
  relationship_type TEXT, -- 'integrates_with', 'alternative_to', 'complements', 'requires'
  description TEXT,
  
  -- Usage statistics
  usage_count INTEGER DEFAULT 0, -- How many workflows use this pairing?
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(api_1_id, api_2_id, relationship_type)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_api_rel_api1 ON api_relationships(api_1_id);
CREATE INDEX IF NOT EXISTS idx_api_rel_api2 ON api_relationships(api_2_id);
CREATE INDEX IF NOT EXISTS idx_api_rel_type ON api_relationships(relationship_type);

-- Cost Tracking Table (optional, for future use)
-- Track actual costs over time
CREATE TABLE IF NOT EXISTS cost_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_id UUID NOT NULL REFERENCES apis(id) ON DELETE CASCADE,
  
  -- Date and cost
  tracked_date DATE NOT NULL,
  total_calls INTEGER NOT NULL DEFAULT 0,
  total_cost NUMERIC(10,2) NOT NULL DEFAULT 0,
  cost_currency TEXT DEFAULT 'USD',
  
  -- Breakdown by endpoint (optional)
  endpoint_costs JSONB, -- { "endpoint_id": {"calls": 100, "cost": 0.50} }
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(api_id, tracked_date)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_cost_tracking_api ON cost_tracking(api_id);
CREATE INDEX IF NOT EXISTS idx_cost_tracking_date ON cost_tracking(tracked_date DESC);

-- Views for common queries

-- View: API Summary with endpoint count
CREATE OR REPLACE VIEW api_summary AS
SELECT 
  a.id,
  a.name,
  a.base_url,
  a.auth_type,
  a.category,
  a.is_free,
  a.provider,
  COUNT(DISTINCT e.id) as endpoint_count,
  COUNT(DISTINCT q.id) as quirk_count,
  a.ingested_at,
  a.last_updated
FROM apis a
LEFT JOIN endpoints e ON a.id = e.api_id
LEFT JOIN quirks q ON a.id = q.api_id
GROUP BY a.id;

-- View: Most expensive endpoints
CREATE OR REPLACE VIEW expensive_endpoints AS
SELECT 
  a.name as api_name,
  e.method,
  e.path,
  e.cost_per_call,
  e.cost_currency,
  e.description
FROM endpoints e
JOIN apis a ON e.api_id = a.id
WHERE e.cost_per_call IS NOT NULL
ORDER BY e.cost_per_call DESC
LIMIT 100;

-- View: Critical quirks that need attention
CREATE OR REPLACE VIEW critical_quirks AS
SELECT 
  a.name as api_name,
  q.quirk_type,
  q.severity,
  q.field_name,
  q.description,
  q.is_verified
FROM quirks q
JOIN apis a ON q.api_id = a.id
WHERE q.severity IN ('high', 'critical')
ORDER BY 
  CASE q.severity 
    WHEN 'critical' THEN 1
    WHEN 'high' THEN 2
  END,
  q.discovered_at DESC;

-- Function: Update last_updated timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers: Auto-update timestamps
CREATE TRIGGER update_apis_updated_at
BEFORE UPDATE ON apis
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflows_updated_at
BEFORE UPDATE ON workflows
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Function: Calculate workflow cost
CREATE OR REPLACE FUNCTION calculate_workflow_cost(workflow_uuid UUID)
RETURNS NUMERIC AS $$
DECLARE
  total_cost NUMERIC := 0;
  step_record RECORD;
BEGIN
  FOR step_record IN
    SELECT 
      wa.calls_per_execution,
      e.cost_per_call
    FROM workflow_apis wa
    JOIN endpoints e ON e.api_id = wa.api_id
    WHERE wa.workflow_id = workflow_uuid
      AND e.cost_per_call IS NOT NULL
  LOOP
    total_cost := total_cost + (step_record.calls_per_execution * COALESCE(step_record.cost_per_call, 0));
  END LOOP;
  
  RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

-- Seed data: Common API categories
INSERT INTO apis (name, category, is_free, description) VALUES
  ('Example API', 'example', true, 'Placeholder for testing')
ON CONFLICT DO NOTHING;

-- Comments for documentation
COMMENT ON TABLE apis IS 'High-level API information';
COMMENT ON TABLE endpoints IS 'Individual API endpoints with methods and paths';
COMMENT ON TABLE parameters IS 'Parameters for each endpoint';
COMMENT ON TABLE quirks IS 'API quirks and their handling logic';
COMMENT ON TABLE workflows IS 'User-defined workflows combining multiple APIs';
COMMENT ON TABLE workflow_apis IS 'Junction table linking workflows to APIs';
COMMENT ON TABLE api_relationships IS 'Tracks common API pairings';
COMMENT ON TABLE cost_tracking IS 'Historical cost tracking data';

-- Grant permissions (adjust as needed for your Supabase setup)
-- These are examples - modify based on your security requirements
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'API Knowledge System schema created successfully!';
  RAISE NOTICE 'Tables: apis, endpoints, parameters, quirks, workflows, workflow_apis, api_relationships, cost_tracking';
  RAISE NOTICE 'Views: api_summary, expensive_endpoints, critical_quirks';
  RAISE NOTICE 'You can now start ingesting APIs!';
END $$;
