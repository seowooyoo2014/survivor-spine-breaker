from pathlib import Path
import shutil
root=Path(__file__).resolve().parents[1]
source=root/'web'
required=['index.html','index.js','index.wasm','index.pck']
for name in required:
 if not (source/name).exists():raise FileNotFoundError(source/name)
dest=root/'dist'
if dest.exists():shutil.rmtree(dest)
shutil.copytree(source,dest)
(dest/'.nojekyll').write_text('')
print('built Godot web export')
