#!/usr/bin/env python3
"""
OBS Stream Switcher - Simple Installer
This script installs the OBS Stream Switcher and its dependencies
"""

import os
import sys
import subprocess
import shutil
import urllib.request
import platform

# Colors for terminal output
class Colors:
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.CYAN}{Colors.BOLD}{'='*50}")
    print(f"{text}")
    print(f"{'='*50}{Colors.RESET}\n")

def print_success(text):
    print(f"{Colors.GREEN}✓ {text}{Colors.RESET}")

def print_error(text):
    print(f"{Colors.RED}✗ {text}{Colors.RESET}")

def print_warning(text):
    print(f"{Colors.YELLOW}⚠ {text}{Colors.RESET}")

def print_info(text):
    print(f"{Colors.CYAN}→ {text}{Colors.RESET}")

def check_python_version():
    """Check if Python 3.11 is installed"""
    print_header("Checking Python Version")
    
    version = sys.version_info
    if version.major == 3 and version.minor == 11:
        print_success(f"Python {version.major}.{version.minor}.{version.micro} is installed")
        return True
    else:
        print_error(f"Wrong Python version: {version.major}.{version.minor}.{version.micro}")
        print_warning("This script requires Python 3.11.x")
        print_info("Download from: https://www.python.org/downloads/")
        return False

def install_dependencies():
    """Install required Python packages"""
    print_header("Installing Dependencies")
    
    packages = ['requests']
    
    for package in packages:
        print_info(f"Installing {package}...")
        try:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
            print_success(f"{package} installed successfully")
        except subprocess.CalledProcessError:
            print_error(f"Failed to install {package}")
            return False
    
    return True

def get_obs_script_path():
    """Get the OBS scripts directory path"""
    if platform.system() == 'Windows':
        appdata = os.environ.get('APPDATA')
        if appdata:
            return os.path.join(appdata, 'obs-studio', 'scripts')
    elif platform.system() == 'Darwin':  # macOS
        home = os.path.expanduser('~')
        return os.path.join(home, 'Library', 'Application Support', 'obs-studio', 'scripts')
    else:  # Linux
        home = os.path.expanduser('~')
        return os.path.join(home, '.config', 'obs-studio', 'scripts')
    
    return None

def install_script():
    """Copy the script to OBS scripts directory"""
    print_header("Installing OBS Script")
    
    # Get the script path
    script_name = 'obs_stream_switcher.py'
    current_dir = os.path.dirname(os.path.abspath(__file__))
    source_script = os.path.join(current_dir, script_name)
    
    if not os.path.exists(source_script):
        print_error(f"Script file not found: {source_script}")
        return False
    
    # Get OBS scripts directory
    obs_scripts_dir = get_obs_script_path()
    
    if not obs_scripts_dir:
        print_error("Could not determine OBS scripts directory")
        return False
    
    # Create directory if it doesn't exist
    os.makedirs(obs_scripts_dir, exist_ok=True)
    print_success(f"OBS scripts directory: {obs_scripts_dir}")
    
    # Copy script
    destination = os.path.join(obs_scripts_dir, script_name)
    try:
        shutil.copy2(source_script, destination)
        print_success(f"Script installed to: {destination}")
        return True
    except Exception as e:
        print_error(f"Failed to copy script: {e}")
        return False

def print_usage_instructions():
    """Print instructions for using the script"""
    print_header("Installation Complete!")
    
    print("To use the OBS Stream Switcher:")
    print("1. Open OBS Studio")
    print("2. Go to: Tools → Scripts")
    print("3. Click the '+' button")
    print("4. Select 'obs_stream_switcher.py'")
    print("5. Configure your settings:")
    print("   - Stats Page URL: Your SLS stats endpoint")
    print("   - Publisher: Your stream publisher name")
    print("   - Scene names for different states")
    print("   - Bitrate threshold")
    print("   - Query interval")
    print("\nThe script will automatically switch scenes based on your stream status!")
    print()

def main():
    """Main installer function"""
    print_header("OBS Stream Switcher Installer")
    print("This installer will:")
    print("  1. Check Python version")
    print("  2. Install required dependencies (requests)")
    print("  3. Copy the script to OBS scripts directory")
    print()
    
    input("Press Enter to continue...")
    
    # Check Python version
    if not check_python_version():
        print_error("Installation aborted due to incorrect Python version")
        sys.exit(1)
    
    # Install dependencies
    if not install_dependencies():
        print_error("Installation aborted due to dependency installation failure")
        sys.exit(1)
    
    # Install script
    if not install_script():
        print_error("Installation aborted due to script installation failure")
        sys.exit(1)
    
    # Print usage instructions
    print_usage_instructions()
    
    input("Press Enter to exit...")

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nInstallation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        sys.exit(1)
