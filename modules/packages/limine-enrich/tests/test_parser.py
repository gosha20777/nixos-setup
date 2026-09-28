"""Unit tests for limine-enrich parser."""

import os
import sys
import unittest

# Ensure src/ is in pythonpath
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from parser import process_config


class TestParser(unittest.TestCase):
    def test_basic_enrichment(self):
        sample = """# NixOS boot entries
//Generation 42
protocol: linux
comment: NixOS 26.11...
kernel_path: boot():///limine/kernels/abc
"""

        def mock_resolver(gen):
            self.assertEqual(gen, "42")
            return "28.09 12:00", "2026-09-28", "my note"

        result = process_config(sample, mock_resolver)
        self.assertIn("//Generation 42 (28.09 12:00)", result)
        self.assertIn("comment: my note · built on 2026-09-28", result)

    def test_default_plus_generation(self):
        sample = """# NixOS boot entries
/+NixOS default profile
//+Generation 43
protocol: linux
comment: NixOS 26.11...
kernel_path: boot():///limine/kernels/xyz
"""

        def mock_resolver(gen):
            self.assertEqual(gen, "43")
            return "28.09 14:30", "2026-09-28", "default note"

        result = process_config(sample, mock_resolver)
        self.assertIn("//+Generation 43 (28.09 14:30)", result)
        self.assertIn("comment: default note · built on 2026-09-28", result)

    def test_fallback_when_profile_has_no_date(self):
        sample = """# NixOS boot entries
//Generation 10
protocol: linux
comment: old generation
kernel_path: boot():///limine/kernels/old
"""

        def mock_resolver(gen):
            return "", "", "system update"

        result = process_config(sample, mock_resolver)
        self.assertIn("//Generation 10\n", result)
        self.assertIn("comment: system update\n", result)


if __name__ == "__main__":
    unittest.main()
