class VcfCli < Formula
  desc "Vibe Coding Framework MCP server + CLI — LLM-agnostic lifecycle tooling"
  homepage "https://github.com/Kaelith-Labs/vcf-cli"
  # Alpha prereleases are published under the npm `alpha` dist-tag; this
  # formula pins the exact tarball for reproducibility.
  url "https://registry.npmjs.org/@kaelith-labs/cli/-/cli-0.3.0-alpha.0.tgz"
  sha256 "7edfdd64d9fdc8d56d283d8569ff3185150631723e79048b414cb438cee7cb93"
  license "Apache-2.0"
  # Bump `version` alongside `url` on each release. Homebrew parses it from
  # the tarball name by default; overriding here keeps the formula self-
  # documenting.
  version "0.3.0-alpha.0"

  # Pin to node@22 (active LTS) rather than the unversioned `node` formula.
  # Homebrew's `node` tracks current (25.x as of 2026-04-20), but
  # better-sqlite3 11.5 has not published prebuilt binaries for the Node 25
  # ABI yet — npm falls back to a from-source compile whose intermediate
  # files carry modes Homebrew can't clean up later, leaving a broken keg.
  # LTS has prebuilts, no compile, clean install.
  depends_on "node@22"

  def install
    # node@22 is keg-only, so expose it on PATH for the duration of install
    # so `npm` and the shebang-resolved node match.
    ENV.prepend_path "PATH", Formula["node@22"].opt_bin

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
    # the matching prebuilt `.node` binary for the pinned node + arch.
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
