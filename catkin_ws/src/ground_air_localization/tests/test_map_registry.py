#!/usr/bin/env python3
import sys
from pathlib import Path
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SOURCE))

from ground_air_localization.map_registry import MapRegistry, MapRegistryError  # noqa: E402


class MapRegistryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / "incoming"
        self.source.mkdir()
        (self.source / "site.pcd").write_bytes(b"pcd")
        (self.source / "site.pgm").write_bytes(b"P5\n1 1\n255\n\0")
        (self.source / "site.yaml").write_text(
            "image: site.pgm\nresolution: 0.05\norigin: [0, 0, 0]\n",
            encoding="utf-8",
        )
        self.registry = MapRegistry(self.root / "maps")

    def tearDown(self):
        self.temp.cleanup()

    def test_imports_complete_map_bundle_and_returns_canonical_paths(self):
        bundle = self.registry.install("site_01", str(self.source))
        self.assertEqual(bundle.map_id, "site_01")
        self.assertTrue(bundle.directory.is_dir())
        self.assertEqual(bundle.pcd.name, "site.pcd")
        self.assertEqual(bundle.yaml.name, "site.yaml")
        self.assertTrue(bundle.image.is_file())
        self.assertEqual(bundle.directory, self.registry.root / "site_01")

    def test_rejects_path_traversal_and_invalid_map_ids(self):
        for bad in ("../outside", "site/name", "", ".", "含空格"):
            with self.assertRaises(MapRegistryError):
                self.registry.install(bad, str(self.source))

    def test_rejects_incomplete_or_ambiguous_bundle(self):
        (self.source / "site.pcd").unlink()
        with self.assertRaises(MapRegistryError):
            self.registry.install("missing", str(self.source))

        (self.source / "a.pcd").write_bytes(b"a")
        (self.source / "b.pcd").write_bytes(b"b")
        with self.assertRaises(MapRegistryError):
            self.registry.install("ambiguous", str(self.source))

    def test_yaml_image_must_exist_inside_bundle(self):
        (self.source / "site.yaml").write_text("image: ../outside.pgm\n", encoding="utf-8")
        (self.root / "outside.pgm").write_bytes(b"x")
        with self.assertRaises(MapRegistryError):
            self.registry.install("escape", str(self.source))

    def test_existing_registered_map_can_be_selected_without_overwrite(self):
        first = self.registry.install("site_01", str(self.source))
        selected = self.registry.install("site_01", str(first.directory))
        self.assertEqual(selected.directory, first.directory)


if __name__ == "__main__":
    unittest.main()
