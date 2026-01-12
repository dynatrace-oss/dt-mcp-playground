---
description: 'Print average response time per service'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` (or shorter) for all queries unless the user specifies otherwise
- **Result limits**: Always include `| limit 50` to cap the number of returned records
- **Aggregation preferred**: Use `summarize` to aggregate data rather than fetching raw spans

---

Your goal is to display the average response time and p50 response time for each service in Dynatrace.

## Requirements

* Fetch the names of all services running in Dynatrace
* Calculate the average response time for each service, and display next to the service name
* Calculate the p50 (median) response time for each service
* Services should be displayed in a table, and in alphabetical order

## Step-by-Step Approach

### Step 1: Understand the Data Source

Service response times are captured in **spans** data. Each span represents an individual operation or request within a service. The key fields are:
- `dt.entity.service` - The service entity ID
- `duration` - The span duration in nanoseconds
- Use `entityName(dt.entity.service)` to get human-readable service names

### Step 2: Build the DQL Query

Use the following DQL pattern to calculate response time metrics:

```dql
fetch spans, from:now()-1h
| summarize
    avg_response_time = avg(duration),
    p50_response_time = percentile(duration, 50),
    request_count = count(),
    by:{service_name = entityName(dt.entity.service)}
| sort service_name asc
| limit 50
```

**Key DQL Patterns Used**:
- `fetch spans` - Retrieves distributed trace data containing response times
- `from:now()-1h` - Sets the time window (adjust as needed: 30m, 2h, 24h)
- `summarize ... by:{...}` - Groups and aggregates data by service
- `avg(duration)` - Calculates average response time
- `percentile(duration, 50)` - Calculates p50 (median) response time
- `entityName()` - Converts entity ID to human-readable name
- `sort service_name asc` - Alphabetical ordering

### Step 3: Format the Output

The duration values are returned in **nanoseconds**. For human-readable output:
- Divide by 1,000,000 to convert to milliseconds
- Divide by 1,000,000,000 to convert to seconds

Enhanced query with millisecond conversion:

```dql
fetch spans, from:now()-1h
| summarize
    avg_response_time_ns = avg(duration),
    p50_response_time_ns = percentile(duration, 50),
    request_count = count(),
    by:{service_name = entityName(dt.entity.service)}
| fieldsAdd
    avg_response_time_ms = avg_response_time_ns / 1000000,
    p50_response_time_ms = p50_response_time_ns / 1000000
| fields service_name, avg_response_time_ms, p50_response_time_ms, request_count
| sort service_name asc
| limit 50
```

### Step 4: Execute and Interpret Results

**Expected Output Columns**:
| Column | Description |
|--------|-------------|
| service_name | Human-readable service name |
| avg_response_time_ms | Average response time in milliseconds |
| p50_response_time_ms | Median response time in milliseconds |
| request_count | Total number of requests (for context) |

**Insights**:
- Compare avg vs p50: A large gap indicates high variability or outliers
- High request count with low latency indicates well-optimized services
- Services with avg >> p50 may have occasional slow requests (tail latency)
- Use request_count to prioritize optimization efforts on high-traffic services

## Additional Considerations

- **Time window**: Adjust `from:now()-1h` based on your analysis needs
- **Filtering**: Add `| filter isNotNull(dt.entity.service)` to exclude spans without service attribution
- **Additional percentiles**: Add p95 and p99 for SLA monitoring: `percentile(duration, 95)`, `percentile(duration, 99)`
