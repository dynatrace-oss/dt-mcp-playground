---
description: 'Show last 5 traces in Dynatrace'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` for span queries unless the user specifies otherwise
- **Result limits**: This query already limits to 5 traces - never exceed `| limit 10` for trace queries
- **Field selection**: Only select the fields needed for display, not all available span fields

---

Your goal is to display the last 5 traces in Dynatrace.

## Requirements

* Get the last 5 traces from Dynatrace
* For each trace, display: service name, span ID, trace ID, start time, and end time
* Display results in a table format

## Step-by-Step Instructions

### Step 1: Understand the Data Model

Traces in Dynatrace are composed of spans. Each span represents an operation within a trace and contains:
- `trace.id` - Unique identifier for the entire distributed trace
- `span.id` - Unique identifier for this specific span within the trace
- `timestamp` - When the span started
- `end_time` - When the span completed (calculated from timestamp + duration)
- `dt.entity.service` - The service entity ID that generated this span

### Step 2: Construct the DQL Query

Use the following DQL query pattern to fetch trace information:

```dql
fetch spans, from:now()-1h
| fields
    trace_id = trace.id,
    span_id = span.id,
    service_name = entityName(dt.entity.service),
    start_time = timestamp,
    end_time = timestamp + duration
| sort start_time desc
| limit 5
```

**Query breakdown**:
- `fetch spans, from:now()-1h` - Retrieves span data from the last hour
- `entityName(dt.entity.service)` - Converts service entity ID to human-readable name
- `timestamp + duration` - Calculates end time (duration is in nanoseconds)
- `sort start_time desc` - Orders by most recent first
- `limit 5` - Returns only the 5 most recent traces

### Step 3: Execute and Display Results

1. Execute the DQL query using the `execute-dql` MCP tool
2. Format the results as a table with these columns:
   - Service Name
   - Span ID
   - Trace ID
   - Start Time
   - End Time

### Expected Output Format

Present the results in a clear table format:

| Service Name | Span ID | Trace ID | Start Time | End Time |
|--------------|---------|----------|------------|----------|
| service-a    | abc123  | xyz789   | 2024-01-08T10:00:00Z | 2024-01-08T10:00:01Z |
| ...          | ...     | ...      | ...        | ...      |

### Insights

- **Trace IDs** can be used for drilling into full transaction flows across services
- **Duration** between start and end time indicates operation latency
- **Service names** show which services are handling recent transactions
- If no spans are returned, the environment may have low traffic or tracing may not be configured

### Troubleshooting

If no results are returned:
- Extend the time range: `from:now()-24h`
- Verify that distributed tracing is enabled in the environment
- Check if services are actively receiving traffic
