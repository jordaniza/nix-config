{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user.name = "jordaniza";
      user.email = "j@jordaniza.com";
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
