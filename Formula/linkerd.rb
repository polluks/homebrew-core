class Linkerd < Formula
  desc "Command-line utility to interact with linkerd"
  homepage "https://linkerd.io"
  url "https://github.com/linkerd/linkerd2.git",
      tag:      "stable-2.11.3",
      revision: "4ae6d9225b05fb1def479d76d505a383adf23326"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^stable[._-]v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "dc556b7742359afab9f094e64dd89a6a5de510645cd60d721e9e665e96500854"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "5f05f41ab684a0b1500168cc40057f4c113d5a9e13dbae289c54f3ed09997d07"
    sha256 cellar: :any_skip_relocation, monterey:       "da73f94d11eb32bb53e89ed3e0da823dc64b529cc85ffb232654fa0aa381381e"
    sha256 cellar: :any_skip_relocation, big_sur:        "02e6c46d56408c4ec11839c6288d143f89c3ed63788afcd2c5c45740ddec4ef4"
    sha256 cellar: :any_skip_relocation, catalina:       "3f6a4c49e437ec83974ca155ebad0b50b26fb05ab861b4245dd06aa2d3507e3d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "84a87773c0ff54c81130d885d2b3c6738a237ad51cf1bf9a3a1b43e0436da53b"
  end

  depends_on "go" => :build

  def install
    ENV["CI_FORCE_CLEAN"] = "1"

    system "bin/build-cli-bin"
    bin.install Dir["target/cli/*/linkerd"]
    prefix.install_metafiles

    # Install bash completion
    output = Utils.safe_popen_read(bin/"linkerd", "completion", "bash")
    (bash_completion/"linkerd").write output

    # Install zsh completion
    output = Utils.safe_popen_read(bin/"linkerd", "completion", "zsh")
    (zsh_completion/"_linkerd").write output

    # Install fish completion
    output = Utils.safe_popen_read(bin/"linkerd", "completion", "fish")
    (fish_completion/"linkerd.fish").write output
  end

  test do
    run_output = shell_output("#{bin}/linkerd 2>&1")
    assert_match "linkerd manages the Linkerd service mesh.", run_output

    version_output = shell_output("#{bin}/linkerd version --client 2>&1")
    assert_match "Client version: ", version_output
    assert_match stable.specs[:tag], version_output if build.stable?

    system bin/"linkerd", "install", "--ignore-cluster"
  end
end
