class Cc1541 < Formula                                                          
  desc "A tool for creating Commodore 1541 floppy disk images"
  url "https://csdb.dk/release/download.php?id=264894"
  version "3.4"
  sha256 "6a8888f77eb5199d799f2791a8504f5569b1639d31e491aa77e6e8e8e37ad47e"
  license "MIT"

  def install
    system "make"
    bin.install "cc1541"
  end

  test do
    system "make", "check"
  end
end
