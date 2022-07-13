class Tio < Formula
  desc "Simple TTY terminal I/O application"
  homepage "https://tio.github.io"
  url "https://github.com/tio/tio/releases/download/v1.43/tio-1.43.tar.xz"
  sha256 "fe687042dc787bb28a00a5abbafd99714921704fae7d51eff30aaf5a6dc74ab7"
  license "GPL-2.0-or-later"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "3177501ffa921361367a050dbcacdf7c2beb6597d75431c7dbee66c385b7e4bc"
    sha256 cellar: :any,                 arm64_big_sur:  "be839f9a95e35a3fa829c8ff11324b9cab042e8fb164b1185f16965768d0d196"
    sha256 cellar: :any,                 monterey:       "dc694bea8a4476f62321e50a8f959943558cbfbb15cd02030d04fd2b83b144c1"
    sha256 cellar: :any,                 big_sur:        "2ab5e3cc3f4aaba70309f734bccaa62edd401e3bde3b440bd4a755674cdb86a3"
    sha256 cellar: :any,                 catalina:       "a8d60c81509e3ce259f0f4e1b48812fee45d62fb5ec93e32de435ae5547a684e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9eec7e2f1dbdb497a87eda7197446cbbab452a31633d7541f99d5d2dff0fd430"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "inih"

  def install
    mkdir "build" do
      system "meson", *std_meson_args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    # Test that tio emits the correct error output when run with an argument that is not a tty.
    # Use `script` to run tio with its stdio attached to a PTY, otherwise it will complain about that instead.
    expected = "Error: Not a tty device"
    output = if OS.mac?
      shell_output("script -q /dev/null #{bin}/tio /dev/null", 1).strip
    else
      shell_output("script -q /dev/null -e -c \"#{bin}/tio /dev/null\"", 1).strip
    end
    assert_match expected, output
  end
end
