
#!/usr/bin/env bash
WORKING_DIR=$(realpath "$0")
WORKING_DIR=$(dirname $WORKING_DIR)

DESKTOP_ENTRY_NAME="Zona_test"

LOG_FILE="$WORKING_DIR/zona_installer-$(date +%H-%M-%S).log"
SKIP_VALIDATION=false

conty="conty_lite.sh"
conty_url="https://github.com/Kron4ek/Conty/releases/download/1.29.3/conty_lite.sh"

INSTALL_DIR="$HOME/.zona_conty"
TEMP_DIR="$INSTALL_DIR/tmp"
MD5_DIR="$INSTALL_DIR/md5"
CONTY="$INSTALL_DIR/$conty"
CONTY_HOME="$INSTALL_DIR/home"
DRIVE_C="$INSTALL_DIR/home/Games/umu/umu-default/drive_c"
LINK_DIR="$HOME/Games/zona"
LAUNCH_SCRIPT_PATH="$LINK_DIR/launch.sh"
# this directory is treated as $HOME within conty:
CONTY_VIRTUAL_PREFIX="$HOME/Games/umu/umu-default"

anomaly="Anomaly-1.5.3-Full.2.7z"
anomaly_url="https://www.moddb.com/$(wget -q -O- --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://www.moddb.com/downloads/start/277404 | grep -Po '(?<=href="/)[^"]*' | head -1)"

demonized="STALKER-Anomaly-modded-exes_2026.8.17.zip"
demonized_url="https://github.com/themrdemonized/xray-monolith/releases/download/2026.8.17/STALKER-Anomaly-modded-exes_2026.8.17.zip"
mt_test="STALKER-Anomaly-modded-exes-MT-TEST_2026.8.17.zip"
mt_test_url="https://github.com/themrdemonized/xray-monolith/releases/download/2026.8.17/STALKER-Anomaly-modded-exes-MT-TEST_2026.8.17.zip"

mo2="Mod.Organizer-2.5.2.7z"
mo2_url="https://github.com/ModOrganizer2/modorganizer/releases/download/v2.5.2/Mod.Organizer-2.5.2.7z"

conty="conty_lite.sh"
conty_url="https://github.com/Kron4ek/Conty/releases/download/1.29.3/conty_lite.sh"

profiles="zona_profiles.7z"
zona_profiles_url="https://github.com/gtair/filehost-1/releases/download/v1.38/zona_profiles.7z"

clean="clean_hud.7z"
clean_hud_url="https://github.com/gtair/filehost-1/releases/download/v1.38/clean_hud.7z"
bhs="bhs_hud.7z"
bhs_hud_url="https://github.com/gtair/filehost-1/releases/download/v1.38/bhs_hud.7z"

zona=( "zona_multipart.7z.001" "zona_multipart.7z.002" "zona_multipart.7z.003" "zona_multipart.7z.004" "zona_multipart.7z.005" "zona_multipart.7z.006" "zona_multipart.7z.007" )
zona_multipart=("https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.001" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.002" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.003" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.004" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.005" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.006" "https://github.com/gtair/filehost-1/releases/download/v1.38/zona_multipart.7z.007")

md5sums_url="https://github.com/johnmnorman/filehost-1/releases/download/2/md5.zip"
md5sum_validation="7bda7295ed792e977de77e5d1a9e062d"

#launch script and desktop entry now generated ca :250 due to variable install paths

### FUNCTION DECLARATIONS

function section_change() {
  log_and_echo ""
  log_and_echo "##########################################"
  log_and_echo "### $1"
  log_and_echo "##########################################"
  log_and_echo ""
}

function 1_or_2() {
  while true; do
    read -r -p "1 or 2 >> " hud
    case $hud in
      [1]* ) return "1";;
      [2]* ) return "2";;
      * ) log_and_echo "Please answer 1 or 2";;
    esac
  done
}

function y_or_n() {
  while true; do
    read -r -p "Is this ok? (y/n) >> " ok 
    case $ok in
      [Yy]* ) return "1";;
      [Nn]* ) return "2";;
      * ) log_and_echo "Please answer Y or N";;
    esac
  done
}

function wait_for_keypress() {
  log_and_echo
  read -r -p "Press Enter to continue."
  log_and_echo
}

function mkdir_if_absent() {
  if [ -f $1 ]; then
    log_and_echo "$1 exists, continuing."
  else
    log_and_echo "Creating new directory structure: $1"
    mkdir -p $1
  fi
}

function download() {
  #if [ -f $TEMP_DIR/$1 ]; then
  #  log_and_echo "$1: File failed checksum - removing."
  #  rm $TEMP_DIR/$1
  #fi
  log_and_echo "Downloading $1..."
  wget --continue --show-progress --output-document="$TEMP_DIR/$1" --append-output="$LOG_FILE" --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$2"
  #checkmd5 $1 && log_and_echo "$1 OK, continuing." || download $1 $2
}

function download_checksums() {
  mkdir_if_absent "$INSTALL_DIR/md5"
  log_and_echo "Downloading checksums."
  rm "$INSTALL_DIR/md5/*"


  download "md5.zip" $md5sums_url

  md5_md5=$(md5sum "$TEMP_DIR/md5.zip" | cut -d " " -f1)
  log_and_echo $md5_md5
  log_and_echo $md5sum_validation
  log_and_echo "Validating checksums..."
  if [ "$md5_md5" == "$md5sum_validation" ]; then
    log_and_echo "Checksums OK, continuing."
    return 0
  else
    log_and_echo "Could not obtain valid checksums."
    exit 1
  fi
}


function log_and_echo() {
  echo "$1"
  echo "$(date +%H:%M:%S): $1" >> $LOG_FILE
}

function checkmd5() {
  checksum="$MD5_DIR/$1.md5"
  download="$TEMP_DIR/$1"
  if [ -f $download ]; then
    md5_to_test=$(cat $checksum | cut -d " " -f1)
    log_and_echo "Generating checksum for $download..."
    md5_from_file=$(md5sum $download | cut -d " " -f1)
    md5_results="Input: $md5_to_test\nFile:  $md5_from_file"
    if [[ $md5_to_test == $md5_from_file ]]
      then
        log_and_echo "checkmd5: $1 passed checksum."
        return 0
      else
        log_and_echo "checkmd5: $1 failed checksum!"
        exit 1
    fi
  else
    log_and_echo "checkmd5: $1 not found!"
    exit 1
  fi
}

function install_winetricks() {
  HOME_DIR=$CONTY_HOME WINEPREFIX=$CONTY_VIRTUAL_PREFIX $CONTY winetricks cmd d3dcompiler_47 d3dx10 d3dx11_43 d3dx9 dx8vb quartz vcrun2022 dxvk | tee -a $LOG_FILE
}

function clean_install_dir() {
  yes | rm -r $INSTALL_DIR/home
  rm -r $INSTALL_DIR/md5
  rm -r $INSTALL_DIR/tmp
  rm $INSTALL_DIR/anomaly
  rm $INSTALL_DIR/mo2
  rm -r $INSTALL_DIR/md5
  rm $TEMP_DIR/md5.zip
  rm $INSTALL_DIR/launch.sh
  log_and_echo "Removed!"
}

### END FUNCTION DECLARATIONS

if [ "$1" == "clean" ]; then
  clean_install_dir
  rm $CONTY
  exit 0
elif [ "$1" == "--winetricks" ]; then
#  HOME_DIR=$CONTY_HOME $CONTY winetricks cmd d3dcompiler_47 d3dx10 d3dx11_43 d3dx9 dx8vb dxvk quartz vcrun2022
  install_winetricks
#  HOME_DIR=$CONTY_HOME $CONTY winetricks cmd d3dx9 dx8vb d3dcompiler_42 d3dcompiler_43 d3dcompiler_46 d3dcompiler_47 d3dx10_43 d3dx10 d3dx11_42 d3dx11_43 vcrun2022 dxvk quartz
  exit 0
elif [ "$1" == "--skip-validation" ]; then
  SKIP_VALIDATION=true
fi


log_and_echo "Welcome to the Zona install script. The log for this session is $LOG_FILE"
log_and_echo
log_and_echo "This script will take care of all the Wine/Proton stuff that has to happen for Zona to run on Linux. If you want to know more, it's in the readme."
log_and_echo
log_and_echo "Don't try to exit the installer or close the terminal window until you see a message saying INSTALL FINISHED - the installer will exit back to the system prompt on its own. If you do interrupt the installation process, you can restart the installer and it will continue from where it left off."
log_and_echo
log_and_echo "Zona will be installed in this directory:"
log_and_echo "> $INSTALL_DIR"
log_and_echo
y_or_n
if [ "$?" == "2" ]; then
  log_and_echo "IMPORTANT: this install method may not work correctly if you install Zona on a mounted filesystem or a secondary partition!"
  log_and_echo
  log_and_echo "If your game fails to launch after installation on a mounted filesystem or secondary partition, try installing somewhere in your primary filesystem or main hard drive."
  log_and_echo
  while true; do
    log_and_echo "Where should Zona be installed? (Wildcards like ~ don't work.)"
    read -r -p ">> " INSTALL_DIR
    INSTALL_DIR=$(realpath "$INSTALL_DIR")
    log_and_echo
    log_and_echo "Zona will be installed in $INSTALL_DIR."
    y_or_n
    if [ "$?" == "1" ]; then
      log_and_echo
      log_and_echo "Ok, Zona will be installed in $INSTALL_DIR."
      log_and_echo
      log_and_echo "IMPORTANT: if the installer is interrupted, you must retype this path exactly to continue from where you left off!"
      log_and_echo
      TEMP_DIR="$INSTALL_DIR/tmp"
      MD5_DIR="$INSTALL_DIR/md5"
      CONTY="$INSTALL_DIR/$conty"
      CONTY_HOME="$INSTALL_DIR/home"
      DRIVE_C="$INSTALL_DIR/home/Games/umu/umu-default/drive_c"

      break
    fi
  done
fi

launch_script_conty="#!/usr/bin/env bash

INSTALL_DIR=$INSTALL_DIR

CONTY=\"\$INSTALL_DIR/conty_lite.sh\"
CONTY_VIRTUAL_PREFIX=\"\$HOME/Games/umu/umu-default\"
CONTY_HOME=\"\$INSTALL_DIR/home\"

HOME_DIR=\$CONTY_HOME \$CONTY umu-run \$CONTY_VIRTUAL_PREFIX/drive_c/mo2/ModOrganizer.exe"

mkdir_if_absent $INSTALL_DIR

log_and_echo
log_and_echo "By default this script will place some symlinks and a launch script in $LINK_DIR."
y_or_n
if [ "$?" == "2" ]; then
  while true; do

    read -r -p "Enter the path to a better directory >> " new_dir
    new_dir=$(realpath "$new_dir")
    log_and_echo "The script will instead store symlinks and launch script in"
    log_and_echo "    $new_dir"
    log_and_echo "If it doesn't exist, it will be created."
    y_or_n
    if [ "$?" == "1" ]; then
      LINK_DIR="$new_dir"
      LAUNCH_SCRIPT_PATH="$LINK_DIR/launch.sh"
      break
    fi
  done
fi

desktop_entry="[Desktop Entry]
Type=Application
Version=1.0
Name=Zona v1.38
Comment=Launch S.T.A.L.K.E.R Zona
Path=
Exec=$LINK_DIR/launch.sh
Categories=Game
Terminal=true"

mkdir_if_absent $LINK_DIR
log_and_echo
log_and_echo "Which Zona settings do you want?"
log_and_echo "1) Clean HUD"
log_and_echo "2) BHS HUD"
1_or_2
hud_mode=$?
log_and_echo
log_and_echo "Zona requires modded exes from MrDemonized to run."
log_and_echo "Do you want the regular modded exes, or the multithreaded* ones?"
log_and_echo "Most people see a large performance boost with multithreading, but these are still in testing and may cause unexpected crashes or compatibility issues. Nevertheless recommended."
log_and_echo "1) Regular Demonized EXEs"
log_and_echo "2) Multithreaded Demonized EXEs"
1_or_2
exe_mode=$?

log_and_echo
log_and_echo "The installer will now download the required files. If the installer is interrupted, it should resume where it left off. If any files fail to validate, delete $TEMP_DIR and try again."
wait_for_keypress

section_change "DOWNLOADING REQUIRED FILES"

#mkdir_if_absent "$INSTALL_DIR/home"
mkdir_if_absent "$TEMP_DIR"
download_checksums
7z x -y -o"$INSTALL_DIR" "$TEMP_DIR/md5.zip" | tee -a "$LOG_FILE"
### DOWNLOAD SECTION

download $anomaly $anomaly_url
download $profiles $zona_profiles_url
download $mo2 $mo2_url

download $conty $conty_url

if [ "$exe_mode" == "1" ]; then
  download $demonized $demonized_url
else
  download $mt_test $mt_test_url
fi

if [ "$hud_mode" == "1" ]; then
  download $clean $clean_hud_url
else
  download $bhs $bhs_hud_url
fi

for url in "${zona_multipart[@]}"; do
  filename=$(basename $url)
  download $filename $url
done

### CHECKSUM SECTION
section_change "VALIDATING DOWNLOADED FILES"

if [ $SKIP_VALIDATION == false ]; then
  checkmd5 $anomaly 
  checkmd5 $profiles 
  checkmd5 $mo2 

  checkmd5 $conty

  if [ "$exe_mode" == "1" ]; then
    checkmd5 $demonized 
  else
    checkmd5 $mt_test 
  fi
  mkdir_if_absent "$MD5_DIR"

  if [ "$hud_mode" == "1" ]; then
    checkmd5 $clean
  else
    checkmd5 $bhs
  fi

  for url in "${zona_multipart[@]}"; do
    filename=$(basename $url)
    checkmd5 $filename 
  done
else
  log_and_echo "Skipping validation..."
fi

section_change "PREPARING FILESYSTEM"

log_and_echo "Moving $conty into $INSTALL_DIR from $TEMP_DIR ..."
cp "$TEMP_DIR/$conty" "$INSTALL_DIR"
log_and_echo "Making $conty executable ..."
chmod +x $CONTY
log_and_echo "Making wineprefix in $CONTY_HOME..."
log_and_echo "NOTE: If you see \"Application could not be started\" and \"ShellExecuteEx failed\", this is ok and intended behavior."
mkdir_if_absent "$CONTY_HOME"
HOME_DIR=$CONTY_HOME $CONTY umu-run "" | tee -a $LOG_FILE
log_and_echo "NOTE: If you see \"Application could not be started\" and \"ShellExecuteEx failed\", this is ok and intended behavior."
mkdir_if_absent "$DRIVE_C/mo2/profiles"
mkdir_if_absent "$DRIVE_C/mo2/mods"
mkdir_if_absent "$DRIVE_C/anomaly"
#FIXME mkdir_if_absent "$HOME/Games/zona/"
if [ -d "$LINK_DIR/mo2_folder" ]; then
  log_and_echo "Removing old symlink mo2_folder..."
  rm "$LINK_DIR/mo2_folder"
fi
if [ -d "$LINK_DIR/anomaly_folder" ]; then
  log_and_echo "Removing old symlink anomaly_folder..."
  rm "$LINK_DIR/anomaly_folder"
fi
if [ -d "$LINK_DIR/virtual_home" ]; then
  log_and_echo "Removing old symlink virtual_home..."
  rm "$LINK_DIR/virtual_home"
fi
log_and_echo "Making symbolic link to $CONTY_HOME ..."
ln -s "$CONTY_HOME" "$LINK_DIR/virtual_home"

log_and_echo "Making symbolic link to $DRIVE_C/mo2 ..."
ln -s "$DRIVE_C/mo2" "$LINK_DIR/mo2_folder"
log_and_echo "Making symbolic link to $DRIVE_C/anomaly ..."
ln -s "$DRIVE_C/anomaly" "$LINK_DIR/anomaly"

section_change "EXTRACTING FILES"


log_and_echo "Extracting $anomaly to $DRIVE_C/anomaly..."
7z x -y -o"$DRIVE_C/anomaly" $TEMP_DIR/$anomaly 

if [ "$exe_mode" == "1" ]; then
  log_and_echo "Extracting $demonized to $DRIVE_C/anomaly..."
  7z x -y -o"$DRIVE_C/anomaly" $TEMP_DIR/$demonized 
else
  log_and_echo "Extracting $mt_test to $DRIVE_C/anomaly..."
  7z x -y -o"$DRIVE_C/anomaly" $TEMP_DIR/$mt_test 
fi

log_and_echo "Extracting $mo2 to $DRIVE_C/mo2 ..."
7z x -y -o"$DRIVE_C/mo2" $TEMP_DIR/$mo2

log_and_echo "Extracting $profiles to $DRIVE_C/mo2/profiles ..."
7z x -y -o"$DRIVE_C/mo2/profiles" $TEMP_DIR/$profiles 
log_and_echo "Extracting ${zona[0]} to $DRIVE_C/mo2 ..."
7z x -y -o"$DRIVE_C/mo2" "$TEMP_DIR/${zona[0]}" 

section_change "IMPORTING ZONA SETTINGS"

if [ "$hud_mode" == "1" ]; then
  7z x -y -o"$TEMP_DIR" "$TEMP_DIR/$clean" 
  cp -r "$TEMP_DIR/Clean Hud/appdata" "$DRIVE_C/anomaly/"
  cp -r "$TEMP_DIR/Clean Hud/gamedata" "$DRIVE_C/anomaly/"
else
  7z x -y -o"$TEMP_DIR" "$TEMP_DIR/$bhs" | tee -a "$LOG_FILE"
  cp -r "$TEMP_DIR/Bhs Hud/appdata" "$DRIVE_C/anomaly/"
  cp -r "$TEMP_DIR/Bhs Hud/gamedata" "$DRIVE_C/anomaly/"
fi

section_change "FINAL PREP"

log_and_echo "Adding a launch script to install directory."
echo "$launch_script_conty" > "$LAUNCH_SCRIPT_PATH"
chmod +x $LAUNCH_SCRIPT_PATH

if [ ! -d "$HOME/.local/share/applications" ]; then
  log_and_echo "$HOME/.local/share/applications doesn't exist, which is weird, but ok."
  log_and_echo "Placing a .desktop file at $HOME/Desktop/$DESKTOP_ENTRY_NAME.desktop instead."
  echo "$desktop_entry" > "$HOME/Desktop/$DESKTOP_ENTRY_NAME.desktop"
else
  log_and_echo "Placing a .desktop file at $HOME/.local/share/applications/$DESKTOP_ENTRY_NAME.desktop"
  echo "$desktop_entry" > "$HOME/.local/share/applications/$DESKTOP_ENTRY_NAME.desktop"
fi
log_and_echo "The installer will now run winetricks to install essential Wine components. When installers pop up, Agree to any terms of service and click OK or Install."
log_and_echo
log_and_echo "HINT - if winetricks quits unexpectedly or hangs, or you get shader compilation issues, try this command to run winetricks again:"
log_and_echo
log_and_echo "    $(basename $0) --winetricks"

wait_for_keypress

install_winetricks

log_and_echo
log_and_echo "Zona installation finished. To launch Zona, run $LAUNCH_SCRIPT_PATH"
log_and_echo
log_and_echo "If you wish to install additional mods on top of Zona, you must drop their archives into $CONTY_HOME in order to make them visible to Mod Organizer! A symlink to this folder has been added at $HOME/Games/zona/virtual_home"
log_and_echo
section_change "INSTALL FINISHED"
log_and_echo
log_and_echo "Thank you for playing Zona!"
exit 0
