class VcfCli < Formula
  desc "Vibe Coding Framework MCP server + CLI — LLM-agnostic lifecycle tooling"
  homepage "https://github.com/Kaelith-Labs/vcf-cli"
  # Alpha prereleases are published under the npm `alpha` dist-tag; this
  # formula pins the exact tarball for reproducibility.
  url "https://registry.npmjs.org/@kaelith-labs/cli/-/cli-0.2.0-alpha.0.tgz"
  sha256 "c2e5dfd94d38abb5ae7a68f54cf1e85ae977e52d67af76faff93460652405298"
  license "Apache-2.0"
  # Bump `version` alongside `url` on each release. Homebrew parses it from
  # the tarball name by default; overriding here keeps the formula self-
  # documenting.
  version "0.2.0-alpha.0"

  depends_on "node"

  def install
    # Install the npm package into libexec/ so we own the directory layout,
    # then link the two bins (vcf, vcf-mcp) into bin/ as Homebrew expects.
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    # `vcf version` exits 0 and prints a version string. Cheapest possible
    # smoke test that doesn't touch the network or config.
    assert_match(/vcf-cli \d+\.\d+\.\d+/, shell_output("#{bin}/vcf version"))
  end
end
