# mcp-nixos

A Nix flake that packages [mcp-nixos](https://github.com/utensils/mcp-nixos), an MCP server that answers questions about NixOS packages and options, Home Manager, nix-darwin, and related Nix resources from published sources rather than from memory.

## Outputs

`packages.mcp-nixos`, also `packages.default`, on `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`: the MCP server, whose `bin/` holds `mcp-nixos`. Name that in an MCP client's command; the interpreter and its dependencies are already in the closure.

```sh
nix run .#mcp-nixos                                   # stdio transport, the default
MCP_NIXOS_TRANSPORT=http MCP_NIXOS_PORT=8000 mcp-nixos # HTTP, endpoint at /mcp
```

`MCP_NIXOS_HOST`, `MCP_NIXOS_PATH`, and `MCP_NIXOS_STATELESS_HTTP=1` shape the HTTP listener. On the default `127.0.0.1` bind the SDK also rejects a `Host` header outside `127.0.0.1`, `localhost` and `[::1]` with `421 Misdirected Request`; `MCP_NIXOS_HOST=0.0.0.0` validates no `Host` at all, which is what the pre-port server did on every bind.

## Behavior of the packaged build

This package is built from upstream with a standing patch that replaces its `fastmcp` dependency with the official MCP Python SDK ([PROVENANCE.md](PROVENANCE.md) carries it and says why). Three client-visible differences, all measured against the pinned fastmcp 4.0.5 build:

- An argument name that is not in the schema is ignored instead of rejected, so a misspelled `query` answers an empty query instead of returning a corrective error.
- Tools publish no `title`, and the server advertises `listChanged` capabilities instead of a `logging` capability.
- Tool names, parameter names, parameter descriptions, result text, and `structuredContent` are unchanged, byte for byte.

## Notes

- The tools query public services over HTTPS (the NixOS search API, NixHub, cache.nixos.org, nix.dev, wiki.nixos.org, FlakeHub, NuschtOS, noogle.dev), so the host needs outbound HTTPS. The system CA bundle is baked into the wrapper.
- Noogle and Nixvim data are fetched whole and cached in the running process, so the first query against those sources pulls a full dataset before answering.
- The `flake-inputs` action shells out to `nix` and needs it on `PATH`. The `store` action reads the Nix store directly without Nix, and nothing else needs it.
- The published systems exclude `x86_64-darwin`.

See [LICENSE.md](LICENSE.md) for licensing and copyright, and [NOTICE.md](NOTICE.md) for the terms of upstream and distributed artifacts.
