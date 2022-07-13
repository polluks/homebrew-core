class Pcl < Formula
  desc "Library for 2D/3D image and point cloud processing"
  homepage "https://pointclouds.org/"
  url "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.12.1.tar.gz"
  sha256 "dc0ac26f094eafa7b26c3653838494cc0a012bd1bdc1f1b0dc79b16c2de0125a"
  license "BSD-3-Clause"
  revision 3
  head "https://github.com/PointCloudLibrary/pcl.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "8cc4232822ff0809a1c28c77b86be152cdf641153c7aabf9493517a5f96bb000"
    sha256 cellar: :any,                 arm64_big_sur:  "6cb3f4914ed6a1f658545c94d2517fc29b24c13aaedf0ea8284659819e7fd61a"
    sha256 cellar: :any,                 monterey:       "2dd1ee60e206db46ca8ceca41c59649c53824ec63835b540e9549af0e645c898"
    sha256 cellar: :any,                 big_sur:        "41a3aa58ef57a64194edfa85da969b86e75157ae8c6bf7d77f6214b84d85b1ca"
    sha256 cellar: :any,                 catalina:       "e2a1320bb8e99bce217145914f482eb686db68d53bd7b9dbb6c90580d4e00d8a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "856249a7b7637982e482a6502b47e59b36eb7c2d9ecac8afa403ca8e5e8c40e9"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "boost"
  depends_on "cminpack"
  depends_on "eigen"
  depends_on "flann"
  depends_on "glew"
  depends_on "libpcap"
  depends_on "libusb"
  depends_on "qhull"
  depends_on "qt@5"
  depends_on "vtk"

  on_macos do
    depends_on "libomp"
  end

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5" # qt@5 is built with GCC

  patch do
    url "https://github.com/PointCloudLibrary/pcl/commit/e964409b4accfd9070093dbc3c9cf5fb216cd877.patch?full_index=1"
    sha256 "78c77388e6c82105d028d5e42662a37c497c35982622a6f8bc875b1c411ab375"
  end

  def install
    args = std_cmake_args + %w[
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_apps=AUTO_OFF
      -DBUILD_apps_3d_rec_framework=AUTO_OFF
      -DBUILD_apps_cloud_composer=AUTO_OFF
      -DBUILD_apps_in_hand_scanner=AUTO_OFF
      -DBUILD_apps_point_cloud_editor=AUTO_OFF
      -DBUILD_examples:BOOL=OFF
      -DBUILD_global_tests:BOOL=OFF
      -DBUILD_outofcore:BOOL=AUTO_OFF
      -DBUILD_people:BOOL=AUTO_OFF
      -DBUILD_simulation:BOOL=ON
      -DWITH_CUDA:BOOL=OFF
      -DWITH_DOCS:BOOL=OFF
      -DWITH_TUTORIALS:BOOL=OFF
      -DBoost_USE_DEBUG_RUNTIME:BOOL=OFF
    ]

    args << if build.head?
      "-DBUILD_apps_modeler=AUTO_OFF"
    else
      "-DBUILD_apps_modeler:BOOL=OFF"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
      prefix.install Dir["#{bin}/*.app"]
    end
  end

  test do
    assert_match "tiff files", shell_output("#{bin}/pcl_tiff2pcd -h", 255)
    # inspired by https://pointclouds.org/documentation/tutorials/writing_pcd.html
    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      project(pcd_write)
      find_package(PCL 1.2 REQUIRED)
      include_directories(${PCL_INCLUDE_DIRS})
      link_directories(${PCL_LIBRARY_DIRS})
      add_definitions(${PCL_DEFINITIONS})
      add_executable (pcd_write pcd_write.cpp)
      target_link_libraries (pcd_write ${PCL_LIBRARIES})
    EOS
    (testpath/"pcd_write.cpp").write <<~EOS
      #include <iostream>
      #include <pcl/io/pcd_io.h>
      #include <pcl/point_types.h>

      int main (int argc, char** argv)
      {
        pcl::PointCloud<pcl::PointXYZ> cloud;

        // Fill in the cloud data
        cloud.width    = 2;
        cloud.height   = 1;
        cloud.is_dense = false;
        cloud.points.resize (cloud.width * cloud.height);
        int i = 1;
        for (auto& point: cloud)
        {
          point.x = i++;
          point.y = i++;
          point.z = i++;
        }

        pcl::io::savePCDFileASCII ("test_pcd.pcd", cloud);
        return (0);
      }
    EOS
    mkdir "build" do
      # the following line is needed to workaround a bug in test-bot
      # (Homebrew/homebrew-test-bot#544) when bumping the boost
      # revision without bumping this formula's revision as well
      ENV.prepend_path "PKG_CONFIG_PATH", Formula["eigen"].opt_share/"pkgconfig"
      ENV.delete "CPATH" # `error: no member named 'signbit' in the global namespace`
      system "cmake", "..", "-DQt5_DIR=#{Formula["qt@5"].opt_lib}/cmake/Qt5",
                            *std_cmake_args
      system "make"
      system "./pcd_write"
      assert_predicate (testpath/"build/test_pcd.pcd"), :exist?
      output = File.read("test_pcd.pcd")
      assert_match "POINTS 2", output
      assert_match "1 2 3", output
      assert_match "4 5 6", output
    end
  end
end
