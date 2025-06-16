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
      user.signingKey = "6C6C3F5262AB6455";
      commit.gpgsign = true;
    };
  };
}
