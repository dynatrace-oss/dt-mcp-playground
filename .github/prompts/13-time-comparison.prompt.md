---
description: 'Compare service performance between two time periods'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` and `from:now()-2h, to:now()-1h` for comparison queries
- **Result limits**: Always include `| limit 20` to cap the number of services compared
- **Aggregation required**: Use `summarize` with `avg()` - never fetch raw spans

---

Your goal is to compare service performance between two time periods to detect regressions.

## Purpose

Compare service response times between a recent time window and a previous baseline to identify performance regressions or improvements. This analysis helps detect services that have degraded and require investigation.

## Requirements

* Compare the last 1 hour against the previous 1 hour (1-2 hours ago)
* For each service, calculate:
    * Average response time in the recent period
    * Average response time in the previous period
    * Percentage change between periods
* Display results in a table with columns: service name, recent avg (ms), previous avg (ms), change (%)
* Highlight services where performance degraded by more than 20%
* Sort by percentage change descending (biggest regressions first)

## Step-by-Step Implementation

### Step 1: Query Recent Period Data

First, fetch span data from the recent period (last 1 hour) and calculate average duration per service:

```dql
fetch spans, from:now()-1h
| summarize recent_avg = avg(duration), by:{dt.entity.service}
```

### Step 2: Query Previous Period Data

Separately query the previous period (1-2 hours ago) for the baseline:

```dql
fetch spans, from:now()-2h, to:now()-1h
| summarize previous_avg = avg(duration), by:{dt.entity.service}
```

### Step 3: Combine Periods Using append and lookup

Use `append` to combine both time periods and `lookup` to join the data for comparison:

```dql
fetch spans, from:now()-1h
| summarize recent_avg_ns = avg(duration), by:{dt.entity.service}
| lookup [
    fetch spans, from:now()-2h, to:now()-1h
    | summarize previous_avg_ns = avg(duration), by:{dt.entity.service}
  ], sourceField:dt.entity.service, lookupField:dt.entity.service, prefix:"baseline."
```

### Step 4: Calculate Percentage Change

Add calculated fields for readable values and percentage change:

```dql
| fieldsAdd service_name = entityName(dt.entity.service)
| fieldsAdd recent_avg_ms = recent_avg_ns / 1000000
| fieldsAdd previous_avg_ms = `baseline.previous_avg_ns` / 1000000
| fieldsAdd change_pct = ((recent_avg_ns - `baseline.previous_avg_ns`) * 100.0) / `baseline.previous_avg_ns`
```

**Key patterns used**:
- `entityName()` converts entity ID to human-readable name
- Duration is in nanoseconds; divide by 1,000,000 for milliseconds
- Percentage change formula: ((new - old) / old) * 100

### Step 5: Filter and Format Results

Select output columns, filter for valid comparisons, and sort by regression severity:

```dql
| filter isNotNull(`baseline.previous_avg_ns`)
| fields service_name, recent_avg_ms, previous_avg_ms, change_pct
| sort change_pct desc
| limit 20
```

## Complete Query

Combine all steps into a single query:

```dql
fetch spans, from:now()-1h
| summarize recent_avg_ns = avg(duration), by:{dt.entity.service}
| lookup [
    fetch spans, from:now()-2h, to:now()-1h
    | summarize previous_avg_ns = avg(duration), by:{dt.entity.service}
  ], sourceField:dt.entity.service, lookupField:dt.entity.service, prefix:"baseline."
| filter isNotNull(`baseline.previous_avg_ns`)
| fieldsAdd service_name = entityName(dt.entity.service)
| fieldsAdd recent_avg_ms = recent_avg_ns / 1000000
| fieldsAdd previous_avg_ms = `baseline.previous_avg_ns` / 1000000
| fieldsAdd change_pct = ((recent_avg_ns - `baseline.previous_avg_ns`) * 100.0) / `baseline.previous_avg_ns`
| fields service_name, recent_avg_ms, previous_avg_ms, change_pct
| sort change_pct desc
| limit 20
```

## What This Shows

- Service-by-service comparison of response times between two time periods
- Percentage change indicating improvement (negative) or regression (positive)
- Services sorted by biggest regressions first
- Duration values in milliseconds for readability

## Insights

- **Regressions >20%**: Services with change_pct > 20 require investigation
- **Significant improvements**: Large negative percentages may indicate successful optimizations or reduced traffic
- **Stable services**: Changes near 0% indicate consistent performance
- **Missing baseline data**: Services appearing only in recent period are new; use filter to focus on comparable services
- **Use for**:
  - Deployment validation (compare before/after release)
  - SLA monitoring (detect degradation before user impact)
  - Capacity planning (identify services under increasing load)
  - Incident investigation (correlate performance changes with events)

## Highlighting Regressions

When presenting results, highlight services where `change_pct > 20` as potential regressions requiring attention. Consider adding severity levels:

- **Critical regression**: change_pct > 50%
- **Significant regression**: change_pct > 20%
- **Minor regression**: change_pct > 10%
- **Stable**: change_pct between -10% and 10%
- **Improved**: change_pct < -10%
