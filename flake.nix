{
  description = "MCP server for NixOS, Home Manager, nix-darwin, and related resources.";

  inputs = {
    flake-lib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:jgus-org/flake-lib/v1";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      flake-lib,
      nixpkgs,
    }:
    flake-lib.lib.mkPythonFlake {
      inherit nixpkgs self;
      payload.packages =
        {
          buildApplication,
          pkgs,
          python,
          version,
          ...
        }:
        rec {
          default = mcp-nixos;
          mcp-nixos = buildApplication {
            build-system = [ python.hatchling ];
            dependencies = [
              python.beautifulsoup4
              python.mcp
              python.pydantic
              python.requests
            ];
            disabledTestPaths = [ "tests/test_integration.py" ];
            doCheck = true;
            meta = {
              changelog = "https://github.com/utensils/mcp-nixos/releases/tag/v${version}";
              description = "MCP server for NixOS, Home Manager, and nix-darwin resources";
              homepage = "https://github.com/utensils/mcp-nixos";
              license = pkgs.lib.licenses.mit;
              mainProgram = "mcp-nixos";
            };
            nativeCheckInputs = [
              python.pytest-asyncio
              python.pytest-cov-stub
              python.pytestCheckHook
            ];
            patchFlags = [
              "-p1"
              "--fuzz=0"
            ];
            patches = [ ./patches/port-to-official-mcp-sdk.patch ];
            pname = "mcp-nixos";
            pyproject = true;
            pythonImportsCheck = [
              "mcp_nixos"
              "mcp_nixos.server"
            ];
          };
        };
      updateBranches.minimumTrackingVersion = "3.1.0";
      upstream = {
        owner = "utensils";
        pin = import ./pin.nix;
        repo = "mcp-nixos";
        type = "github";
      };
    };
}
