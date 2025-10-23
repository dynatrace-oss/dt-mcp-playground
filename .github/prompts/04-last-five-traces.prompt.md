---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Show last 5 traces in Dynatrace'
---
Your goal is to display the last 5 traces in Dynatrace from 

Requirements:

* Run query:

```
fetch spans
| fields dt.entity.service, start_time, end_time, span.id, trace.id, right.service_name
| join [
  fetch dt.entity.service
  | filter startsWith(entity.name, "astroshop-")
  | fields id, alias: dt.entity.service, entity.name, alias: service_name
], 
on: {dt.entity.service},
kind: outer
| fieldsRemove right.dt.entity.service
```

* Display results in a table:
    * Display fields: `right.service_name`, `span.id`, `trace.id`, `start_time`, `end_time`
