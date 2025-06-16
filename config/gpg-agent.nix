{
  services.gpg-agent = {
    enable = true;
    # 1 year
    maxCacheTtl = 31536000;
    defaultCacheTtl = 31536000;
    enableZshIntegration = true;
  };
}
