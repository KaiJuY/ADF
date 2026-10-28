# Live hardware

Commands sent to a real machine can cause physical motion. These rules apply to every project that has a real machine in its profile.

1. **Only the owner touches hardware.** Subagents do not connect to a PLC, do not run a demo against a machine, and do not send commands.
2. **Read the profile first.** The project profile states the address, the port, the resting state, and what Allen authorized.
3. **Read the state before a command.** Read the resting state of the machine first.
4. **Prefer a command that the machine refuses.** To test a handshake, choose a command that the current state rejects. A rejected command proves the path without motion.
5. **Report the command.** Say which command you sent, and why it could not move anything, or what Allen authorized.
6. **Close every connection.** Do not pipe a demo's output into a command that ends early (for example `head`). The demo process stays alive and holds the connection.
