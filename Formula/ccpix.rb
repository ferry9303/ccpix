class Ccpix < Formula
  desc "View images from your Claude Code session transcripts in the terminal"
  homepage "https://github.com/ferry9303/ccpix"
  url "https://github.com/ferry9303/ccpix/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "8c87bf012311b6aa1bd573b5e0d141fe98b7b5f403e9ad142a36a0762a0729f8"
  license "MIT"
  head "https://github.com/ferry9303/ccpix.git", branch: "main"

  depends_on "python@3.13"
  depends_on "chafa" => :recommended

  def install
    bin.install "ccpix"
    # Pin the interpreter to Homebrew's python (keg-only; its bin ships
    # python3.13, not python3) so it runs regardless of the user's PATH.
    inreplace bin/"ccpix", %r{\A#!/usr/bin/env python3$},
              "#!#{Formula["python@3.13"].opt_bin}/python3.13"
  end

  test do
    assert_match "usage: ccpix", shell_output("#{bin}/ccpix --help")
  end
end
