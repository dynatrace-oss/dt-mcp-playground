---
agent: 'agent'
model: GPT-4o
tools: ['runCommands', 'npx-dynatrace-mcp-server/*']
description: 'List services in Dynatrace for the Astroshop app'
---
Your goal is to list the astroshop services in Dynatrace, using the guidelines for fetching services.

Requirements:
* Print the total number of services
* List the services by name, in alphabetical order