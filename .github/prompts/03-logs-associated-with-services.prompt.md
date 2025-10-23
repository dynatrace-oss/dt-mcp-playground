---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'List which services have associated logs'
---
Your goal is to list which services in Dynatrace have associated logs.

Do this by finding the associated spans for each service, and determining whether or not the spans have associated logs.

Requirements:
* Get the name of each service containing associated logs using the guidelines for fetching services
* For the spans returned above, join spans and logs based on `dt.entity.service`
* Next to each applicable service name, display the number of associated log messagess