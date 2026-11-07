"""Replace files in a worktree that are byte-identical to the base checkout with APFS clones.

Tracked files: same blob + mode in both indexes and unmodified on both sides.
Ignored files (build dirs, node_modules): same size, then same content hash.
usage: dedupe.py <worktree> <base> [--dry-run]
"""
import ctypes, hashlib, os, subprocess, sys

wt, base = os.path.realpath(sys.argv[1]), os.path.realpath(sys.argv[2])
dry = "--dry-run" in sys.argv
DARWIN = sys.platform == "darwin"
libc = ctypes.CDLL("/usr/lib/libSystem.B.dylib", use_errno=True) if DARWIN else None
FICLONE = 0x40049409  # linux: ioctl that shares extents on btrfs/XFS/bcachefs

def git(cwd, *a):
    return subprocess.run(["git", "-C", cwd, *a], check=True, capture_output=True).stdout

def ls_files_s(cwd):
    out = {}
    for line in git(cwd, "ls-files", "-s", "-z").decode().split("\0"):
        if not line: continue
        meta, path = line.split("\t", 1)
        mode, blob, _ = meta.split()
        out[path] = (mode, blob)
    return out

def zset(cwd, *a):
    return {p for p in git(cwd, *a).decode().split("\0") if p}

def clone(src, dst):
    tmp = dst + ".cowtree-tmp"
    if DARWIN:
        if libc.clonefile(src.encode(), tmp.encode(), 0) != 0:
            e = ctypes.get_errno()
            try: os.unlink(tmp)
            except OSError: pass
            raise OSError(e, os.strerror(e), src)
    else:
        import fcntl
        with open(src, "rb") as s_, open(tmp, "wb") as d_:
            try: fcntl.ioctl(d_.fileno(), FICLONE, s_.fileno())
            except OSError:
                os.unlink(tmp); raise
    st, ss = os.lstat(dst), os.lstat(src)
    os.chmod(tmp, st.st_mode & 0o7777)
    os.utime(tmp, ns=(ss.st_atime_ns, ss.st_mtime_ns))
    os.replace(tmp, dst)

def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""): h.update(chunk)
    return h.digest()

files, blocks = 0, 0
def take(rel):
    global files, blocks
    src, dst = os.path.join(base, rel), os.path.join(wt, rel)
    try:
        s, d = os.lstat(src), os.lstat(dst)
    except OSError:
        return
    from stat import S_ISREG
    if not (S_ISREG(s.st_mode) and S_ISREG(d.st_mode)) or s.st_size != d.st_size: return
    blocks += d.st_blocks * 512; files += 1
    if not dry: clone(src, dst)

wt_idx, base_idx = ls_files_s(wt), ls_files_s(base)
dirty = zset(wt, "diff", "--name-only", "-z") | zset(base, "diff", "--name-only", "-z")
for rel, ent in wt_idx.items():
    if rel in dirty or base_idx.get(rel) != ent or ent[0] == "120000": continue
    take(rel)
tracked = files
for rel in zset(wt, "ls-files", "--others", "--ignored", "--exclude-standard", "-z"):
    src, dst = os.path.join(base, rel), os.path.join(wt, rel)
    try:
        if os.path.getsize(src) != os.path.getsize(dst) or os.path.islink(src) or os.path.islink(dst): continue
    except OSError:
        continue
    if sha(src) == sha(dst): take(rel)
if not dry: subprocess.run(["git", "-C", wt, "update-index", "-q", "--refresh"], capture_output=True)  # exits 1 when the tree has edits
print(f"{'would clone' if dry else 'cloned'} {files} files ({tracked} tracked, {files-tracked} ignored), {blocks/1048576:.1f}MB previously owned")
