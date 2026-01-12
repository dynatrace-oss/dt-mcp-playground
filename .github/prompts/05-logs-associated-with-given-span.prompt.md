---
description: 'Display log message associated with a given span'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** Logs are data-intensive. To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` for all log queries - NEVER query logs without a time constraint
- **Result limits**: Always include `| limit 50` when fetching log content
- **Two-step approach**: First find the span_id (limit 1), then fetch related logs (limit 50)
- **Field selection**: Only select required fields (`service.name`, `span_id`, `trace_id`, `timestamp`, `content`, `loglevel`)

---

Your goal is to display the log messages for the latest span in Dynatrace.

## Requirements

* Find the latest log message with a non-null `span_id` where `service.name` contains `recommendation`
* Fetch all logs having the same `span_id` as the one found above
* Display: service name, span ID, trace ID, timestamp, content, loglevel
* Present results in a table format

## Step-by-Step Approach

This task requires correlating logs with spans to analyze application behavior within a specific trace context. Follow these steps:

### Step 1: Find the Latest Span ID

First, query logs to find the most recent log entry that has a span_id and matches the service filter.

**Key DQL Patterns**:
- Use `fetch logs` to retrieve log data
- Filter with `isNotNull(span_id)` to ensure span correlation exists
- Use `contains()` for partial string matching on service name
- Sort by `timestamp desc` to get the most recent entry
- Limit to 1 to get only the latest

```dql
fetch logs, from:now()-1h
| filter isNotNull(span_id) AND contains(service.name, "recommendation")
| sort timestamp desc
| limit 1
| fields span_id
```

**What this shows**:
- The span_id from the most recent log entry matching your criteria
- This ID will be used to correlate with all related logs

### Step 2: Fetch All Logs for the Span

Using the span_id obtained in Step 1, query all logs that share this span context.

**Key DQL Patterns**:
- Filter logs by the specific `span_id` value
- Select relevant fields for analysis
- Sort by timestamp to see the chronological order of events

```dql
fetch logs, from:now()-1h
| filter span_id == "<span_id_from_step_1>"
| fields service.name, span_id, trace_id, timestamp, content, loglevel
| sort timestamp asc
| limit 50
```

**What this shows**:
- All log messages emitted during the span's execution
- Chronological view of application behavior within that span
- Log levels to identify errors, warnings, and informational messages
- Full content for detailed analysis

### Alternative: Single Query Approach

If your environment supports it, you can combine both steps using a lookup or subquery pattern:

```dql
fetch logs, from:now()-1h
| filter span_id == (
    fetch logs, from:now()-1h
    | filter isNotNull(span_id) AND contains(service.name, "recommendation")
    | sort timestamp desc
    | limit 1
    | fields span_id
  )[0]
| fields service.name, span_id, trace_id, timestamp, content, loglevel
| sort timestamp asc
| limit 50
```

## Expected Results

The output should be a table containing:
- **service.name**: The service that emitted the log
- **span_id**: The unique identifier for the span
- **trace_id**: The distributed trace identifier (allows correlation across services)
- **timestamp**: When the log was emitted
- **content**: The actual log message
- **loglevel**: Severity level (INFO, WARN, ERROR, etc.)

## Insights

- **Span correlation**: Logs with the same span_id were emitted during the same logical operation
- **Trace context**: The trace_id allows you to see this span in the broader distributed trace
- **Debugging**: Chronologically ordered logs within a span reveal the execution flow
- **Error analysis**: Filter by loglevel == "ERROR" within the span to focus on issues
- **Performance correlation**: Compare log timestamps with span duration to identify slow operations
