---
description: 'Show error rate for each service'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` (or shorter) for all span queries
- **Result limits**: Always include `| limit 50` to cap the number of services returned
- **Aggregation required**: Use `summarize` with `count()` and `countIf()` - never fetch raw spans

---

Your goal is to display the error rate for each service in Dynatrace.

## Requirements

* Fetch all services running in Dynatrace
* For each service, calculate the error rate (percentage of failed requests)
* Display results in a table with columns: service name, total requests, failed requests, error rate (%)
* Sort by error rate descending (highest error rate first)
* Only show services that have at least one request

## Step-by-Step Approach

### Step 1: Understand the Data Source

Error rate analysis for services requires span data from distributed traces. Use `fetch spans` to access request-level data that includes success/failure status for each service call.

**Key fields available in spans:**
- `dt.entity.service` - The service entity ID
- `otel.status_code` - OpenTelemetry status (ERROR indicates failure)
- `span.kind` - Type of span (SERVER spans represent incoming requests)

### Step 2: Build the Base Query

Start by fetching spans for a reasonable time window (e.g., last hour) and filter to SERVER spans to count actual service requests:

```dql
fetch spans, from:now()-1h
| filter span.kind == "SERVER"
```

### Step 3: Calculate Error Metrics per Service

Use `summarize` with conditional counting to calculate both total requests and failed requests per service:

```dql
| summarize
    total_requests = count(),
    failed_requests = countIf(otel.status_code == "ERROR"),
    by:{dt.entity.service}
```

**Key DQL patterns:**
- `count()` - Total number of spans (requests)
- `countIf(condition)` - Count only spans matching the condition
- `by:{field}` - Group results by the specified field

### Step 4: Calculate Error Rate Percentage

Add a calculated field for error rate using `fieldsAdd`:

```dql
| fieldsAdd error_rate = (failed_requests * 100.0) / total_requests
```

**Note:** Multiply by 100.0 (not 100) to ensure floating-point division for accurate percentages.

### Step 5: Add Human-Readable Service Names

Convert entity IDs to readable names using `entityName()`:

```dql
| fieldsAdd service_name = entityName(dt.entity.service)
```

### Step 6: Filter, Sort, and Format Output

Apply the requirements for filtering and sorting:

```dql
| filter total_requests > 0
| sort error_rate desc
| limit 50
| fields service_name, total_requests, failed_requests, error_rate
```

### Complete Query

```dql
fetch spans, from:now()-1h
| filter span.kind == "SERVER"
| summarize
    total_requests = count(),
    failed_requests = countIf(otel.status_code == "ERROR"),
    by:{dt.entity.service}
| fieldsAdd error_rate = (failed_requests * 100.0) / total_requests
| fieldsAdd service_name = entityName(dt.entity.service)
| filter total_requests > 0
| sort error_rate desc
| limit 50
| fields service_name, total_requests, failed_requests, error_rate
```

## What This Shows

- **service_name**: Human-readable name of each service
- **total_requests**: Total number of incoming requests to the service
- **failed_requests**: Count of requests that resulted in errors
- **error_rate**: Percentage of failed requests (0-100%)

## Insights for Analysis

- **High error rates (>10%)**: Indicate critical issues requiring immediate investigation
- **Compare error rates across services**: Identify outliers that may have deployment issues
- **High request volume with low error rate**: Healthy, well-performing services
- **Low request volume with high error rate**: May indicate startup issues or intermittent problems
- **Services with 0% error rate**: Either very stable or may not be properly instrumented

## Alternative Approaches

If you need error rates based on HTTP status codes instead of OpenTelemetry status:

```dql
fetch spans, from:now()-1h
| filter span.kind == "SERVER"
| summarize
    total_requests = count(),
    failed_requests = countIf(http.response.status_code >= 500),
    by:{dt.entity.service}
| fieldsAdd error_rate = (failed_requests * 100.0) / total_requests
| fieldsAdd service_name = entityName(dt.entity.service)
| filter total_requests > 0
| sort error_rate desc
| limit 50
| fields service_name, total_requests, failed_requests, error_rate
```

This counts 5xx status codes as errors, which may give different results depending on how your services report errors.
