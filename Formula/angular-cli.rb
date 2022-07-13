require "language/node"

class AngularCli < Formula
  desc "CLI tool for Angular"
  homepage "https://cli.angular.io/"
  url "https://registry.npmjs.org/@angular/cli/-/cli-14.0.5.tgz"
  sha256 "fa50804b1515140f5bef2c3527c33e259b5a2a5114bf658d97360b7f422c14d4"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a42fc2238070d4862f3113a3680f4fb5f8046982f9feea067687663e6a5f23c7"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "a42fc2238070d4862f3113a3680f4fb5f8046982f9feea067687663e6a5f23c7"
    sha256 cellar: :any_skip_relocation, monterey:       "b20cfb531c1caa0f8d06259865b7b1e258d64b0569ae1a38303f3ac307588db2"
    sha256 cellar: :any_skip_relocation, big_sur:        "b20cfb531c1caa0f8d06259865b7b1e258d64b0569ae1a38303f3ac307588db2"
    sha256 cellar: :any_skip_relocation, catalina:       "b20cfb531c1caa0f8d06259865b7b1e258d64b0569ae1a38303f3ac307588db2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a42fc2238070d4862f3113a3680f4fb5f8046982f9feea067687663e6a5f23c7"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"ng", "new", "angular-homebrew-test", "--skip-install"
    assert_predicate testpath/"angular-homebrew-test/package.json", :exist?, "Project was not created"
  end
end
