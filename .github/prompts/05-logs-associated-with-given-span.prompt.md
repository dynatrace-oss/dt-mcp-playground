---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Display log message associated with a given span'
---
Your goal is to display the log messages for the latest span in Dynatrace.

Requirements:
* Find the latest log message. Filters:
    * `span_id` is not null
    * `service.name` contains `recommendation`
* Fetch all logs having the value of `span_id` returned above
* Print the service name, span ID, trace ID
* Also print: `timestamp`, `content`, `loglevel`
* Display results in a table
