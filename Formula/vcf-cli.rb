class VcfCli < Formula
  desc "Vibe Coding Framework MCP server + CLI — LLM-agnostic lifecycle tooling"
  homepage "https://github.com/Kaelith-Labs/vcf-cli"
  # Alpha prereleases are published under the npm `alpha` dist-tag; this
  # formula pins the exact tarball for reproducibility.
  url "https://registry.npmjs.org/@kaelith-labs/cli/-/cli-0.2.1-alpha.0.tgz"
  sha256 "b035925c9fa133708e6f912da5a9c4a0aeb3a75a68db205f7ffefe7e25009ce5"
  license "Apache-2.0"
  # Bump `version` alongside `url` on each release. Homebrew parses it from
  # the tarball name by default; overriding here keeps the formula self-
  # documenting.
  version "0.2.1-alpha.0"

  depends_on "node"

  def install
    # Install the npm package into libexec/ so we own the directory layout,
    # then link the two bins (vcf, vcf-mcp) into bin/ as Homebrew expects.
    # `std_npm_args` is the modern replacement for the removed
    # `Language::Node.std_npm_install_args` helper — it sets --prefix,
    # disables audit/fund noise, and installs `.` (the current dir).
    system "npm", "install", *std_npm_args(prefix: libexec)

    # Homebrew's npm install runs under `--ignore-scripts` for security, so
    # packages with native addons (here: better-sqlite3's prebuild-install)
    # never download their platform binary and the MCP server crashes at
    # startup with "Could not locate the bindings file". Explicitly rebuild
    # the one dep that needs it — this re-runs the install hook and fetches
    # the matching prebuilt `.node` binary for the current node + arch.
    cd libexec/"lib/node_modules/@kaelith-labs/cli" do
      system "npm", "rebuild", "better-sqlite3"
    end

    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    # `vcf version` exits 0 and prints a version string. Cheapest possible
    # smoke test that doesn't touch the network or config.
    assert_match(/vcf-cli \d+\.\d+\.\d+/, shell_output("#{bin}/vcf version"))
  end
end
