let
  recipients = {
    "evgenii@t480s" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNAiuOgUCcHudRo5skVUs4L2oxOBaMGX9gLNaRPqGGt";

    "evgenii@mbp" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFtve6zBCQVeNrUAySDkT1cukVVgfKEZ1KOfYJQAy09a evgenii@yaak.ai";
  };
in
{
  "nextdns-profile.age" = {
    publicKeys = builtins.attrValues recipients;
    armor = true;
  };

  "rex.netrc.age" = {
    publicKeys = builtins.attrValues recipients;
    armor = true;
  };
}
