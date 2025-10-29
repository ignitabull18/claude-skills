# Quick Start Guide

Get started with the API Knowledge System in 30 minutes!

## Prerequisites

✅ Claude Desktop installed
✅ MCP servers configured (see [MCP_SETUP.md](./MCP_SETUP.md))
✅ This skill added to Claude Desktop

## Tutorial: Your First API Ingestion

We'll ingest the JSONPlaceholder API (a free fake API for testing).

### Step 1: Open Claude Desktop

Make sure your MCP servers are running (you should see them listed when you open Claude Desktop).

### Step 2: Start the Ingestion

**You:**
```
Ingest the JSONPlaceholder API documentation from https://jsonplaceholder.typicode.com/
```

**Claude will:**
1. 🔍 Investigate the site
2. 📊 Count pages to process
3. 📝 Report findings
4. ⏸️ Wait for your confirmation

**Example Response:**
```
🔍 Investigating JSONPlaceholder API...

Findings:
- Base URL: https://jsonplaceholder.typicode.com/
- Detected endpoints:
  • Posts (GET, POST, PUT, DELETE)
  • Comments (GET, POST)
  • Albums (GET, POST)
  • Photos (GET, POST)
  • Todos (GET, POST)
  • Users (GET, POST)
  
- Total pages to process: 12
- Estimated time: 1 minute
- Firecrawl API calls: ~12

Would you like me to proceed with the full ingestion?
```

### Step 3: Confirm

**You:**
```
Yes, proceed
```

**Claude will:**
1. 📥 Extract with Firecrawl
2. 💾 Store in Supabase
3. 🔍 Detect quirks
4. ✅ Verify completeness

**Example Response:**
```
📥 Starting extraction...

Progress:
- 3/12 pages processed...
- 7/12 pages processed...
- 12/12 pages processed!

✅ Verification Complete:
- Successfully ingested: 12/12 pages
- Endpoints cataloged: 6
- Quirks detected: 1
  • Returns id as integer (not UUID)

The JSONPlaceholder API is now in your knowledge base!
```

### Step 4: Query the API

**You:**
```
What endpoints does the JSONPlaceholder API have?
```

**Claude will:**
Query the database and show you all endpoints with their methods and descriptions.

## Tutorial: Create a Workflow

Now let's create a practical workflow.

### Step 1: Ask for a Workflow

**You:**
```
Create a workflow to fetch all posts from JSONPlaceholder and save them to a CSV file
```

**Claude will:**
1. 📋 Create detailed plan
2. 💰 Estimate costs
3. ⚠️ Identify error cases
4. 🔧 Note quirks to handle

**Example Response:**
```
## Workflow: JSONPlaceholder Posts → CSV Export

### Steps:

1️⃣ **Fetch All Posts**
   - Endpoint: GET /posts
   - Returns: Array of post objects
   - Rate limit: None (free API)
   - Cost: $0 (free)
   
2️⃣ **Transform Data**
   - Extract fields: id, userId, title, body
   - Handle quirk: id is integer (not UUID)
   - Validate data completeness
   
3️⃣ **Write to CSV**
   - Headers: id, userId, title, body
   - Encoding: UTF-8
   - File: posts_export.csv

### Cost Estimate:
- API calls: Free
- Processing: Local
- Total: $0

### Error Handling:
- Network timeout → Retry 3x
- Invalid data → Log and skip
- File write error → Alert user

Would you like me to generate the implementation code?
```

### Step 2: Generate Code

**You:**
```
Yes, generate Python code
```

**Claude will:**
Generate production-ready Python code with:
- ✅ All quirks handled
- ✅ Error handling
- ✅ Retry logic
- ✅ Clear comments

**Example Code Generated:**
```python
import requests
import csv
import time
from typing import List, Dict

class JSONPlaceholderExporter:
    BASE_URL = "https://jsonplaceholder.typicode.com"
    MAX_RETRIES = 3
    RETRY_DELAY = 1  # seconds
    
    def fetch_posts(self) -> List[Dict]:
        """Fetch all posts with retry logic"""
        for attempt in range(self.MAX_RETRIES):
            try:
                response = requests.get(
                    f"{self.BASE_URL}/posts",
                    timeout=10
                )
                response.raise_for_status()
                return response.json()
            except requests.RequestException as e:
                if attempt == self.MAX_RETRIES - 1:
                    raise
                print(f"Attempt {attempt + 1} failed: {e}")
                time.sleep(self.RETRY_DELAY)
    
    def export_to_csv(self, filename: str = "posts_export.csv"):
        """Export posts to CSV file"""
        posts = self.fetch_posts()
        
        # Note: id is integer (not UUID) - this is a known quirk
        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=['id', 'userId', 'title', 'body'])
            writer.writeheader()
            
            for post in posts:
                try:
                    writer.writerow({
                        'id': post['id'],
                        'userId': post['userId'],
                        'title': post['title'],
                        'body': post['body']
                    })
                except (KeyError, TypeError) as e:
                    print(f"Skipping invalid post: {e}")
                    continue
        
        print(f"Successfully exported {len(posts)} posts to {filename}")

# Usage
if __name__ == "__main__":
    exporter = JSONPlaceholderExporter()
    exporter.export_to_csv()
```

## Tutorial: Cost Optimization

Let's compare different APIs for a common use case.

### Step 1: Ask for Comparison

**You:**
```
What's the cheapest way to send 10,000 transactional emails?
```

**Claude will:**
1. 🔍 Query database for email APIs
2. 💰 Compare costs
3. ⚖️ Show tradeoffs
4. 🎯 Make recommendation

**Example Response:**
```
## Email API Cost Comparison (10,000 emails)

| Provider | Cost | Setup | Deliverability | Analytics |
|----------|------|-------|----------------|------------|
| AWS SES | $1.00 | Hard | Excellent | Basic |
| SendGrid | $14.95 | Easy | Excellent | Advanced |
| Mailgun | $35.00 | Medium | Excellent | Advanced |
| Postmark | $10.00 | Easy | Excellent | Good |

### 🏆 Recommendation: AWS SES

**Why:**
- **90% cost savings** vs alternatives
- Excellent deliverability
- Scales to millions

**Tradeoffs:**
- Requires AWS account setup
- Basic analytics (need external tools)
- Steeper learning curve

**Best for:**
- High-volume transactional emails
- Cost-sensitive applications
- Teams comfortable with AWS

### Alternative: Postmark

**If you value:**
- Easier setup (5 minutes)
- Better analytics
- Great documentation
- Worth the extra $9/mo for convenience

**Best for:**
- Startups wanting fast setup
- Teams without AWS experience
- Balance of cost and features
```

## Common Tasks

### Ingest from URL
```
Ingest the [API name] documentation from [URL]
```

### Ingest from File
```
Ingest this OpenAPI specification
[Attach file]
```

### Search APIs
```
What payment processing APIs do we have in the database?
```

### Check for Quirks
```
What quirks does the Stripe API have?
```

### Create Workflow
```
Build a workflow to [describe what you want to do]
```

### Generate Code
```
Generate [Python/JavaScript] code for [workflow name]
```

### Compare Costs
```
Compare costs for [functionality] across all available APIs
```

### Update API
```
Re-ingest the [API name] documentation to get updates
```

## Tips & Tricks

### 1. Be Specific
❌ "Ingest an API"
✅ "Ingest the Stripe API documentation from docs.stripe.com"

### 2. Confirm Counts
Always review the page count before proceeding with ingestion.

### 3. Use Free APIs First
Test with free APIs (JSONPlaceholder, OpenWeatherMap, etc.) before ingesting paid APIs.

### 4. Monitor Firecrawl Usage
Free tier is 10 APIs/month. Check your usage at firecrawl.dev dashboard.

### 5. Update Regularly
Re-ingest APIs quarterly to catch documentation updates.

### 6. Document Custom Quirks
If you discover a quirk not automatically detected, tell Claude:
```
Add a quirk for [API name]: [describe the quirk]
```

## What's Next?

### Intermediate
1. Ingest 3-5 APIs your team uses most
2. Create workflows for common tasks
3. Generate and test code in your projects

### Advanced
1. Build multi-API workflows (API chaining)
2. Set up cost monitoring and alerts
3. Create custom quirk detection rules
4. Share your API catalog with your team

## Troubleshooting

### "Firecrawl rate limit exceeded"
**Solution:** Wait until next month or upgrade to paid tier.

### "Page count doesn't match"
**Solution:** Some pages may have failed. Claude will report which ones. Try re-ingesting just those pages.

### "Database error"
**Solution:** Check Supabase dashboard to ensure project is active and not paused.

### "Generated code doesn't work"
**Solution:** 
1. Check if all quirks are properly handled
2. Verify API credentials in your code
3. Test with curl/Postman first
4. Ask Claude to debug: "This code isn't working: [paste error]"

## Need Help?

Ask Claude!

```
I'm stuck with [describe problem]
```

Claude can:
- Debug issues
- Explain quirks
- Suggest alternatives
- Optimize workflows
- Answer questions about any ingested API

## Next Steps

✅ Complete this tutorial
✅ Read [SKILL.md](./SKILL.md) for comprehensive documentation
✅ Review [EXECUTIVE_SUMMARY.md](./EXECUTIVE_SUMMARY.md) for technical details
✅ Start ingesting your production APIs!

Happy API building! 🚀