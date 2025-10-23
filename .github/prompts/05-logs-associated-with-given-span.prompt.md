---
mode: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server']
description: 'Display log message associated with a given span'
---
Your goal is to display the log messages for the latest span in Dynatrace. 

Make sure that the returned spans must pertain to services that start with "astroshop-" if DT_ENVIRONMENT contains `wkf10640`.

Requirements:
* Find the most recent span that has one or more associated logs.
* For the above span, print the service name, span ID, trace ID, start time, end time.
* Print the last 5 log messages associated to the above span. The log message should include message, log level, and timestamp.
