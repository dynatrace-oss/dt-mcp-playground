---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server/*']
description: 'List services in Dynatrace for the Astroshop app'
---
List the services in Dynatrace.

Use query:

```text
fetch dt.entity.service
| fields entity.name
| sort entity.name
```

Requirements:
* Print the total number of services
* List the services by name, in alphabetical order