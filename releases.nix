{
  version = "0.0.0";
  timestamp = "2025-08-13T11:50:25Z";

  sources = {
    "x86_64-linux" = {
      url = "https://github.com/foundry-rs/foundry/releases/download/nightly-8b7db3abfa3075114c7f862332e42f813a6e7afd/foundry_nightly_linux_amd64.tar.gz";
      sha256 = "1g8pji208sm1hnqd19r2s0qzs25x05vypd7k6ni27m2igj6prbz4";
    };
    "aarch64-linux" = {
      url = "https://github.com/foundry-rs/foundry/releases/download/nightly-8b7db3abfa3075114c7f862332e42f813a6e7afd/foundry_nightly_linux_arm64.tar.gz";
      sha256 = "045h31dji1cv9bmjn926yidjgn5hi2p4s6vr6zjwkpd9bpim1hmf";
    }; 
    "x86_64-darwin" = {
      url = "https://github.com/foundry-rs/foundry/releases/download/nightly-8b7db3abfa3075114c7f862332e42f813a6e7afd/foundry_nightly_darwin_amd64.tar.gz";
      sha256 = "19pnnlihbvds3fc5d9hbxhdimna4m9ddz4fcqa0bkpvmhgcbkyfx";
    };
    "aarch64-darwin" = {
      url = "https://github.com/foundry-rs/foundry/releases/download/nightly-8b7db3abfa3075114c7f862332e42f813a6e7afd/foundry_nightly_darwin_arm64.tar.gz";
      sha256 = "1sypriaz82wf3xfmym542nrfya7l7g5kx2m1lr6wzhqzpsgqadf3";
    };
  };
}
