# MCP Server Setup Guide

This guide will help you configure the required MCP servers for the API Knowledge System skill.

## Required MCP Servers

1. **Supabase (PostgreSQL)** - Primary database
2. **Firecrawl Extract** - AI-powered web scraping
3. **Filesystem** (Optional) - For local API documentation files

## 1. Supabase Setup

### Step 1: Create Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up (free tier is perfect for this)

### Step 2: Create a New Project

1. Click "New Project"
2. Choose a name: `api-knowledge-system`
3. Generate a strong database password (save it!)
4. Choose region closest to you
5. Click "Create new project" (takes ~2 minutes)

### Step 3: Run the Schema

1. In Supabase dashboard, click "SQL Editor" in left sidebar
2. Click "New Query"
3. Copy the entire contents of `schema.sql` from this directory
4. Paste into the editor
5. Click "Run" (bottom right)
6. You should see "Success. No rows returned"

### Step 4: Get Connection String

1. Click "Settings" in left sidebar
2. Click "Database"
3. Scroll to "Connection string" section
4. Copy the "Connection string" (the one labeled "URI")
5. It looks like: `postgresql://postgres:[YOUR-PASSWORD]@db.xxx.supabase.co:5432/postgres`
6. Replace `[YOUR-PASSWORD]` with your actual password

### Step 5: Configure MCP Server

Add to your Claude Desktop config file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://xxx.supabase.co",
        "SUPABASE_ANON_KEY": "your-anon-key-here",
        "DATABASE_URL": "postgresql://postgres:yourpassword@db.xxx.supabase.co:5432/postgres"
      }
    }
  }
}
```

**To get SUPABASE_URL and SUPABASE_ANON_KEY:**
1. In Supabase dashboard, click "Settings"
2. Click "API"
3. Copy "Project URL" as SUPABASE_URL
4. Copy "anon public" key as SUPABASE_ANON_KEY

## 2. Firecrawl Setup

### Step 1: Get API Key

1. Go to [firecrawl.dev](https://firecrawl.dev)
2. Click "Get Started" or "Sign Up"
3. Sign up (free tier: 10 APIs/month)
4. Go to your dashboard
5. Click "API Keys" in the navigation
6. Copy your API key (starts with `fc-`)

### Step 2: Configure MCP Server

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "supabase": {
      // ... (from previous step)
    },
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "@mendable/firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "fc-your-api-key-here"
      }
    }
  }
}
```

## 3. Filesystem MCP (Optional)

This is only needed if you want to read local API documentation files.

### Installation

```bash
npm install -g @modelcontextprotocol/server-filesystem
```

### Configuration

Add to your Claude Desktop config:

```json
{
  "mcpServers": {
    "supabase": {
      // ... (from previous steps)
    },
    "firecrawl": {
      // ... (from previous steps)
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/your/api/docs"]
    }
  }
}
```

Replace `/path/to/your/api/docs` with the actual path where you store API documentation files.

## Complete Configuration Example

Here's what your full `claude_desktop_config.json` should look like:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_URL": "https://xxx.supabase.co",
        "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "DATABASE_URL": "postgresql://postgres:yourpassword@db.xxx.supabase.co:5432/postgres"
      }
    },
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "@mendable/firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "fc-xxx"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "~/Documents/api-docs"]
    }
  }
}
```

## Verify Installation

### Step 1: Restart Claude Desktop

Completely quit and restart Claude Desktop for changes to take effect.

### Step 2: Test Supabase Connection

In Claude Desktop:
```
You: "Can you query the apis table in the database?"

Claude: "Let me check..."
[Should successfully query and return empty results if nothing ingested yet]
```

### Step 3: Test Firecrawl

In Claude Desktop:
```
You: "Can you use Firecrawl to extract the content from example.com?"

Claude: "Using Firecrawl Extract..."
[Should successfully extract and show page content]
```

## Troubleshooting

### "Cannot find module '@supabase/mcp-server'"

**Solution:** The `npx` command will auto-install it. Make sure you have Node.js installed:
```bash
node --version  # Should be v16 or higher
```

If not installed:
- **macOS:** `brew install node`
- **Windows:** Download from [nodejs.org](https://nodejs.org)

### "Connection to database failed"

**Solution:**
1. Check your DATABASE_URL is correct
2. Ensure password doesn't have special characters (or URL-encode them)
3. Check Supabase project is not paused (happens after inactivity)
4. Verify you can connect via Supabase dashboard

### "Firecrawl API key invalid"

**Solution:**
1. Get a fresh API key from firecrawl.dev dashboard
2. Make sure you copied the entire key (starts with `fc-`)
3. Check for extra spaces in the config file

### "MCP server not responding"

**Solution:**
1. Check Claude Desktop logs:
   - **macOS:** `~/Library/Logs/Claude/`
   - **Windows:** `%APPDATA%\Claude\logs\`
2. Look for error messages
3. Ensure config JSON is valid (use a JSON validator)
4. Restart Claude Desktop

### "Firecrawl quota exceeded"

**Solution:**
Free tier is 10 APIs/month. Either:
1. Wait until next month
2. Upgrade to paid plan ($30/mo for 100 APIs)
3. Use filesystem MCP for local documentation instead

## Cost Summary

### Free Tier (Recommended for Starting)
- ✅ Supabase: 500 MB (enough for 1,000+ APIs)
- ✅ Firecrawl: 10 APIs per month
- ✅ Claude Desktop: Included with your subscription

**Total: $0/month** for light usage

### Paid Tier (If Needed)
- Supabase: Free tier usually sufficient, but $25/mo if you need more
- Firecrawl: $30/mo for 100 APIs
- Claude Desktop: Your existing subscription

**Total: $30-55/month** for heavy usage

## Security Best Practices

### 1. Never Commit Secrets

Do NOT commit your `claude_desktop_config.json` to git if it contains:
- Database passwords
- API keys
- Connection strings

Add to `.gitignore`:
```
claudefde_desktop_config.json
```

### 2. Use Environment Variables (Optional)

For better security, you can set environment variables:

**macOS/Linux:**
```bash
export SUPABASE_URL="https://xxx.supabase.co"
export SUPABASE_ANON_KEY="your-key"
export DATABASE_URL="postgresql://..."
export FIRECRAWL_API_KEY="fc-xxx"
```

Add to `~/.zshrc` or `~/.bashrc` to persist.

**Windows:**
```powershell
[System.Environment]::SetEnvironmentVariable('FIRECRAWL_API_KEY', 'fc-xxx', 'User')
```

Then in config, reference them:
```json
{
  "mcpServers": {
    "firecrawl": {
      "command": "npx",
      "args": ["-y", "@mendable/firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}"
      }
    }
  }
}
```

### 3. Rotate Keys Regularly

Change your API keys every 90 days:
1. Generate new key in Firecrawl dashboard
2. Update config
3. Restart Claude Desktop
4. Delete old key

## Next Steps

Once setup is complete:
1. ✅ Read [QUICKSTART.md](./QUICKSTART.md) for your first API ingestion
2. ✅ Try the examples in [SKILL.md](./SKILL.md)
3. ✅ Start building workflows!

## Getting Help

- **Supabase Issues:** [supabase.com/docs](https://supabase.com/docs)
- **Firecrawl Issues:** [docs.firecrawl.dev](https://docs.firecrawl.dev)
- **MCP Issues:** [modelcontextprotocol.io](https://modelcontextprotocol.io/)
- **Claude Desktop:** [support.claude.com](https://support.claude.com)