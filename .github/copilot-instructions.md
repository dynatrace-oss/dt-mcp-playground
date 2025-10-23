---
applyTo: "**"
---
# Dynatrace MCP server query standards

## Guidelines for fetching services
- When fetching service names in Dynatrace, always query `dt.entity`, but always display the service names from the `entity.name` field
- If the value of DT_ENVIRONMENT contains `wkf10640`, then always apply `filter startsWith(entity.name, "astroshop-")` in `dt.entity.service`. - For any other value of DT_ENVIRONMENT, don't apply the above filter.


## Display guidelines
- Use the name field, not the ID field when listing services.
- If a null value is returned when requesting a value for trace ID, try `trace.id`, `trace_id`, and `trace id`
- If a null value is returned when requesting a value for trace ID, try `span.id`, `span_id`, and `span id`