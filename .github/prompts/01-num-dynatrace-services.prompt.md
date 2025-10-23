---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'List services in Dynatrace for the Astroshop app'
---
Your goal is to list the services in Dynatrace.

Requirements:
* Print the total number of services
* List the services by name, in alphabetical order