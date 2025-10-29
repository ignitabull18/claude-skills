# API Knowledge System

Transform Claude into an intelligent API knowledge assistant that can ingest, understand, and help you work with any API.

## What This Skill Does

🧠 **Intelligent API Ingestion**
- Automatically scrapes and understands API documentation
- Uses AI-powered extraction (Firecrawl Extract)
- Verifies complete ingestion with page counts

🔍 **Format Quirk Detection**
- Automatically identifies API quirks (time formats, currency, encoding)
- Stores conversion functions for each quirk
- Applies fixes in generated code

📋 **Workflow Planning**
- Creates detailed multi-API workflow plans
- Calculates cost estimates
- Identifies error cases and rate limits

💻 **Code Generation**
- Generates production-ready Python & JavaScript
- Includes all quirk handling automatically
- Proper error handling and retry logic

💰 **Cost Optimization**
- Compares multiple APIs for same functionality
- Recommends most cost-effective approach
- Shows tradeoffs clearly

## Quick Start

### 1. Prerequisites
- Claude Desktop installed
- Supabase account (free tier)
- Firecrawl API key (free tier: 10 APIs/month)

### 2. Setup MCP Servers

See [MCP_SETUP.md](./MCP_SETUP.md) for detailed instructions.

### 3. First Use

```
You: "Ingest the Stripe API documentation"

Claude investigates, reports findings, extracts data, and verifies completeness.
You'll have a fully cataloged API ready to use!
```

### 4. Start Building

```
You: "Plan a workflow to send SMS when a Stripe payment succeeds"

Claude creates a detailed plan with:
- Step-by-step instructions
- Cost estimates
- Quirk handling
- Error cases
```

### 5. Generate Code

```
You: "Generate Python code for that workflow"

Claude produces production-ready code with:
- All quirks handled automatically
- Proper error handling
- Retry logic
- Clear comments
```

## Architecture

```
┌─────────────────┐
│ Claude Desktop  │
│   + Skill       │
└────────┬────────┘
         │
         ├─────────► Supabase PostgreSQL
         │            (API Catalog Storage)
         │
         ├─────────► Firecrawl Extract  
         │            (AI Web Scraping)
         │
         └─────────► Filesystem MCP
                      (Local Files)
```

## Tech Stack

| Component | Purpose | Why |
|-----------|---------|-----|
| **Supabase** | Database | Free tier, hosted, team-ready |
| **Firecrawl Extract** | Web scraping | AI-powered, no CSS selectors |
| **Claude Memory** | User preferences | Built-in, automatic |
| **PostgreSQL** | Structured data | Relationships, indexing, SQL |

## What Gets Stored

### In Supabase:
- API endpoints with parameters
- Detected format quirks
- Conversion functions
- Workflow plans
- Cost data

### In Claude Memory:
- Your preferred programming language
- Frequently used APIs
- Cost threshold preferences
- Team member names

## Example Use Cases

### 1. Payment Processing
```
"Compare Stripe vs PayPal vs Square for processing $10,000/month in payments"
```

### 2. Email Automation
```
"Build a system to send email receipts when Shopify orders are created"
```

### 3. Customer Communication
```
"Send WhatsApp message when a Zendesk ticket is created"
```

### 4. Data Sync
```
"Sync HubSpot contacts to Salesforce every hour"
```

### 5. Monitoring
```
"Send Slack alert when Sentry detects an error"
```

## Cost

### Free Tier Covers:
- ✅ Supabase: 500 MB storage (1,000+ APIs)
- ✅ Firecrawl: 10 APIs per month
- ✅ Claude Desktop: Your existing subscription

### Paid Tiers (Optional):
- Firecrawl: $30/mo for 100 APIs
- Supabase: $25/mo for 8 GB (if you exceed free tier)

**Most users stay free forever!**

## Files

- `SKILL.md` - Complete skill documentation for Claude
- `MCP_SETUP.md` - MCP server configuration guide
- `QUICKSTART.md` - Step-by-step tutorial
- `schema.sql` - PostgreSQL database schema
- `EXECUTIVE_SUMMARY.md` - Technical decisions and rationale
- `UPDATED_ARCHITECTURE.md` - Detailed architecture with examples

## Support

Need help? Check:
- [Firecrawl Documentation](https://docs.firecrawl.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Claude Desktop MCP Guide](https://modelcontextprotocol.io/)

## Contributing

Found a quirk that should be detected automatically? Open an issue or PR!

## License

MIT