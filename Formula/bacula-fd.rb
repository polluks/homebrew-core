class BaculaFd < Formula
  desc "Network backup solution"
  homepage "https://www.bacula.org/"
  url "https://downloads.sourceforge.net/project/bacula/bacula/13.0.0/bacula-13.0.0.tar.gz"
  sha256 "4119d48bbfe1518b3224a88e7365c2fa5f7d1679c815e7d15f26631883a8a0c6"

  bottle do
    sha256                               arm64_monterey: "5ce02dd71c35475c7ce92c54c45e8617b2e5935418317619fda4f5713daf82a3"
    sha256                               arm64_big_sur:  "ee765d178fc42c263064233cc263d1861c0736ac7a937c7581f8cfa2efb5f9d7"
    sha256                               monterey:       "16649b7fe5c0b0986425b878ae6354d2b22dcf90c45f248548f99e32370643c5"
    sha256                               big_sur:        "24ebca4a60a923795d78e923444b0d34c64234a59fb8815140979d1a7a0eeae3"
    sha256                               catalina:       "3269766474c655143cfede969df75a3d0075f9ace9a2a143351fb15ed1d467fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "70b6cea2fd1c8fc6504340e4c82027264e428583e6ade75914045ef23ae6cf60"
  end

  depends_on "openssl@1.1"
  depends_on "readline"

  uses_from_macos "zlib"

  conflicts_with "bareos-client",
    because: "both install a `bconsole` executable"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff"
    sha256 "83af02f2aa2b746bb7225872cab29a253264be49db0ecebb12f841562d9a2923"
  end

  def install
    # CoreFoundation is also used alongside IOKit
    inreplace "configure", '"-framework IOKit"',
                           '"-framework IOKit -framework CoreFoundation"'

    # * sets --disable-conio in order to force the use of readline
    #   (conio support not tested)
    # * working directory in /var/lib/bacula, reasonable place that
    #   matches Debian's location.
    system "./configure", "--prefix=#{prefix}",
                          "--sbindir=#{bin}",
                          "--with-working-dir=#{var}/lib/bacula",
                          "--with-pid-dir=#{var}/run",
                          "--with-logdir=#{var}/log/bacula",
                          "--enable-client-only",
                          "--disable-conio",
                          "--with-readline=#{Formula["readline"].opt_prefix}"

    system "make"
    system "make", "install"

    # Avoid references to the Homebrew shims directory
    inreplace prefix/"etc/bacula_config", "#{Superenv.shims_path}/", ""

    (var/"lib/bacula").mkpath
  end

  def post_install
    (var/"run").mkpath
  end

  plist_options startup: true
  service do
    run [opt_bin/"bacula-fd", "-f"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/bacula-fd -? 2>&1", 1)
  end
end
