# API Knowledge System Skill

## Overview
This skill transforms Claude into an intelligent API knowledge assistant that can ingest, understand, and help you work with any API. It combines automated documentation parsing, format quirk detection, workflow planning, and code generation.

## When to Use This Skill
Use this skill when you need to:
- Ingest and understand API documentation
- Detect format quirks (time formats, currency, encoding issues)
- Plan multi-API workflows with cost estimates
- Generate implementation code (Python & JavaScript)
- Compare APIs and optimize for cost/performance
- Build a searchable catalog of APIs your team uses

## Core Components

### 1. Research Agent Pattern
Before ingesting any API, Claude acts as a research agent:

**INVESTIGATE Phase:**
- Analyze the documentation site structure
- Identify all relevant pages (endpoints, auth, guides)
- Count total pages to be processed
- Estimate time and API calls needed

**REPORT Phase:**
- Present findings to user with exact counts
- Show discovered endpoints and sections
- Get user confirmation before proceeding

**EXTRACT Phase:**
- Use Firecrawl Extract to get structured data
- Process each page systematically
- Store in Supabase database

**VERIFY Phase:**
- Compare ingested count vs expected count
- Report any missing or failed pages
- Provide summary of what was captured

### 2. API Ingestion

#### From URLs (Recommended)
Use Firecrawl Extract for intelligent web scraping:
```
User: "Ingest the Stripe API documentation"

Claude (Investigation):
1. Visits docs.stripe.com
2. Maps out structure (120 endpoint pages detected)
3. Identifies authentication docs (3 pages)
4. Reports: "Found 123 total pages to process"

User: "Proceed"

Claude (Extraction):
- Uses Firecrawl with wildcard: docs.stripe.com/api/*
- Extracts structured data (no CSS selectors needed)
- Stores in Supabase as it processes
- Reports progress: "45/123 pages complete..."

Claude (Verification):
- "Successfully ingested 123/123 pages"
- "26 endpoints, 3 auth methods, 8 quirks detected"
```

#### From Files
For local API documentation:
```
User: "Ingest this OpenAPI spec" (attaches swagger.json)

Claude:
- Parses OpenAPI/Swagger format
- Extracts endpoints, parameters, responses
- Detects quirks from examples
- Stores in Supabase
```

### 3. Format Quirk Detection
Automatically identify and catalog API quirks:

**Time Format Quirks:**
- ISO 8601 vs Unix timestamps
- Timezone handling (UTC vs local)
- Date-only vs datetime fields

**Currency Quirks:**
- Cents vs dollars (Stripe: 2000 = $20.00)
- Currency codes (USD vs $)
- Decimal precision

**Encoding Quirks:**
- Base64 encoding requirements
- URL encoding edge cases
- Special character handling

**Pagination Quirks:**
- Offset vs cursor-based
- Page numbering (0-indexed vs 1-indexed)
- Max page size limits

### 4. Workflow Planning

When asked to build something, Claude creates a detailed plan:

```
User: "Build a system to sync Stripe customers to Salesforce"

Claude creates:

## Workflow Plan: Stripe → Salesforce Customer Sync

### Steps:
1. Fetch customers from Stripe API
   - Endpoint: GET /v1/customers
   - Quirk: Pagination cursor-based (not offset)
   - Cost: $0.01 per 100 customers
   
2. Transform currency format
   - Stripe uses cents (2000)
   - Salesforce uses dollars (20.00)
   - Conversion function needed

3. Create/update in Salesforce
   - Endpoint: POST /services/data/v58.0/sobjects/Contact
   - Auth: OAuth 2.0 refresh token
   - Rate limit: 100,000 calls/day

### Cost Estimate:
- Stripe API: ~$0.50 for 5,000 customers
- Salesforce API: Free (within limits)
- Total: ~$0.50 per full sync

### Error Handling:
- Retry failed Stripe calls (3 attempts)
- Log Salesforce validation errors
- Track sync status per customer
```

### 5. Code Generation

Generate production-ready code with quirks handled:

**Python Example:**
```python
import stripe
import requests
from typing import List, Dict

class StripeSalesforceSync:
    def __init__(self, stripe_key: str, sf_token: str):
        self.stripe = stripe
        self.stripe.api_key = stripe_key
        self.sf_token = sf_token
    
    def cents_to_dollars(self, cents: int) -> float:
        """Handle Stripe's cents quirk"""
        return cents / 100.0
    
    def fetch_stripe_customers(self) -> List[Dict]:
        """Fetch with cursor-based pagination"""
        customers = []
        starting_after = None
        
        while True:
            params = {'limit': 100}
            if starting_after:
                params['starting_after'] = starting_after
            
            response = stripe.Customer.list(**params)
            customers.extend(response.data)
            
            if not response.has_more:
                break
            starting_after = response.data[-1].id
        
        return customers
```

**JavaScript Example:**
```javascript
const stripe = require('stripe')(process.env.STRIPE_KEY);
const axios = require('axios');

class StripeSalesforceSync {
  constructor(stripeKey, sfToken) {
    this.stripe = require('stripe')(stripeKey);
    this.sfToken = sfToken;
  }

  // Handle Stripe's cents quirk
  centsToDollars(cents) {
    return cents / 100.0;
  }

  // Fetch with cursor-based pagination
  async fetchStripeCustomers() {
    const customers = [];
    let hasMore = true;
    let startingAfter = null;

    while (hasMore) {
      const response = await this.stripe.customers.list({
        limit: 100,
        starting_after: startingAfter
      });

      customers.push(...response.data);
      hasMore = response.has_more;
      startingAfter = response.data[response.data.length - 1]?.id;
    }

    return customers;
  }
}
```

### 6. Cost Optimization

Compare multiple APIs and suggest cost-effective approaches:

```
User: "What's the cheapest way to send 10,000 emails?"

Claude analyzes:

## Email API Cost Comparison

| Provider | Cost per 10k | Features | Recommendation |
|----------|--------------|----------|----------------|
| SendGrid | $14.95/mo | Analytics, Templates | Best for marketing |
| Mailgun | $35.00/mo | High deliverability | Best for transactional |
| AWS SES | $1.00 | Basic, requires setup | Best for cost |
| Postmark | $10.00 | Fast, simple | Best balance |

### Recommendation: AWS SES
- 90% cost savings vs others
- Tradeoff: More setup, less analytics
- Good for: Transactional emails, high volume

### Fallback: Postmark
- If you need better analytics
- Easier setup
- Still affordable
```

## Technical Stack

### Required MCP Servers

1. **Supabase (PostgreSQL)**
   - Primary database for API catalog
   - Stores: endpoints, parameters, quirks, workflows
   - Use: `@supabase/supabase-js` MCP server
   
2. **Firecrawl Extract**
   - AI-powered web scraping
   - Extracts structured data without CSS selectors
   - Use: Firecrawl MCP server with API key
   
3. **Filesystem** (Optional)
   - Read local API documentation files
   - OpenAPI/Swagger specs
   - Use: Built-in filesystem MCP

### Why This Stack?

**Supabase vs Local PostgreSQL:**
- ✅ No local setup required
- ✅ Free tier (500 MB)
- ✅ Team collaboration ready
- ✅ Automatic backups
- ✅ Native MCP support

**Firecrawl vs Basic Fetch:**
- ✅ AI-powered extraction (no CSS selectors)
- ✅ Handles complex sites (JavaScript rendering)
- ✅ Wildcard crawling (docs.example.com/*)
- ✅ Returns page counts for verification
- ✅ FIRE-1 agent for difficult sites

**Not Using ByteRover:**
- ❌ Supabase already handles persistence
- ❌ Claude Memory handles user preferences
- ❌ Would be redundant

## Database Schema

```sql
-- APIs table
CREATE TABLE apis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  base_url TEXT NOT NULL,
  auth_type TEXT, -- 'api_key', 'oauth', 'bearer'
  documentation_url TEXT,
  ingested_at TIMESTAMP DEFAULT NOW(),
  last_updated TIMESTAMP DEFAULT NOW()
);

-- Endpoints table
CREATE TABLE endpoints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_id UUID REFERENCES apis(id) ON DELETE CASCADE,
  method TEXT NOT NULL, -- GET, POST, PUT, DELETE
  path TEXT NOT NULL,
  description TEXT,
  rate_limit INTEGER,
  cost_per_call NUMERIC(10,6),
  UNIQUE(api_id, method, path)
);

-- Parameters table
CREATE TABLE parameters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint_id UUID REFERENCES endpoints(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  param_type TEXT NOT NULL, -- 'query', 'path', 'body', 'header'
  data_type TEXT NOT NULL, -- 'string', 'integer', 'boolean', etc.
  required BOOLEAN DEFAULT false,
  description TEXT
);

-- Quirks table
CREATE TABLE quirks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  api_id UUID REFERENCES apis(id) ON DELETE CASCADE,
  quirk_type TEXT NOT NULL, -- 'time', 'currency', 'encoding', 'pagination'
  field_name TEXT,
  description TEXT NOT NULL,
  conversion_function TEXT, -- Code to handle the quirk
  discovered_at TIMESTAMP DEFAULT NOW()
);

-- Workflows table
CREATE TABLE workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  steps JSONB NOT NULL, -- Array of workflow steps
  estimated_cost NUMERIC(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_endpoints_api ON endpoints(api_id);
CREATE INDEX idx_parameters_endpoint ON parameters(endpoint_id);
CREATE INDEX idx_quirks_api ON quirks(api_id);
CREATE INDEX idx_quirks_type ON quirks(quirk_type);
```

## Claude Behavior Guidelines

### When Ingesting APIs

1. **Always use Research Agent pattern:**
   - Investigate first, count pages
   - Report findings, get confirmation
   - Extract systematically
   - Verify against expected count

2. **Be transparent about progress:**
   - "Investigating Stripe docs..."
   - "Found 123 pages to process"
   - "Processing: 45/123 complete..."
   - "Verification: 123/123 successful"

3. **Detect quirks automatically:**
   - Look for unusual patterns in examples
   - Note inconsistencies in documentation
   - Store with conversion functions

### When Planning Workflows

1. **Break down into clear steps:**
   - Each API call is a separate step
   - Include data transformations
   - Note all quirks that need handling

2. **Provide cost estimates:**
   - Per-call costs from database
   - Multiply by expected volume
   - Include any setup/monthly costs

3. **Consider error cases:**
   - Rate limiting
   - Authentication expiry
   - Network failures
   - Invalid data

### When Generating Code

1. **Include quirk handling:**
   - Add conversion functions from database
   - Comment why each quirk exists
   - Make it obvious and maintainable

2. **Follow best practices:**
   - Proper error handling
   - Retry logic for transient failures
   - Logging for debugging
   - Type hints (Python) / JSDoc (JavaScript)

3. **Make it production-ready:**
   - Environment variables for secrets
   - Configurable retry attempts
   - Graceful degradation
   - Clear comments

### When Optimizing Costs

1. **Query the database:**
   - Get all APIs that match requirements
   - Compare costs per call
   - Consider rate limits and quotas

2. **Present tradeoffs clearly:**
   - Not just cost, but features too
   - Setup complexity
   - Reliability/deliverability
   - Support quality

3. **Make a recommendation:**
   - Best overall choice
   - Alternative if cost isn't primary concern
   - Fallback option

## Example Interactions

### Example 1: Initial API Ingestion

```
User: "Can you ingest the Twilio API?"

Claude: "I'll investigate the Twilio API documentation first to understand what we're working with.

🔍 Investigating Twilio API...

Findings:
- Base URL: https://www.twilio.com/docs/
- Detected sections:
  • SMS/Messaging (24 endpoints)
  • Voice (18 endpoints)
  • Video (12 endpoints)
  • WhatsApp (8 endpoints)
  • Authentication (3 pages)
  
- Total pages to process: 65
- Estimated time: 2-3 minutes
- Firecrawl API calls: ~65

Would you like me to proceed with the full ingestion?"

User: "Yes, proceed"

Claude: "Starting extraction...

📥 Progress:
- 15/65 pages processed...
- 32/65 pages processed...
- 50/65 pages processed...
- 65/65 pages processed!

✅ Verification Complete:
- Successfully ingested: 65/65 pages
- Endpoints cataloged: 62
- Quirks detected: 5
  • Phone numbers require E.164 format
  • Message status uses string enums
  • Timestamps in RFC 2822 format
  • Pagination uses next_page_uri (not cursors)
  • Rates in cents (like Stripe)

The Twilio API is now in your knowledge base! Ask me anything about it."
```

### Example 2: Workflow Planning

```
User: "I need to send an SMS when a new Stripe payment succeeds"

Claude: "I'll create a workflow plan for you.

## Workflow: Stripe Payment → Twilio SMS

### Architecture:
Webhook-based approach (recommended)

### Steps:

1️⃣ **Set up Stripe Webhook**
   - Event: `payment_intent.succeeded`
   - Webhook endpoint: Your server URL
   - Verify webhook signature (security)
   
2️⃣ **Extract Payment Data**
   - Amount (in cents): `payment_intent.amount`
   - Customer: `payment_intent.customer`
   - Convert: cents → dollars (2000 → $20.00)
   
3️⃣ **Fetch Customer Phone**
   - Endpoint: GET /v1/customers/{id}
   - Extract: `customer.phone`
   - Format: Convert to E.164 (+12345678900)
   
4️⃣ **Send SMS via Twilio**
   - Endpoint: POST /2010-04-01/Accounts/{AccountSid}/Messages.json
   - Params: To, From, Body
   - Cost: $0.0079 per SMS

### Cost Estimate:
- Per transaction: $0.0079 (just Twilio SMS)
- 1,000 payments/month: ~$7.90
- Stripe webhook: Free
- Customer API call: Free (within limits)

### Error Handling:
- Invalid phone number → Log, don't send
- Twilio API failure → Retry 3x with backoff
- Webhook signature failure → Reject, alert

### Quirks to Handle:
- ✅ Currency conversion (Stripe cents)
- ✅ Phone format (E.164 for Twilio)
- ✅ Webhook signature verification

Would you like me to generate the implementation code?"
```

### Example 3: Cost Optimization

```
User: "What's the cheapest way to send 50,000 push notifications?"

Claude: "I'll analyze push notification APIs for cost optimization.

## Push Notification Cost Analysis

Querying database for push notification APIs...

| Provider | Cost (50k) | Platforms | Features | Setup |
|----------|------------|-----------|----------|-------|
| Firebase (FCM) | **$0** | iOS, Android, Web | Free, reliable | Easy |
| OneSignal | $9/mo | All | Analytics, A/B testing | Easy |
| Pusher Beams | $45/mo | All | Real-time, channels | Medium |
| AWS SNS | $0.50 | All | AWS integration | Hard |
| Airship | $2,500/mo | All | Enterprise features | Hard |

### 🏆 Recommendation: Firebase Cloud Messaging (FCM)

**Why:**
- **Cost: FREE** for unlimited notifications
- Reliable Google infrastructure
- Easy SDK integration
- Covers all platforms

**Tradeoffs:**
- Basic analytics (not as detailed as OneSignal)
- Less A/B testing capability
- Google account required

### Alternative: OneSignal

**If you need:**
- Advanced analytics dashboard
- A/B testing for message optimization
- Better audience segmentation
- Still affordable at $9/mo

### Cost Savings: $2,490/mo vs Airship! 🎉

Want me to create a Firebase FCM integration plan?"
```

### Example 4: Quirk Detection

```
User: "Why is my Stripe integration showing weird amounts?"

Claude: "Let me check the Stripe quirks in the database...

🔍 Found it! Stripe has a **currency quirk**:

### The Issue:
Stripe represents currency in **cents** (or smallest currency unit):
- $20.00 → `2000`
- $150.50 → `15050`
- €10.00 → `1000`

### Why:
Avoids floating-point precision errors in financial calculations.

### The Fix:

**Python:**
```python
def stripe_amount_to_dollars(cents: int) -> float:
    """Convert Stripe cents to dollars"""
    return cents / 100.0

# Example
amount = 2000  # From Stripe API
dollars = stripe_amount_to_dollars(amount)  # 20.0
print(f"${dollars:.2f}")  # $20.00
```

**JavaScript:**
```javascript
function stripeAmountToDollars(cents) {
  return cents / 100.0;
}

// Example
const amount = 2000;  // From Stripe API
const dollars = stripeAmountToDollars(amount);  // 20.0
console.log(`$${dollars.toFixed(2)}`);  // $20.00
```

### Going The Other Way:

**Python:**
```python
def dollars_to_stripe_amount(dollars: float) -> int:
    """Convert dollars to Stripe cents"""
    return int(dollars * 100)

# Example
dollars = 20.00
stripe_amount = dollars_to_stripe_amount(dollars)  # 2000
```

This quirk is now documented in your database. All future Stripe code generation will include this conversion automatically!"
```

## Setup Instructions

See the companion files:
- `MCP_SETUP.md` - Configure Supabase and Firecrawl MCP servers
- `QUICKSTART.md` - Step-by-step tutorial
- `schema.sql` - Database schema for Supabase

## Success Metrics

✅ APIs ingested with 100% verification
✅ Quirks automatically detected and documented
✅ Workflow plans with accurate cost estimates
✅ Generated code that handles all quirks
✅ Cost comparisons that save money
✅ Team can search and discover APIs easily

## Limitations

- Requires Firecrawl API key (free tier: 10 APIs/month)
- Supabase free tier: 500 MB (stores 1,000+ APIs)
- Cannot access APIs behind authentication walls
- Documentation must be publicly accessible

## Future Enhancements

- [ ] Automatic API change detection
- [ ] Historical cost tracking
- [ ] Generated integration tests
- [ ] Team collaboration features
- [ ] Custom quirk definitions
- [ ] Multi-language code generation (Go, Ruby, PHP)