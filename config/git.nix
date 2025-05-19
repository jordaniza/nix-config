{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "jordaniza";
    userEmail = "j@jordaniza.com";

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      credential.helper = "${
        pkgs.git.override {withLibsecret = true;}
      }/bin/git-credential-libsecret";
    };
  };
}
