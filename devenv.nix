{pkgs, ...}: let
  erlang = pkgs.beam.packages.erlangR26;
  elixir = erlang.elixir_1_15;
  node = pkgs.nodejs_20;
  elixir-ls = erlang.elixir-ls.override {elixir = elixir;};
in {
  # setup '.env' with ENVs from README
  dotenv.enable = true;

  env.LANG = "en_US.UTF-8";
  env.ERL_AFLAGS = "-kernel shell_history enabled";

  enterShell = ''
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export PATH=$PATH:$(pwd)/_build/pip_packages/bin
  '';

  packages = with pkgs; [
    nodejs_20
    inotify-tools

    # LSP
    nodePackages_latest.typescript-language-server
    nodePackages_latest.eslint

    # formatting
    alejandra
    nodePackages_latest.prettier
  ];

  languages.elixir = {
    enable = true;
    package = elixir;
  };

  languages.javascript = {
    enable = true;
    package = node;
  };

  services.postgres = {
    enable = true;
    initialScript = ''
      CREATE USER postgres WITH ENCRYPTED PASSWORD 'postgres' CREATEDB CREATEROLE;
    '';
  };
}
