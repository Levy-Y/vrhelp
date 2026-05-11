import os, yaml

files = []
for f in sorted(os.listdir("static/files")):
    ext = f.rsplit(".", 1)[-1] if "." in f else "file"
    files.append({"name": f, "path": f"files/{f}", "ext": ext})

with open("data/files.yaml", "w") as out:
    yaml.dump(files, out)