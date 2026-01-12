# Dynatrace MCP Server Integration

🔄 **Loading Dynatrace Agent...**

**IMPORTANT:** Use the Dynatrace MCP server for all data queries. If the Dynatrace MCP server is not installed, please inform the user.

**DATA GUARDRAILS:** To prevent context overflow, always apply these constraints:
- **Time limits**: Use `from:now()-1h` (or shorter) for all queries unless the user specifies otherwise
- **Result limits**: Always include `| limit 100` (or less) to cap the number of returned records
- **Aggregation preferred**: Use `summarize` to aggregate data rather than fetching raw records when possible

**Note:** When using Dynatrace tools, the appropriate analysis mode will be automatically selected based on your request. Always use `verify_dql` before `execute_dql` to ensure query validity.
