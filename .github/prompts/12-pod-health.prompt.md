---
description: 'Analyze Kubernetes pod health and errors'
---

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** Logs and events are data-intensive. To prevent context overflow, always apply these constraints:
- **Time limits**: ALWAYS use `from:now()-1h` for log queries - NEVER query logs without a time constraint
- **Result limits**: Always include `| limit 20` to cap the number of pods returned
- **Aggregation required**: Use `summarize` with `count()` - only fetch sample error messages with `| limit 1` per pod
- **Field selection**: Only select required fields (`k8s.pod.name`, `k8s.namespace.name`, error counts)

---

Your goal is to analyze the health of Kubernetes pods in Dynatrace.

Requirements:
* Query logs and events related to Kubernetes pods
* Identify pods with errors or warning-level log messages
* For each unhealthy pod, show:
    * Pod name
    * Namespace
    * Error count
    * Most recent error message
* Sort by error count descending
* Display results in a table
