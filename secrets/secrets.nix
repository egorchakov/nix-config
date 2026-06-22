let
  recipients = {
    "evgenii@t480s" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNAiuOgUCcHudRo5skVUs4L2oxOBaMGX9gLNaRPqGGt";
  };
in
{
  "nextdns-profile.age" = {
    publicKeys = builtins.attrValues recipients;
    armor = true;
  };
}
