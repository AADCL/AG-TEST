#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "scripts" / "tf_tree_validation.py"


class TfTreeValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        spec = importlib.util.spec_from_file_location("tf_tree_validation", MODULE_PATH)
        cls.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.module)

    def test_accepts_exact_target_chain(self):
        parents = {
            "camera_init": {"world"},
            "body": {"camera_init"},
            "base_link": {"body"},
            "livox_frame": {"base_link"},
        }
        self.assertEqual([], self.module.validate_tf_tree(parents))

    def test_rejects_duplicate_parent_missing_edge_and_odom(self):
        parents = {
            "camera_init": {"world", "odom"},
            "body": {"camera_init"},
            "livox_frame": {"base_link"},
            "odom": {"world"},
        }
        errors = "\n".join(self.module.validate_tf_tree(parents))
        self.assertIn("multiple parents", errors)
        self.assertIn("missing target edge body -> base_link", errors)
        self.assertIn("legacy odom frame", errors)

    def test_exporter_invokes_view_frames_and_timestamp_artifacts(self):
        text = (ROOT / "scripts" / "export_tf_tree.py").read_text(encoding="utf-8")
        self.assertIn('subprocess.run(["rosrun", "tf", "view_frames"]', text)
        self.assertIn('/ "artifacts" / "tf"', text)
        self.assertIn('"/tf_static"', text)
        self.assertIn('"/tf"', text)
        self.assertIn('"frames.gv"', text)
        self.assertIn('"frames.pdf"', text)


if __name__ == "__main__":
    unittest.main()
