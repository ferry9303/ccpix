class Ccpix < Formula
  desc "View images from your Claude Code session transcripts in the terminal"
  homepage "https://github.com/ferry9303/ccpix"
  url "https://github.com/ferry9303/ccpix/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a7c89e3f03e90ee22aef339868e7b0dbd3396da04a554c81dd968a1eefb1a2e8"
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
