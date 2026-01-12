---
description: 'Find the slowest span operations'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` for span queries
- **Result limits**: This query limits to 10 results - never exceed `| limit 20` for slow operation queries
- **Field selection**: Only select required fields, not all span attributes

---

Your goal is to identify the slowest operations across all services in Dynatrace.

## Requirements

* Query spans from the last hour
* Calculate the duration of each span operation
* Find the top 10 slowest operations
* Display results in a table with columns: service name, operation name, duration (ms), trace ID
* Sort by duration descending (slowest first)

## Step-by-Step Instructions

### Step 1: Fetch Spans with Time Range

Start by fetching spans from the last hour using the `fetch` command:

```dql
fetch spans, from:now()-1h
```

**Why**: Spans contain distributed tracing data with timing information for each operation. The `from:now()-1h` parameter limits the query to the last hour.

### Step 2: Extract Required Fields

Use the `fields` command to select the columns needed for analysis:

```dql
| fields
    trace.id,
    span.name,
    duration,
    service_name = entityName(dt.entity.service)
```

**Key fields**:
- `trace.id` - Unique identifier for the distributed trace
- `span.name` - The operation name (e.g., "GET /api/users")
- `duration` - Span duration in **nanoseconds**
- `entityName(dt.entity.service)` - Converts service entity ID to human-readable name

### Step 3: Convert Duration to Milliseconds

DQL stores duration in nanoseconds. Convert to milliseconds for readability:

```dql
| fieldsAdd duration_ms = duration / 1000000
```

**Conversion**: 1 millisecond = 1,000,000 nanoseconds

### Step 4: Sort by Duration Descending

Sort to show the slowest operations first:

```dql
| sort duration desc
```

### Step 5: Limit to Top 10 Results

Apply the limit to get only the top 10 slowest operations:

```dql
| limit 10
```

### Step 6: Select Final Output Columns

Format the final output with the required columns:

```dql
| fields service_name, span.name, duration_ms, trace.id
```

## Complete Query

```dql
fetch spans, from:now()-1h
| fields
    trace.id,
    span.name,
    duration,
    service_name = entityName(dt.entity.service)
| fieldsAdd duration_ms = duration / 1000000
| sort duration desc
| limit 10
| fields service_name, span.name, duration_ms, trace.id
```

## What This Shows

- Individual span operations sorted by duration (slowest first)
- Service name and operation type for each slow span
- Duration in milliseconds for easy interpretation
- Trace ID for drilling into the full transaction context

## Insights

- **Long-duration spans** may indicate database queries, external API calls, or blocking operations
- **Span names** reveal which specific operations are slow (e.g., "SELECT * FROM orders" vs "POST /checkout")
- **Use the trace ID** to investigate the full distributed trace and understand the context of the slow operation
- **Differentiate between expected and problematic** slow operations (background jobs vs user-facing requests)
- **Compare span.kind** (client/server) to identify whether the caller or callee is responsible for latency
- **Consider filtering** out known long-running operations (streaming, batch jobs) to focus on unexpected slowness

## Alternative: Aggregate by Operation

If you want to find operations that are consistently slow (not just individual slow spans), use aggregation:

```dql
fetch spans, from:now()-1h
| summarize
    avg_duration_ms = avg(duration) / 1000000,
    max_duration_ms = max(duration) / 1000000,
    count = count(),
    by:{service_name = entityName(dt.entity.service), span.name}
| sort avg_duration_ms desc
| limit 10
```

This shows average and maximum duration per operation, helping identify systemic performance issues rather than one-off slow requests.
