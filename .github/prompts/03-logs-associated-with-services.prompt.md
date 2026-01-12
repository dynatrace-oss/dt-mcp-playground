---
description: 'List which services have associated logs'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** Logs are data-intensive. To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` (or shorter) for all log queries - NEVER query logs without a time constraint
- **Result limits**: Always include `| limit 50` to cap the number of returned records
- **Aggregation required**: Use `summarize` with `count()` to aggregate log counts rather than fetching raw log content
- **Never fetch raw log content in bulk**: Only retrieve individual log messages when investigating specific spans/traces

---

Your goal is to list which services in Dynatrace have associated logs.

Do this by finding the associated traces for each service, and determining whether or not the traces have associated logs.

## Requirements

* List the name of each service containing associated logs
* Next to each applicable service name, display the number of associated log messages

---

## Step-by-Step Approach

### Step 1: Understand the Data Model

To find logs associated with services, you need to understand the relationship chain:
- **Services** have **spans** (traces)
- **Spans** have a `trace.id` that links related spans together
- **Logs** can be correlated to spans via `trace_id` field

The key is to join spans (which have service information) with logs (which have the log content).

### Step 2: Fetch Spans with Service Information

First, get spans from services to obtain trace IDs and service entity information:

```dql
fetch spans, from:now()-1h
| fields trace.id, dt.entity.service
| filter isNotNull(dt.entity.service)
```

**What this provides**:
- `trace.id`: The trace identifier to correlate with logs
- `dt.entity.service`: The service entity ID

### Step 3: Fetch Logs with Trace Correlation

Logs that are correlated to traces will have a `trace_id` field:

```dql
fetch logs, from:now()-1h
| filter isNotNull(trace_id)
| fields trace_id, content
```

**What this provides**:
- `trace_id`: The trace identifier matching spans
- Logs that are actually associated with distributed traces

### Step 4: Join Spans and Logs to Find Services with Logs

Use a `lookup` command to join the two data sources and aggregate by service:

```dql
fetch spans, from:now()-1h
| fields trace.id, dt.entity.service
| filter isNotNull(dt.entity.service)
| lookup [
    fetch logs, from:now()-1h
    | filter isNotNull(trace_id)
    | summarize log_count = count(), by:{trace_id}
  ], sourceField:trace.id, lookupField:trace_id, prefix:"log."
| filter isNotNull(log.log_count)
| summarize
    total_log_count = sum(log.log_count),
    by:{service_name = entityName(dt.entity.service)}
| sort total_log_count desc
| limit 50
```

**What this query does**:
1. Fetches spans with service information
2. Looks up log counts for each trace ID
3. Filters to only spans that have associated logs
4. Aggregates log counts by service name
5. Sorts by highest log count first

### Step 5: Interpret Results

**Expected output columns**:
- `service_name`: Human-readable name of each service with logs
- `total_log_count`: Number of log messages associated with that service

**Insights**:
- Services with high log counts may indicate verbose logging or high activity
- Services with zero or no associated logs may need log correlation configuration
- Use this to understand logging coverage across your service landscape
- Compare log volumes to identify outliers requiring attention

### Alternative Approach: Direct Log-to-Service Correlation

If your environment has direct service tagging on logs, you can use a simpler approach:

```dql
fetch logs, from:now()-1h
| filter isNotNull(dt.entity.service)
| summarize log_count = count(), by:{service_name = entityName(dt.entity.service)}
| sort log_count desc
| limit 50
```

**Note**: This only works if logs have the `dt.entity.service` field populated directly.

---

## Key DQL Patterns Used

| Pattern | Purpose |
|---------|---------|
| `lookup` | Joins two data sources (spans and logs) |
| `entityName()` | Converts entity ID to human-readable name |
| `summarize ... by:{}` | Aggregates data by grouping fields |
| `filter isNotNull()` | Ensures required fields exist |
| `trace.id` / `trace_id` | Correlation key between spans and logs |
