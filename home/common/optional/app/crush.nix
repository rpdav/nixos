{
  pkgs,
  inputs,
  ...
}: let
  crushConfig = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";
    lsp = {
      nix = {
        command = "nil";
      };
    };
    providers = {
      ollama = {
        base_url = "http://10.10.1.17:11434/v1/";
        name = "Ollama";
        type = "openai";
        models = [
          {
            id = "llama3.2:3b";
            name = "Llama 3.2:3b";
          }
          {
            id = "wizardlm2:7b";
            name = "Wizard LM2:7b";
          }
          {
            id = "deepseek-coder:6.7b";
            name = "DeepSeek Coder:6.7b";
          }
          {
            id = "deepseek-r1:8b";
            name = "DeepSeek-r1:8b";
          }
          {
            context_window = 256000;
            default_max_tokens = 20000;
            id = "qwen3:8b";
            name = "Qwen 3 8B";
          }
        ];
      };
    };
  };
in {
  home.packages = [
    inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.crush
  ];

  home.file."crush.json" = {
    target = ".config/crush/crush.json";
    text = crushConfig;
  };
}
