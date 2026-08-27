"""Safe on-disk registry for paired point-cloud and navigation maps."""

from dataclasses import dataclass
import os
from pathlib import Path
import re
import shutil
import tempfile
from urllib.parse import unquote, urlparse


class MapRegistryError(RuntimeError):
    pass


@dataclass(frozen=True)
class MapBundle:
    map_id: str
    directory: Path
    pcd: Path
    yaml: Path
    image: Path


class MapRegistry:
    MAP_ID_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$")

    def __init__(self, root):
        self.root = Path(root).expanduser().resolve()
        self.root.mkdir(parents=True, exist_ok=True)

    @staticmethod
    def _inside(path, parent):
        try:
            path.relative_to(parent)
            return True
        except ValueError:
            return False

    @staticmethod
    def _source_path(source_uri):
        source_text = str(source_uri)
        parsed = urlparse(source_text)
        is_windows_drive = len(parsed.scheme) == 1 and len(source_text) > 1 and source_text[1] == ":"
        if is_windows_drive:
            parsed = urlparse("")
        if parsed.scheme not in ("", "file"):
            raise MapRegistryError("source_uri must be a local path or file:// URI")
        if parsed.scheme == "file" and parsed.netloc not in ("", "localhost"):
            raise MapRegistryError("remote file URI is not allowed")
        raw = unquote(parsed.path) if parsed.scheme == "file" else source_text
        path = Path(raw).expanduser().resolve()
        if not path.exists():
            raise MapRegistryError("map source does not exist: {}".format(path))
        return path

    @staticmethod
    def _yaml_image(yaml_path, directory):
        image_value = None
        with yaml_path.open("r", encoding="utf-8") as stream:
            for line in stream:
                match = re.match(r"^\s*image\s*:\s*(.+?)\s*$", line)
                if match:
                    image_value = match.group(1).strip().strip("\"'")
                    break
        if not image_value:
            raise MapRegistryError("map YAML has no image field")
        image = (directory / image_value).resolve()
        if not MapRegistry._inside(image, directory) or not image.is_file():
            raise MapRegistryError("map image is missing or outside the bundle")
        return image

    @classmethod
    def _inspect(cls, map_id, directory, selected_pcd=None):
        directory = directory.resolve()
        pcd_files = sorted(directory.glob("*.pcd"))
        yaml_files = sorted(directory.glob("*.yaml"))
        if selected_pcd is not None:
            pcd_files = [selected_pcd.resolve()]
        if len(pcd_files) != 1:
            raise MapRegistryError("map bundle must contain exactly one .pcd file")
        if len(yaml_files) != 1:
            raise MapRegistryError("map bundle must contain exactly one .yaml file")
        image = cls._yaml_image(yaml_files[0], directory)
        return MapBundle(map_id, directory, pcd_files[0], yaml_files[0], image)

    def install(self, map_id, source_uri):
        if not self.MAP_ID_PATTERN.fullmatch(str(map_id)):
            raise MapRegistryError("invalid map_id")

        source = self._source_path(source_uri)
        selected_pcd = source if source.is_file() and source.suffix.lower() == ".pcd" else None
        source_dir = source.parent if source.is_file() else source
        self._inspect(map_id, source_dir, selected_pcd)

        destination = (self.root / map_id).resolve()
        if not self._inside(destination, self.root):
            raise MapRegistryError("map destination escapes registry root")
        if destination.exists():
            if source_dir == destination:
                return self._inspect(map_id, destination, selected_pcd)
            raise MapRegistryError("map_id already exists; refusing to overwrite")

        staging_root = Path(tempfile.mkdtemp(prefix=".staging-", dir=str(self.root)))
        staging_bundle = staging_root / map_id
        try:
            shutil.copytree(str(source_dir), str(staging_bundle))
            os.replace(str(staging_bundle), str(destination))
        finally:
            shutil.rmtree(str(staging_root), ignore_errors=True)
        return self._inspect(map_id, destination)
