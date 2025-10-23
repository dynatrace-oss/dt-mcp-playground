---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Print average response time per service'
---
Your goal is to display the average response time and p50 response time for each service in Dynatrace.

Requirements:
* Fetch the names of all services running in Dynatrace
* Calculate the average response time for each service, and display next to the service name
* Services should be displayed in a table, and in alphabetical order