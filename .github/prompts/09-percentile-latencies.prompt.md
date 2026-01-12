---
description: 'Show p50, p90, and p99 latencies per service'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` for span queries
- **Result limits**: Always include `| limit 20` to cap the number of services returned
- **Aggregation required**: Use `summarize` with `percentile()` - never fetch raw spans

---

Your goal is to display percentile latencies for each service in Dynatrace.

## Step-by-Step Instructions

### Step 1: Understand the Data Source

Percentile latency data comes from **spans** (distributed traces). Each span has a `duration` field measured in **nanoseconds** and is associated with a service entity (`dt.entity.service`).

### Step 2: Write the DQL Query

Use the following query pattern to calculate percentile latencies:

```dql
fetch spans, from:now()-1h
| summarize
    p50 = percentile(duration, 50),
    p90 = percentile(duration, 90),
    p99 = percentile(duration, 99),
    request_count = count(),
    by:{service_name = entityName(dt.entity.service)}
| sort p99 desc
| limit 20
```

**Key DQL patterns used**:
- `fetch spans` - Retrieves distributed trace data
- `from:now()-1h` - Time window (adjust as needed: 30m, 2h, 24h)
- `percentile(duration, N)` - Calculates the Nth percentile of span durations
- `entityName(dt.entity.service)` - Converts service entity ID to human-readable name
- `sort p99 desc` - Sorts by tail latency (highest first)

### Step 3: Convert Durations to Milliseconds (Optional)

DQL returns duration in **nanoseconds**. To display in milliseconds, add conversion:

```dql
fetch spans, from:now()-1h
| summarize
    p50_ns = percentile(duration, 50),
    p90_ns = percentile(duration, 90),
    p99_ns = percentile(duration, 99),
    request_count = count(),
    by:{service_name = entityName(dt.entity.service)}
| fieldsAdd
    p50_ms = p50_ns / 1000000,
    p90_ms = p90_ns / 1000000,
    p99_ms = p99_ns / 1000000
| fields service_name, p50_ms, p90_ms, p99_ms, request_count
| sort p99_ms desc
| limit 20
```

### Step 4: Interpret the Results

**What the results show**:
- **p50 (median)**: Half of requests complete faster than this value
- **p90**: 90% of requests complete faster than this value
- **p99**: 99% of requests complete faster than this value (tail latency)
- **request_count**: Total number of requests per service (useful for context)

**Insights to look for**:
- **Large p99-p50 gap**: Indicates high latency variability and outlier issues
- **High p99 with low p50**: Occasional slow requests affecting user experience
- **Services with high request_count AND high latency**: Priority optimization targets
- **Multi-second p95/p99 latencies**: May indicate architectural issues, slow dependencies, or resource constraints

### Step 5: Additional Analysis Options

**Filter by span kind** (server-side only):
```dql
fetch spans, from:now()-1h
| filter span.kind == "server"
| summarize
    p50 = percentile(duration, 50) / 1000000,
    p90 = percentile(duration, 90) / 1000000,
    p99 = percentile(duration, 99) / 1000000,
    by:{service_name = entityName(dt.entity.service)}
| sort p99 desc
```

**Time-series view for trends**:
```dql
timeseries p99_latency = percentile(dt.service.request.response_time, 99),
    by:{dt.entity.service},
    from:now()-24h
| fieldsAdd service_name = entityName(dt.entity.service)
```

## Requirements Summary

* Fetch spans from Dynatrace (distributed traces)
* Calculate p50 (median), p90, and p99 percentiles of duration
* Group by service using `entityName(dt.entity.service)`
* Display results with columns: service name, p50, p90, p99 (in ms)
* Sort by p99 descending (highest tail latency first)
* Include request count for context on traffic volume
