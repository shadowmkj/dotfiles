#!/usr/bin/env python3
"""
Unit tests for keybinds parser and fzf helper.
"""
import unittest
from pathlib import Path
import tempfile
import sys
import os

from importlib.machinery import SourceFileLoader

# Import keybinds executable module dynamically
keybinds_path = str(Path(__file__).parent / "keybinds")
try:
    keybinds = SourceFileLoader("keybinds", keybinds_path).load_module()
except Exception:
    keybinds = None


class TestKeybindsParser(unittest.TestCase):
    def setUp(self):
        if keybinds is None:
            self.fail("keybinds module could not be imported")

    def test_aerospace_parser(self):
        sample_toml = """
[mode.main.binding]
alt-slash = 'layout tiles horizontal vertical'
alt-shift-space = 'layout floating tiling'         # floating toggle in i3

[mode.service.binding]
esc = ['reload-config', 'mode main']
r = ['flatten-workspace-tree', 'mode main']        # reset layout
down = 'volume down'
"""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".toml", delete=False) as f:
            f.write(sample_toml)
            temp_path = f.name

        try:
            parser = keybinds.AerospaceParser(config_path=Path(temp_path))
            bindings = parser.parse()

            self.assertEqual(len(bindings), 5)

            # Check alt-slash
            b0 = bindings[0]
            self.assertEqual(b0.source, "aerospace")
            self.assertEqual(b0.mode, "main")
            self.assertEqual(b0.key, "alt-slash")
            self.assertEqual(b0.command, "layout tiles horizontal vertical")

            # Check alt-shift-space with comment
            b1 = bindings[1]
            self.assertEqual(b1.key, "alt-shift-space")
            self.assertEqual(b1.comment, "floating toggle in i3")

            # Check array command in service mode
            b2 = bindings[2]
            self.assertEqual(b2.mode, "service")
            self.assertEqual(b2.key, "esc")
            self.assertEqual(b2.command, "reload-config; mode main")

            # Check single command in service mode
            b4 = bindings[4]
            self.assertEqual(b4.mode, "service")
            self.assertEqual(b4.key, "down")
            self.assertEqual(b4.command, "volume down")
        finally:
            os.remove(temp_path)

    def test_skhd_parser(self):
        sample_skhd = """
.device internal {
  vendor:  0x0000,
  product: 0x0000,
}

.remap rcmd [device internal] : return

# Browsers
hyper - b : open -na "Google Chrome"

# System App
hyper - f : open -a "Finder"

:: bm_mode
# Enter bookmark mode
hyper - h ; bm_mode

# Open bookmarks
bm_mode < h : skhd -k "escape"; /Users/milan/scripts/bookmark.sh
"""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".skhdrc", delete=False) as f:
            f.write(sample_skhd)
            temp_path = f.name

        try:
            parser = keybinds.SkhdParser(config_path=Path(temp_path))
            bindings = parser.parse()

            self.assertEqual(len(bindings), 4)

            # Check hyper - b
            b0 = bindings[0]
            self.assertEqual(b0.source, "skhd")
            self.assertEqual(b0.mode, "default")
            self.assertEqual(b0.key, "hyper - b")
            self.assertEqual(b0.command, 'open -na "Google Chrome"')
            self.assertEqual(b0.comment, "Browsers")

            # Check bm_mode < h
            b3 = bindings[3]
            self.assertEqual(b3.source, "skhd")
            self.assertEqual(b3.mode, "bm_mode")
            self.assertEqual(b3.key, "h")
            self.assertEqual(b3.command, 'skhd -k "escape"; /Users/milan/scripts/bookmark.sh')
            self.assertEqual(b3.comment, "Open bookmarks")
        finally:
            os.remove(temp_path)

    def test_tmux_parser(self):
        sample_tmux = """
# Window management
bind | split-window -h
bind - split-window -v

bind-key -n C-M-S-k new-window
bind-key -T copy-mode-vi 'v' send -X begin-selection # start selection
bind-key x kill-pane # kill pane with x
"""
        with tempfile.NamedTemporaryFile(mode="w", suffix=".conf", delete=False) as f:
            f.write(sample_tmux)
            temp_path = f.name

        try:
            parser = keybinds.TmuxParser(config_path=Path(temp_path))
            bindings = parser.parse()

            self.assertEqual(len(bindings), 5)

            # Check bind |
            b0 = bindings[0]
            self.assertEqual(b0.source, "tmux")
            self.assertEqual(b0.mode, "prefix")
            self.assertEqual(b0.key, "|")
            self.assertEqual(b0.command, "split-window -h")
            self.assertEqual(b0.comment, "Window management")

            # Check bind-key -n C-M-S-k
            b2 = bindings[2]
            self.assertEqual(b2.mode, "root")
            self.assertEqual(b2.key, "C-M-S-k")
            self.assertEqual(b2.command, "new-window")

            # Check copy-mode-vi
            b3 = bindings[3]
            self.assertEqual(b3.mode, "copy-mode-vi")
            self.assertEqual(b3.key, "v")
            self.assertEqual(b3.command, "send -X begin-selection")
            self.assertEqual(b3.comment, "start selection")
        finally:
            os.remove(temp_path)

    def test_registry_and_filtering(self):
        registry = keybinds.KeybindRegistry()
        sample_binding1 = keybinds.Keybind(
            source="aerospace",
            mode="main",
            key="alt-h",
            command="focus left",
            comment="Focus window on left",
            file_path="/path/to/aerospace.toml",
            line_number=93,
        )
        sample_binding2 = keybinds.Keybind(
            source="skhd",
            mode="default",
            key="hyper - b",
            command="open -na Google Chrome",
            comment="Open browser",
            file_path="/path/to/skhdrc",
            line_number=17,
        )
        registry.add(sample_binding1)
        registry.add(sample_binding2)

        # Filter all
        all_binds = registry.get_all()
        self.assertEqual(len(all_binds), 2)

        # Filter aerospace only
        aero_binds = registry.get_by_source("aerospace")
        self.assertEqual(len(aero_binds), 1)
        self.assertEqual(aero_binds[0].key, "alt-h")

        # Filter skhd only
        skhd_binds = registry.get_by_source("skhd")
        self.assertEqual(len(skhd_binds), 1)
        self.assertEqual(skhd_binds[0].key, "hyper - b")

    def test_formatting_and_preview(self):
        binding = keybinds.Keybind(
            source="aerospace",
            mode="main",
            key="alt-h",
            command="focus left",
            comment="Focus window on left",
            file_path="/path/to/aerospace.toml",
            line_number=93,
        )
        line = binding.to_fzf_line()
        self.assertIn("aerospace", line)
        self.assertIn("main", line)
        self.assertIn("alt-h", line)
        self.assertIn("focus left", line)

        preview = binding.to_preview()
        self.assertIn("AeroSpace", preview)
        self.assertIn("alt-h", preview)
        self.assertIn("focus left", preview)
        self.assertIn("Focus window on left", preview)


if __name__ == "__main__":
    unittest.main()
