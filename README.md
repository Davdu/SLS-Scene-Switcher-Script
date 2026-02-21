# OBS Stream Switcher

Automatically switches OBS scenes based on your SLS (SRT Live Server) stream status.

## Features

- **Automatic scene switching** based on stream bitrate
- **Three scene states**: Live (normal), Low (low bitrate), Offline (no stream)
- **Configurable thresholds** and query intervals
- **No UI stuttering** - runs in background thread
- **Proper memory management** - no crashes on exit

## Requirements

- **OBS Studio** (any recent version)
- **Python 3.11.9** (specifically version 3.11.x)
- **requests** library (automatically installed)

## Installation Options

### Option 1: Windows Installer (Recommended)

**Warning:** 

- Windows may block you from executing the installer. In this case, press 'more info' and then 'run anyway'.

- If Windows Smart App Control blocks the installer, you can disable by searching "Smart App Control" in the Windows search bar and hitting enter. From here, select 'Off'. The intaller is completely harmless and simply installs python 3.11.9 with the requests module and places the script in the correct folder. You can freely enable Smart App Control after the installation finishes.

#### Step 1: Download Installer 

Download `SLS_Scene_Switcher_v*.*_Setup.exe` from the [latest release](https://github.com/Davdu/SLS-Scene-Switcher-Script/releases)

#### Step 2: Run the installer

Run the installer from your downloads folder.

#### Step 3: Follow the Prompts 

Follow the prompts (it will automatically install Python 3.11.9 and dependencies if needed)

The script will be installed to: `C:\Program Files\obs-studio\data\obs-plugins\frontend-tools\scripts\`

#### Step 4: Configure the script

Configure the script by following the [configuration guide](https://github.com/Davdu/SLS-Scene-Switcher-Script?tab=readme-ov-file#configuration).

### Option 2: Manual Installation

#### Step 1: Install Python 3.11.9

1. Download Python 3.11.9 from: https://www.python.org/downloads/
2. During installation, **check "Add Python to PATH"**
3. Verify installation:
   ```bash
   python --version
   ```
   Should show: `Python 3.11.9`

#### Step 2: Install Dependencies

Open Command Prompt and run:
```bash
pip install requests
```

#### Step 3: Install the Script

1. Copy `sls_scene_switcher.py` to your OBS scripts directory:
   - **Windows**: `%APPDATA%\obs-studio\scripts\`
   - **macOS**: `~/Library/Application Support/obs-studio/scripts/`
   - **Linux**: `~/.config/obs-studio/scripts/`

2. If the directory doesn't exist, create it manually

#### Step 4: Configure the script

Configure the script by following the [configuration guide](https://github.com/Davdu/SLS-Scene-Switcher-Script?tab=readme-ov-file#configuration).

## Configuration

1. Open OBS Studio
2. Go to: **Tools → Scripts**
3. Ensure python is loaded in the Python Settings tab. If python was installed by the installer, it should be in `C:/Program Files/Python311`, otherwise, locate your python installation folder.
4. In the Scripts tab, click the **+** button and select `sls_scene_switcher.py`
5. Configure the settings:

### Settings

| Setting | Description | Example |
|---------|-------------|---------|
| **Activate Switcher** | Enable/disable automatic switching | ✓ Checked |
| **Stats Page URL** | Your SLS stats endpoint URL | `http://localhost:8080/stats` |
| **Publisher** | Your stream publisher name | `live/stream` |
| **Live Scene** | Scene to show when stream is good | `Live Camera` |
| **Low Scene** | Scene to show when bitrate is low | `Technical Difficulties` |
| **Offline Scene** | Scene to show when stream is offline | `Starting Soon` |
| **LOW Bitrate Threshold** | Bitrate threshold for low quality (kbps) | `1000` |
| **Query Interval** | How often to check stream status (seconds) | `5` |

## How It Works

The script periodically queries your SLS stats endpoint and checks the publisher's bitrate:

1. **Bitrate >= Threshold** → Switches to "Live Scene"
2. **Bitrate < Threshold** → Switches to "Low Scene"
3. **Publisher not found** → Switches to "Offline Scene"

## Troubleshooting

### Script doesn't appear in OBS

- Make sure Python 3.11.9 is installed and referenced in OBS Python Settings
- Check that the script is in the correct directory
- Restart OBS Studio
- Check OBS Script Log (in Scripts window) for errors

### "Module 'requests' not found" error

Run in Command Prompt:
```bash
pip install requests
```

### Python version mismatch

OBS requires Python 3.11.x specifically. Check your version:
```bash
python --version
```

If you have multiple Python versions, you may need to:
1. Uninstall other Python versions
2. Reinstall Python 3.11.9
3. Make sure it's added to PATH
OR specify which python version you are using by inputting the full path to the .exe

## Technical Details

### Memory Management

The script properly releases all OBS source references using `obs_source_release()` to prevent memory leaks and crashes during shutdown.

### Threading

Uses daemon threads for HTTP requests to prevent UI stuttering while maintaining responsiveness.

### Error Handling

Gracefully handles:
- Network errors
- Invalid JSON responses
- Missing publishers
- Shutdown race conditions

## Version History

- **1.0** - Initial release with proper memory management and crash-free shutdown

## License

GPL-3.0

## Support

For issues or questions, please:
- Check the troubleshooting section
- Review OBS script logs
- Open an issue on GitHub

## Credits

Created by Mads Andersen
