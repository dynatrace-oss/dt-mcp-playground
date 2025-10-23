---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'List which services have associated logs'
---
Your goal is to list which services in Dynatrace have associated logs.

Do this by finding the associated traces for each service, and determining whether or not the traces have associated logs.

Requirements:
* List the name of each service containing associated logs
* Next to each applicable service name, display the number of associated log messagess