class ReorderPythonImports < Formula
  include Language::Python::Virtualenv

  desc "Rewrites source to reorder python imports"
  homepage "https://github.com/asottile/reorder_python_imports"
  url "https://files.pythonhosted.org/packages/70/e0/dd84bd8c7884f78943b8a81f8e44ee221bdfbe70abafbc23db71feda1b74/reorder_python_imports-3.8.1.tar.gz"
  sha256 "33a981a477875ac79588dbc6f80d7db85eccd2f5529ff289fe51283afd5affb5"
  license "MIT"
  head "https://github.com/asottile/reorder_python_imports.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c873b178e7a565497ddc533a197b4b8054fc80f85cd672f95be13cb4ef207b4a"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "c873b178e7a565497ddc533a197b4b8054fc80f85cd672f95be13cb4ef207b4a"
    sha256 cellar: :any_skip_relocation, monterey:       "4290d6e437cad001ddd45bd61be8bff1fa6e30e7681ce0793d6da65d9f45e8b7"
    sha256 cellar: :any_skip_relocation, big_sur:        "4290d6e437cad001ddd45bd61be8bff1fa6e30e7681ce0793d6da65d9f45e8b7"
    sha256 cellar: :any_skip_relocation, catalina:       "4290d6e437cad001ddd45bd61be8bff1fa6e30e7681ce0793d6da65d9f45e8b7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "1a889aa5c87d53cd4e3ac9cc66333ab97269ce4fe515706b1739b68cc3b1dd96"
  end

  depends_on "python@3.10"

  resource "classify-imports" do
    url "https://files.pythonhosted.org/packages/5e/b1/5c8792dee3437a13d66e0518bcd6add8ec6f54a02c89ef3f14986a05016d/classify_imports-4.1.0.tar.gz"
    sha256 "69ddc4320690c26aa8baa66bf7e0fa0eecfda49d99cf71a59dee0b57dac82616"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"test.py").write <<~EOS
      from os import path
      import sys
    EOS
    system "#{bin}/reorder-python-imports", "--exit-zero-even-if-changed", "#{testpath}/test.py"
    assert_equal("import sys\nfrom os import path\n", File.read(testpath/"test.py"))
  end
end
