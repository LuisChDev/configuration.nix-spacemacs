{ config, lib, pkgs, ... }:

with lib;

{ boot.isContainer = true;
  networking = {
    hostName = mkDefault "colvid-db";
    useDHCP = false;
    firewall.allowedTCPPorts = [ 22 5432 ];
  };

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoWa4CmI4If9iDHSbQAST1jEkqHfRoJIT+j2pZG6aPgrLMvl1KOzuIr6rkVSUS12XYFMxE8lD7GH9IOjIaRHTa3eDOSVKp2if0Kkd70q8dZyOJ7PWquGxbihvH8yngtOBr9rHG/gsBwdDqMbFV3Ye4dNYohby5xfXe9/6K45j8eNuT4A3CXrT9eeObc/22It8phCLSl54EgqmreJTE9QsD8BsiEcaEIMOgEiCjyH7v/k1xVCkhIBCLNaXi65DAlVFmT2QDvJ4HpGvg/KeFKXkWNDpnz2iZP54KWASP0EStc8v2b2mP5GRlWqj7BkAaNJ3HNqg/6QhP9FVZUxROs66j chava@phoenix"];

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql;

    authentication = ''
      host  all  all  10.0.0.0/8  trust
    '';

    ensureUsers = [
      {
	name = "chava";
	ensurePermissions = {
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
	};
      }
      {
        name = "root";
	ensurePermissions = {
	  "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
	};
      }
    ];
  };

}
