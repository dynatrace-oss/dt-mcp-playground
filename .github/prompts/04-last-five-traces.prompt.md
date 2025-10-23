---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Show last 5 traces in Dynatrace'
---
Your goal is to display the last 5 traces in Dynatrace.

Requirements:
* Get the last 5 traces Dynatrace
* For each trace listed above, print service name, span ID, trace ID, start time, end time
* Use guidance from `.github/copilot-instructions`
* Display results in a table