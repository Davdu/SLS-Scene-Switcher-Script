# OBS Stream Switcher - Installation Package

## What's Included

This package contains everything you need to install and distribute the OBS Stream Switcher script.

### Files Included:

1. **obs_stream_switcher.py** - The main script (with proper memory management - crash-free!)
2. **simple_installer.py** - Python-based installer (cross-platform)
3. **installer_setup.iss** - Inno Setup configuration for Windows installer
4. **build_installer.bat** - Script to build the Windows installer
5. **setup_dependencies.bat** - Manual dependency installer
6. **check_python.ps1** - PowerShell script to verify Python setup
7. **README.md** - Complete documentation
8. **QUICK_INSTALL.md** - Quick installation guide

## Quick Start

### For End Users:

**Option 1: Windows Installer (Build it first - see below)**
- Run `OBS_Stream_Switcher_Setup.exe`
- Follow prompts
- Done!

**Option 2: Python Installer**
- Run: `python simple_installer.py`
- Follow prompts
- Done!

**Option 3: Manual**
1. Install Python 3.11.9 (with "Add to PATH" checked)
2. Run: `pip install requests`
3. Copy `obs_stream_switcher.py` to `%APPDATA%\obs-studio\scripts\`
4. Done!

### For Developers (Building the Windows Installer):

1. **Install Inno Setup 6**
   - Download: https://jrsoftware.org/isdl.php
   - Install to default location

2. **Build the Installer**
   ```
   build_installer.bat
   ```
   Or open `installer_setup.iss` in Inno Setup and click Compile

3. **Distribute**
   - The installer will be: `OBS_Stream_Switcher_Setup.exe`
   - Share this with users for one-click installation

## Installation Methods Comparison

| Method | Ease | Auto-Install Python | Auto-Install Deps | Best For |
|--------|------|---------------------|-------------------|----------|
| Windows Installer (.exe) | ⭐⭐⭐⭐⭐ | ✓ | ✓ | End users |
| Python Installer | ⭐⭐⭐⭐ | ✗ | ✓ | Users with Python |
| Manual | ⭐⭐ | ✗ | ✗ | Advanced users |

## Script Configuration (in OBS)

Once installed, configure in OBS:
1. Tools → Scripts → Add `obs_stream_switcher.py`
2. Settings:
   - **Activate Switcher**: ✓ (checked)
   - **Stats URL**: Your SLS endpoint (e.g., `http://localhost:8080/stats`)
   - **Publisher**: Your stream name (e.g., `live/stream`)
   - **Live Scene**: Scene for good stream
   - **Low Scene**: Scene for low bitrate
   - **Offline Scene**: Scene for offline
   - **Bitrate Threshold**: Minimum bitrate in kbps (e.g., `1000`)
   - **Query Interval**: Check frequency in seconds (e.g., `5`)

## What's Fixed in This Version

✅ **No more crashes on OBS exit!**
- Properly releases all OBS source references
- Uses `obs_source_release()` for memory management
- Graceful shutdown handling

✅ **No UI stuttering**
- Background threading for HTTP requests
- Non-blocking scene switches

✅ **Robust error handling**
- Network errors handled gracefully
- Invalid JSON responses handled
- Missing publishers handled

## Distribution Options

### Option 1: Distribute the Windows Installer
1. Build `OBS_Stream_Switcher_Setup.exe` using `build_installer.bat`
2. Upload to your website/GitHub releases
3. Users download and run - that's it!

### Option 2: Distribute the Python Package
1. Zip all files together
2. Users extract and run `simple_installer.py`
3. Requires Python 3.11.9 pre-installed

### Option 3: Manual Distribution
1. Share `obs_stream_switcher.py` only
2. Provide instructions from README.md
3. Users handle Python/dependencies themselves

## Requirements

- **OBS Studio** (any recent version)
- **Python 3.11.9** (specifically 3.11.x)
- **requests library** (installed automatically by installers)

## License

[Add your license here]

## Credits

Script created to solve the OBS Python source reference memory leak issue.

Special thanks to the debugging process that identified the root cause:
`obs_frontend_get_current_scene()` and `obs_frontend_get_scenes()` return 
sources with incremented reference counts that must be explicitly released
with `obs_source_release()`.

## Support

For issues:
1. Check QUICK_INSTALL.md troubleshooting
2. Review OBS Script Log
3. Verify Python 3.11.9 and requests are installed
4. Report issues with logs if needed

---

**Congratulations on fixing the crash issue! 🎉**

The key was properly releasing OBS source references. This is now a 
production-ready, crash-free script.
