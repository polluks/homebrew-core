class Solana < Formula
  desc "Web-Scale Blockchain for decentralized apps and marketplaces"
  homepage "https://solana.com"
  url "https://github.com/solana-labs/solana/archive/v1.10.28.tar.gz"
  sha256 "3c2c8e1a4cc8cdb4ef626c3d1cd6775588ab3a4fe9c5f25b7ed21fb29176fe5f"
  license "Apache-2.0"

  # This formula tracks the stable channel but the "latest" release on GitHub
  # varies between Mainnet and Testnet releases. This identifies versions by
  # checking the releases page and only matching Mainnet releases.
  livecheck do
    url "https://github.com/solana-labs/solana/releases?q=prerelease%3Afalse"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >][^>]*?>[^<]*?Mainnet}i)
    strategy :page_match
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "47a62afaea8faea4d72b912321ef4b19eed9749b454b13827dd354970c9e83ab"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "fbdcf6b7824d47a7e46ce90f0bf3a9bf405e4b0222a99b422a0fb0884d4cb03f"
    sha256 cellar: :any_skip_relocation, monterey:       "9b1808e8e9b36e61e31df4a7af78b21445016a7321118548c89e87728917c4af"
    sha256 cellar: :any_skip_relocation, big_sur:        "33b41757c0bc181ac73fec597b59d1f2cf9cd92c656fe7e90d8751352c8e04b2"
    sha256 cellar: :any_skip_relocation, catalina:       "3c5f94cd630593c9b51fdb0c8116b12afa8f61c44d008b8e0e80fe9d3c87f133"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9b6fdac117ba30502973b9cf27381068056de70a94fcb075e9e6377889040691"
  end

  depends_on "protobuf" => :build
  depends_on "rust" => :build

  uses_from_macos "zlib"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "openssl@1.1"
    depends_on "systemd"
  end

  def install
    # Fix for error: cannot find derive macro `Deserialize` in this scope. Already fixed on 1.11.x.
    # Can remove if backported to 1.10.x or when 1.11.x has a stable release.
    # Ref: https://github.com/solana-labs/solana/commit/12e24a90a009d7b8ab1ed5bb5bd42e36a4927deb
    inreplace "net-shaper/Cargo.toml", /^serde = ("[\d.]+")$/, "serde = { version = \\1, features = [\"derive\"] }"

    %w[
      cli
      bench-streamer
      faucet
      keygen
      log-analyzer
      net-shaper
      stake-accounts
      sys-tuner
      tokens
      watchtower
    ].each do |bin|
      system "cargo", "install", "--no-default-features", *std_cargo_args(path: bin)
    end
  end

  test do
    assert_match "Generating a new keypair",
      shell_output("#{bin}/solana-keygen new --no-bip39-passphrase --no-outfile")
    assert_match version.to_s, shell_output("#{bin}/solana-keygen --version")
  end
end
