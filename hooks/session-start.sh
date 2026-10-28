#!/bin/sh
cat "${CLAUDE_PLUGIN_ROOT}/references/response-style.md"
printf '\nADF is active. Flow commands: /adf:flow, /adf:status. Rules index: %s/references/README.md\n' "${CLAUDE_PLUGIN_ROOT}"
exit 0
