---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Show last 5 traces in Dynatrace'
---
Your goal is to display the last 5 traces in Dynatrace from 

Requirements:
* Get the last 5 traces Dynatrace where service name matches the criteria from `.github/copilot-instructions.md`
* For each trace listed above, print:
    * service name (fetch service names from `dt.entity.service` and return `dt.entity`)
    * span ID
    * trace ID
    * start time (fetch the `start_time` field) from `spans`
    * end time (fetch the `end_time` field from `spans`)
* Display results in a table