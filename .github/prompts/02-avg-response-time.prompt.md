---
agent: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server/*']
description: 'Print average response time per service'
---
Your goal is to display the average response time and p50 response time for services in Dynatrace.

Requirements:

* Run this query:

```
timeseries by:{dt.entity.service}, avg_response_time = avg(dt.service.request.response_time), p50_response_time = percentile(dt.service.request.response_time, 50) 
| lookup [fetch dt.entity.service], sourceField:dt.entity.service, lookupField:id, fields:{entity.name} 
| filter startsWith(entity.name, "astroshop-") | sort entity.name
```

If DT_ENVIRONMENT does NOT contain `wkf10640`, omit `| filter startsWith(entity.name, "astroshop-")`

* Display results in a table with 3 columns: service name, average response time, and p50 response time