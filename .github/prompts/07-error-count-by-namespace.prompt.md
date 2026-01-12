---
description: 'Count errors grouped by Kubernetes namespace'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** Logs are data-intensive. To prevent context overflow, always apply these constraints:
- **Time limits**: ALWAYS use `from:now()-1h` for log queries - NEVER query logs without a time constraint
- **Result limits**: Always include `| limit 20` to cap the number of namespaces returned
- **Aggregation required**: Use `summarize` with `count()` - never fetch raw log content for this analysis

---

Your goal is to display the count of errors grouped by Kubernetes namespace.

## Step-by-Step Instructions

### Step 1: Fetch Logs with Error Filter

Start by fetching logs and filtering for error-level entries:

```dql
fetch logs, from:now()-1h
| filter loglevel == "ERROR" or loglevel == "SEVERE"
```

**Key considerations**:
- Include both "ERROR" and "SEVERE" log levels to capture all error types
- Use the `loglevel` field which is a standard field in Dynatrace logs

### Step 2: Aggregate by Kubernetes Namespace

Use `summarize` to count errors grouped by namespace:

```dql
| summarize error_count = count(), by:{k8s.namespace.name}
```

**Key considerations**:
- The `k8s.namespace.name` field contains the Kubernetes namespace
- Use `count()` to get the total number of error log entries per namespace
- Namespaces without errors will not appear in the results

### Step 3: Sort Results by Error Count

Sort descending to show namespaces with the most errors first:

```dql
| sort error_count desc
```

### Step 4: Limit Results

Apply a reasonable limit to avoid overwhelming output:

```dql
| limit 20
```

## Complete Query Example

```dql
fetch logs, from:now()-1h
| filter loglevel == "ERROR" or loglevel == "SEVERE"
| summarize error_count = count(), by:{k8s.namespace.name}
| sort error_count desc
| limit 20
```

## Expected Output

The query should return a table with:
- **k8s.namespace.name**: The Kubernetes namespace name
- **error_count**: Total number of error log entries in that namespace

Results are sorted by error count descending (most errors first).

## Insights from Results

- **Prioritize namespaces with disproportionately high error counts** for immediate investigation
- **Compare error rates across namespaces** to identify outliers that may indicate problems
- **Track error trends over time** by running this query at different intervals to detect degradation
- **Use error distribution** to guide troubleshooting efforts and allocate resources

## Optional Enhancements

### Add Time Range

To analyze a specific time window, add a `from` clause:

```dql
fetch logs, from:now()-1h
| filter loglevel == "ERROR" or loglevel == "SEVERE"
| summarize error_count = count(), by:{k8s.namespace.name}
| sort error_count desc
| limit 20
```

### Include Log Source Breakdown

For additional context on where errors originate:

```dql
fetch logs, from:now()-1h
| filter loglevel == "ERROR" or loglevel == "SEVERE"
| summarize error_count = count(), by:{k8s.namespace.name, log.source}
| sort error_count desc
| limit 20
```

### Filter for Specific Cluster

If you have multiple clusters and want to focus on one:

```dql
fetch logs, from:now()-1h
| filter loglevel == "ERROR" or loglevel == "SEVERE"
| filter k8s.cluster.name == "your-cluster-name"
| summarize error_count = count(), by:{k8s.namespace.name}
| sort error_count desc
| limit 20
```
