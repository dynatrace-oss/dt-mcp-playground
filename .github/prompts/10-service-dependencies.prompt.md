---
description: 'Show service-to-service dependencies'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` for span-based queries
- **Result limits**: Always include `| limit 50` to cap the number of dependency pairs returned
- **Aggregation preferred**: Use `summarize` to aggregate call counts rather than listing individual calls

---

Your goal is to display the service dependencies in Dynatrace, showing which services call which other services.

## Step-by-Step Instructions

### Step 1: Query Smartscape Edges for Service Relationships

Use `smartscapeEdges` to discover service-to-service communication patterns:

```dql
smartscapeEdges "dt.entity.service"
| filter relationship == "calls"
| fields source = sourceId, target = targetId, relationship
| limit 100
```

**What this shows**:
- All "calls" relationships between services
- Source service (the caller) and target service (the callee)
- The relationship type confirming service communication

### Step 2: Enrich with Human-Readable Service Names

Add entity names to make the output more readable:

```dql
smartscapeEdges "dt.entity.service"
| filter relationship == "calls"
| fieldsAdd caller = entityName(sourceId), callee = entityName(targetId)
| fields caller, callee, sourceId, targetId
| sort caller
| limit 100
```

**What this shows**:
- Caller and callee service names for easy identification
- Entity IDs preserved for further investigation
- Sorted alphabetically by calling service

### Step 3: Aggregate Call Patterns with Span Data

For call counts and timing, query spans directly:

```dql
fetch spans, from:now()-1h
| filter isNotNull(dt.entity.service)
| fieldsAdd service = entityName(dt.entity.service)
| filter span.kind == "CLIENT" or span.kind == "PRODUCER"
| summarize
    call_count = count(),
    avg_duration_ms = avg(duration) / 1000000,
    by:{caller = service, trace.id}
| limit 50
```

### Step 4: Complete Dependency Map with Call Counts

Combine Smartscape topology with operational metrics:

```dql
smartscapeEdges "dt.entity.service"
| filter relationship == "calls"
| fieldsAdd caller = entityName(sourceId), callee = entityName(targetId)
| summarize connection_count = count(), by:{caller, callee}
| sort caller, connection_count desc
| limit 50
```

**What this shows**:
- Service-to-service dependency pairs
- Grouped by calling service
- Number of unique connections tracked

## Expected Output Format

Results should display:
- **Caller Service**: The service initiating the call
- **Callee Service**: The downstream dependency being called
- **Call Count**: Number of calls between the pair (when available)

## Key Insights

- **Fan-out patterns**: Services calling many downstream dependencies may be orchestrators or API gateways
- **Critical dependencies**: Services called by many others are critical infrastructure (databases, auth services)
- **Call chains**: Deep dependency chains increase latency and failure risk
- **Circular dependencies**: Identify potential architectural issues

## Alternative Approaches

### Using Trace Data for Recent Dependencies

```dql
fetch spans, from:now()-1h
| filter span.kind == "CLIENT"
| fieldsAdd service = entityName(dt.entity.service)
| summarize
    call_count = count(),
    services_called = countDistinct(span.name),
    by:{service}
| sort call_count desc
| limit 20
```

### Smartscape Nodes for Service Inventory

```dql
smartscapeNodes "dt.entity.service"
| fields id, entity.name
| sort entity.name
| limit 100
```

**Notes**:
- `smartscapeEdges` provides static topology relationships
- Spans provide dynamic, time-bounded operational data
- Combine both for complete dependency visibility
