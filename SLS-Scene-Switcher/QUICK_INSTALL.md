# Quick Installation Guide - OBS Stream Switcher

## For End Users (Simple Installation)

### Method 1: Windows Installer (Easiest)
1. Download `OBS_Stream_Switcher_Setup.exe`
2. Double-click to run
3. Follow the installer prompts
4. Done! The script is installed and ready to use

### Method 2: Python Script Installer
1. Make sure Python 3.11.9 is installed
2. Double-click `simple_installer.py` (or run: `python simple_installer.py`)
3. Follow the prompts
4. Done!

### Method 3: Manual Installation
1. Install Python 3.11.9 from https://www.python.org/downloads/
   - **Important**: Check "Add Python to PATH" during installation!
2. Open Command Prompt and run:
   ```
   pip install requests
   ```
3. Copy `obs_stream_switcher.py` to:
   - Windows: `%APPDATA%\obs-studio\scripts\`
   - Create the folder if it doesn't exist
4. Done!

## Using the Script in OBS

1. Open OBS Studio
2. Go to **Tools → Scripts**
3. Click the **+** button
4. Find and select `obs_stream_switcher.py`
5. Configure your settings:
   - Check "Activate Switcher"
   - Enter your Stats URL (e.g., `http://localhost:8080/stats`)
   - Enter your Publisher name (e.g., `live/stream`)
   - Select your scenes for each state
   - Set bitrate threshold (e.g., `1000` kbps)
   - Set query interval (e.g., `5` seconds)
6. Done! The script will now automatically switch scenes

---

## For Developers (Building the Installer)

### Prerequisites
1. **Inno Setup 6** - Download from https://jrsoftware.org/isdl.php
2. All project files in one directory:
   - `obs_stream_switcher.py`
   - `installer_setup.iss`
   - `setup_dependencies.bat`
   - `check_python.ps1`
   - `simple_installer.py`
   - `build_installer.bat`
   - `README.md`

### Building the Windows Installer

#### Option 1: Using the Build Script
```bash
build_installer.bat
```

#### Option 2: Using Inno Setup Manually
1. Open `installer_setup.iss` in Inno Setup
2. Click **Build → Compile**
3. Find the output: `OBS_Stream_Switcher_Setup.exe`

### Customizing the Installer

Edit `installer_setup.iss` to customize:
- App name and version
- Publisher information
- Installation paths
- Python version requirements
- Custom actions during installation

### Testing

After building, test the installer by:
1. Running it on a clean Windows system
2. Verifying Python installation (if needed)
3. Checking that dependencies are installed
4. Confirming the script appears in OBS Scripts
5. Testing the script functionality

---

## File Structure

```
OBS_Stream_Switcher/
├── obs_stream_switcher.py          # Main script
├── installer_setup.iss              # Inno Setup configuration
├── simple_installer.py              # Python-based installer
├── setup_dependencies.bat           # Dependency installer
├── check_python.ps1                 # Python checker
├── build_installer.bat              # Build script
├── README.md                        # Full documentation
└── QUICK_INSTALL.md                 # This file
```

---

## Troubleshooting

### "Python not found" error
- Reinstall Python 3.11.9 with "Add to PATH" checked
- Or manually add Python to system PATH

### "requests module not found" error
```bash
pip install requests
```

### Script doesn't appear in OBS
- Check that the file is in the correct location
- Restart OBS
- Check OBS Script Log for errors

### OBS crashes on exit
- Update to the latest version of the script
- Old versions had memory leak issues (now fixed)

---

## Support

For issues or questions:
1. Check the full README.md
2. Review troubleshooting section
3. Check OBS script logs (Tools → Scripts → Script Log)
4. Report issues with crash logs if needed
