# CLI Tools

A personal collection of Bash/Zsh command-line utilities built for my Linux flow. Covers backup, file synchronization, interactive navigation, command discovery, and USB management.

---

## Tools

### `cli-backup-restore-solution`

Compress a directory into a timestamped `.tar.gz` archive and restore it later. All operations are logged.

**Scripts:** `backup.sh`, `restore.sh`

```bash
# Create a backup
./backup.sh /path/to/source /path/to/destination

# Restore a backup
./restore.sh /path/to/archive.tar.gz /path/to/restore/destination
```

**Features:**
- Timestamped archive names (`name_backup_YYYY-MM-DD_HH-MM-SS.tar.gz`)
- Non-empty destination warning with confirmation prompt
- Append-only log file for audit trail

**Dependencies:** `bash`, `tar`

---

### `cli-bootable-distro`

A guided, safety-first bootable USB creator. Walks you through selecting an ISO and target device with multiple safeguards before writing anything.

**Script:** `bootable-distro.sh`

```bash
./bootable-distro.sh           # Full run (zeros first 10 MiB)
./bootable-distro.sh --nozero  # Skip zeroing step
```

**Safety checks:**
- Refuses to write to the root/system disk
- Warns if target is not a removable device
- Aborts if USB capacity is smaller than the ISO
- Requires typing the device path verbatim to confirm
- Unmounts all partitions before writing

**Dependencies:** `dd`, `lsblk`, `wipefs`, `udisksctl`, `udevadm`, `findmnt`, `blockdev`, `awk`

---

### `cli-tool-backup`

Interactive, menu-driven backup to a labeled USB device. Mount, navigate the device filesystem, and copy files — all from a terminal menu.

**Script:** `backup.sh`

```bash
./backup.sh <device-label>
# Example:
./backup.sh MY_USB
```

**Menu options:** Save here · Change directory · Previous directory · Make directory · Preview data · Exit

**Dependencies:** `bash`, `udisksctl`, `lsblk`, `awk`

---

### `cli-tool-command-pallet`

An `fzf`-powered command palette backed by a JSON catalog. Browse commands by topic, preview them with syntax highlighting, then copy, edit, or execute.

**Scripts:** `xcmd.sh`, `ranger_xcmd.sh`

```bash
# Launch the full command palette
./xcmd.sh

# Keyword search across dev-commands directory
./xcmd.sh <keyword>
# (no argument = open dev-commands in ranger)
```

The catalog lives at `~/.cmdpal/commands.json` (override with `CMDPAL_CATALOG` env var):

**Dependencies:** `fzf`, `jq`, `bat`, `ripgrep` (`rg`), `ranger`, `wl-copy` or `xclip` (clipboard)

---

### `cli-tool-lang-pallet`

An `fzf`-based TUI for navigating and searching your dev notebook. Browse directories and files interactively, or jump straight to a keyword match.

**Scripts:** `langpal.sh`, `xlang.sh`

```bash
# Interactive TUI navigator for ~/dev-notebook
./langpal.sh

# Keyword search across dev-notebook (opens result in neovim)
./xlang.sh <keyword>
# (no argument = open dev-notebook in ranger)
```

**Features:**
- Breadcrumb-style prompt showing current directory
- Live `bat` preview for files, `tree` preview for directories
- Sorted alphabetical listing with `..` navigation
- Opens selected files in `nvim`

**Dependencies:** `fzf`, `bat`, `ripgrep` (`rg`), `nvim`, `ranger`, `tree` (optional)

---

### `cli-tool-rsync`

Mirror a set of home directories to a labeled USB device using `rsync`. Handles mount and unmount automatically.

**Script:** `rsync-mirror.sh`

```bash
./rsync-mirror.sh <device-label>
# Example:
./rsync-mirror.sh MY_USB
```

Mirrors: `dev-commands`, `dev-notebook`, `Documents`, `Downloads`, `Pictures`, `Programming`, `Todo`, `.zshrc`, `.config`

**Dependencies:** `rsync`, `udisksctl`, `lsblk`, `awk`

**Test suite:** `rsync-tests/` contains a shell-based test harness for verifying sync behavior.

---

### `cli-tool-teleport`

> **Work in progress.** Quick directory teleportation from the command line.

---

## Prerequisites

- Linux (tested on Arch Linux)
- `bash` >= 4 or `zsh`
- Tool-specific dependencies listed per section above

Common dependencies you may need to install:

```bash
# Arch Linux
sudo pacman -S fzf jq bat ripgrep neovim ranger tree
```

Each tool is self-contained in its own directory — no global install required.

---

## License

Personal use. Feel free to adapt anything here for your own workflow.
