class Fb303 < Formula
  desc "Thrift functions for querying information from a service"
  homepage "https://github.com/facebook/fb303"
  url "https://github.com/facebook/fb303/archive/v2022.07.04.00.tar.gz"
  sha256 "7024be76f181559da406f8751784f8fef46b3583089d48b3bf996b4342b0f50c"
  license "Apache-2.0"
  head "https://github.com/facebook/fb303.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "0f7f78f2929c50dc4b0744a0a38cebdd6e30002a9e1a72569adbf702b91ad3d6"
    sha256 cellar: :any,                 arm64_big_sur:  "670a855fc5967b2f6c0abe8d4dfe638e1519c37eac9494ff4d327e89b8c86b0f"
    sha256 cellar: :any,                 monterey:       "7ac94656d7e090519ee4a666a928a4495e4a68351f35aa7d579e55d0313986f5"
    sha256 cellar: :any,                 big_sur:        "d157b69870cbc0be21aeaea988a289971e984fc29e5e5f31c46bf9524cdcc6e0"
    sha256 cellar: :any,                 catalina:       "e52b359df94ea91993250b56e1db9f3d2cece8d2f2efc3245a79a72eb1beed5d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0650b43c578e4cd15fa986a45616be8cb245cb0d8a375e3e0b52669324e2ef30"
  end

  depends_on "cmake" => :build
  depends_on "fbthrift"
  depends_on "fizz"
  depends_on "fmt"
  depends_on "folly"
  depends_on "gflags"
  depends_on "glog"
  depends_on "openssl@1.1"
  depends_on "wangle"

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5" # C++17

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DPYTHON_EXTENSIONS=OFF",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "fb303/thrift/gen-cpp2/BaseService.h"
      #include <iostream>
      int main() {
        auto service = facebook::fb303::cpp2::BaseServiceSvIf();
        std::cout << service.getGeneratedName() << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++17", "-I#{include}", "-I#{Formula["openssl@1.1"].opt_include}", "test.cpp",
                    "-L#{Formula["folly"].opt_lib}", "-lfolly", "-L#{Formula["glog"].opt_lib}", "-lglog",
                    "-L#{lib}", "-lfb303_thrift_cpp", "-L#{Formula["boost"].opt_lib}", "-lboost_context-mt",
                    "-ldl", "-L#{Formula["fbthrift"].opt_lib}", "-lthriftprotocol", "-o", "test"
    assert_equal "BaseService", shell_output("./test").strip
  end
end
