{
    monitorcontrol.url = "github:newam/monitorcontrol/main";
    monitorcontrol.inputs.nixpkgs.follows = "unstable";
    inputs.nixpkgs.url = monitorcontrol.url;
  
    outputs = { self, nixpkgs, ... }@attrs: {
      overlays = [ monitorcontrol.overlays.default ];
      nixosConfigurations.fnord = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [ ./package-configuration.nix ];
      };
    };
}
