"""Fingerprint the compiled app so returning browsers load the current release."""
from hashlib import sha256
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "build" / "web"
entry = root / "main.dart.js"
versioned_name = f"main.{sha256(entry.read_bytes()).hexdigest()[:16]}.dart.js"
# Validate both loader copies before modifying the output.
loaders = [root / "index.html", root / "flutter_bootstrap.js"]
contents = [path.read_text() for path in loaders]
for content in contents:
    if '"mainJsPath":"main.dart.js"' not in content:
        raise RuntimeError("Flutter entrypoint configuration changed; inspect the build before publishing")
entry.rename(root / versioned_name)
for path, content in zip(loaders, contents):
    path.write_text(content.replace('"mainJsPath":"main.dart.js"', f'"mainJsPath":"{versioned_name}"'))
# Existing installations can still request the old worker URL. Retire it rather
# than returning a 404 that would leave their previous worker active.
(root / "flutter_service_worker.js").write_text(
    "self.addEventListener('install', () => self.skipWaiting());\n"
    "self.addEventListener('activate', event => event.waitUntil(self.registration.unregister()));\n"
)
print(f"Prepared release: {versioned_name}")
