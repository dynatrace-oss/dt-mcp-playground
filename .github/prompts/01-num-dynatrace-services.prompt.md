---
description: 'List services in Dynatrace for the Astroshop app'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` (or shorter) for all queries unless the user specifies otherwise
- **Result limits**: Always include `| limit 100` (or less) to cap the number of returned records
- **Aggregation preferred**: Use `summarize` to aggregate data rather than fetching raw records when possible

---

Your goal is to list the services in Dynatrace.

## Requirements

* Print the total number of services
* List the services by name, in alphabetical order

## Step-by-Step Instructions

### Step 1: Query the Service Entity Type

Use the `dt.entity.service` entity type to discover all monitored services in the environment.

**Key DQL Pattern**:
```dql
fetch dt.entity.service
| fields entity.name, id
| sort entity.name asc
| limit 100
```

**What this query does**:
- Fetches all service entities from Dynatrace Smartscape
- Retrieves the service name (`entity.name`) and Dynatrace entity ID (`id`)
- Sorts results alphabetically by service name

### Step 2: Count Total Services

To get the total count, use a summarize query:

```dql
fetch dt.entity.service
| summarize service_count = count()
```

Alternatively, you can note the total record count from the first query result.

### Step 3: Present the Results

Format your response to include:

1. **Total Service Count**: State the total number of services discovered
2. **Alphabetical Service List**: List each service name in alphabetical order

**Example output format**:
```
Total number of services: X

Services (alphabetical order):
1. service-name-a
2. service-name-b
3. service-name-c
...
```

## Expected Results

- A complete inventory of all monitored services in the Dynatrace environment
- Services listed with their display names (not entity IDs)
- Clear total count at the beginning of the response
- Services sorted A-Z for easy reference

## Notes

- The `dt.entity.service` entity type includes all services monitored by Dynatrace OneAgent
- Service names may include Kubernetes service names, cloud function names, or traditional application service names
- If no services are found, verify that OneAgent is properly deployed and monitoring is active
