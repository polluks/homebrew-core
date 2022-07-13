require "language/node"

class BitwardenCli < Formula
  desc "Secure and free password manager for all of your devices"
  homepage "https://bitwarden.com/"
  url "https://registry.npmjs.org/@bitwarden/cli/-/cli-2022.6.2.tgz"
  sha256 "9d6f7e3289c1798438079e4f43d479124ff8d345c0675313304af5707c9f7e2a"
  license "GPL-3.0-only"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "10d6175a3bbb788d9125bc4e4610b435441c64adda8a997cd9b8787bd3b2db47"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "10d6175a3bbb788d9125bc4e4610b435441c64adda8a997cd9b8787bd3b2db47"
    sha256 cellar: :any_skip_relocation, monterey:       "6ef1b518cd048f8121b7191ac7891f791711af4f397936768493723284e8f5d2"
    sha256 cellar: :any_skip_relocation, big_sur:        "6ef1b518cd048f8121b7191ac7891f791711af4f397936768493723284e8f5d2"
    sha256 cellar: :any_skip_relocation, catalina:       "6ef1b518cd048f8121b7191ac7891f791711af4f397936768493723284e8f5d2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "10d6175a3bbb788d9125bc4e4610b435441c64adda8a997cd9b8787bd3b2db47"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    assert_equal 10, shell_output("#{bin}/bw generate --length 10").chomp.length

    output = pipe_output("#{bin}/bw encode", "Testing", 0)
    assert_equal "VGVzdGluZw==", output.chomp
  end
end
