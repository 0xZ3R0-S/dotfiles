# OSX version requirement

print_divider() {
  echo
  echo 
  echo "--------------------------------------------------"
}

###########################################################
#                                                         #
#          Homebrew Install                               #
#                                                         #
###########################################################

homebrew_install() {
  print_divider
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo
  echo "PLEASE WAIT FOR THIS TO FINISH TO SELECT WHAT TO INSTALL"
  echo
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  print_divider
  echo "Installing homebrew..."
  if [ ! -f /usr/local/bin/brew ]; then
    ruby -e "$(\curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap homebrew/cask-versions
  else
    echo "Homebrew already installed. So far, so good."
  fi

  # Update brew
  print_divider
  echo "Updating Brew..."
  brew update

  # Install MAS (Mac App Store)
  print_divider
  echo "Installing mas to install from the Mac App Store..."
  brew install mas
}

whiptail_install() {
  print_divider
  echo "Installing whiptail..."
  if [ ! -f /usr/local/bin/whiptail ]; then
    brew install newt
  else
    # Test whiptail version
    whiptail -v > /dev/null 2>/dev/null
    if [[ $? -ne 0 ]]; then
      brew reinstall newt
    else
      echo "Whiptail already installed. Going on..."
    fi
  fi
}


confirm() {
    read -p "$1 ([y]es or [n]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) return 1 ;;
        *)     return 0 ;;
    esac
}



SW_VERS=$(sw_vers -productVersion)
if [[ ! $(echo $SW_VERS | egrep '10.(15)')  ]]
then
    echo "The script requires macOS 10.13.X (High Sierra) to run. You are running version $SW_VERS"
    exit 1
fi


###########################################################
#                                                         #
#           Push Settings                                 #
#                                                         #
###########################################################

mac_settings() {
  # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Always show scroll bar
  defaults write NSGlobalDomain AppleShowScrollBars -string “Always”

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Trackpad: disable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool false
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 0
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 0

  # Trackpad: disable launchpad pinch with thumb and three fingers
  defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

  # Trackpad set scroll direction
  defaults write -g com.apple.swipescrolldirection -bool FALSE

  # Bluetooth: Increase sound quality for Bluetooth headphones/headsets
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  # Dock: Hot corners: Top right screen corner → Start Screensaver
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0

  # Finder: Show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Messages.app: Disable smart quotes as it’s annoying for messages that contain code
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

  # Text Edit: Use plain text mode for new TextEdit documents
  defaults write com.apple.TextEdit RichText -int 0

  # Text Edit: Disable auto correct
  defaults write com.apple.TextEdit NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write com.apple.TextEdit TextReplacement -bool false

  # Text Edit: Open and save files as UTF-8 in TextEdit
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  # Terminal.app: Only use UTF-8 in Terminal
  defaults write com.apple.terminal StringEncodings -array 4

  # Kill affected applications
  for app in \
    Dock \
    Finder \
    Safari \
    SystemUIServer \
    ; do killall "$app" >/dev/null 2>&1
  done
}



###########################################################
#                                                         #
#           Install APPS                                  #
#                                                         #
###########################################################

install_menu() {
  choice=$(whiptail --title "Welcome to Zpriddy Install"  --cancel-button Exit --checklist \
  "Choose what to install" 20 90 10 \
  "settings" "Mac OSX Settings" ON\
  "1Password" "1Password" ON\
  "iTerm2" "iTerm2"  ON\
  "mattermost" "MatterMost" OFF\
  "gitkracken" "Gitkraken"  ON\
  "wget"      "wget" ON \
  "jetbrains" "JetBrains Toolbox" ON\
  "chrome" "chrome" ON\
  "keybase" "keybase" ON\
  "keepingyouawake" "keepingyouawake" ON\
  "notion" "Notion" ON\
  "vlc" "VLC" ON\
  "sublime" "SublimeText" ON\
  "vscode" "VS Code" ON\
  "paw" "Paw.Cloud" ON\
  "spotify" "Spotify" ON\
  "terraform" "terraform" ON\
  "moom" "Moom (AppStore)" ON\
  "magnet" "Magnet (AppStore)" ON\
  "slack" "Slack (AppStore)" ON\
  "istat" "iStat Menus (AppStore)" ON\
  "alfred" "Alfred" ON\
  "black" "Black" ON\
  "awscli" "AWS CLI" ON\
  "tox" "Tox" ON\
  "jq" "JSON Query" ON\
  "jid" "JSON Query Interactive" ON\
  "xcode" "XCode (AppStore)" ON\
  "dockercore" "Docker" ON\
  "docker-compose" "Docker Compose" ON\
  "pyenv" "Pyenv & pyenv-virtualenv" ON\
  "py27" "Pyenv Python 2.7" ON\
  "py35" "Pyenv Python 3.5" ON\
  "py36" "Pyenv Python 3.6" ON\
  "py37" "Pyenv Python 3.7" ON\
  "py38" "Pyenv Python 3.8" ON\
  3>&1 1>&2 2>&3)

  if [[ "$choice" == *"settings"* ]]; then
    print_divider
    echo "Setting Mac Settings..."
    mac_settings
  fi

  if [[ "$choice" == *"black"* ]]; then
    print_divider
    echo "Installing Black..."
    brew install black
  fi

  if [[ "$choice" == *"tox"* ]]; then
    print_divider
    echo "Installing Tox..."
    brew install tox
  fi

  if [[ "$choice" == *"1Password"* ]]; then
    print_divider
    echo "Installing 1Password..."
    brew cask install 1password
  fi

  if [[ "$choice" == *"iTerm2"* ]]; then
    print_divider
    echo "Installing iTerm..."
    brew cask install iterm2
  fi

  if [[ "$choice" == *"gitkracken"* ]]; then
    print_divider
    echo "Installing GetKraken..."
    brew cask install gitkraken
  fi

  if [[ "$choice" == *"wget"* ]]; then
    print_divider
    echo "Installing wget..."
    brew install wget
  fi

  if [[ "$choice" == *"terraform"* ]]; then
    print_divider
    echo "Installing terraform..."
    brew install terraform
  fi

  if [[ "$choice" == *"jetbrains"* ]]; then
    print_divider
    echo "Installing Jetbrains Toolbox..."
    brew cask install jetbrains-toolbox
  fi

  if [[ "$choice" == *"chrome"* ]]; then
    print_divider
    echo "Installing Chrome..."
    brew cask install chrome
  fi

  if [[ "$choice" == *"vlc"* ]]; then
    print_divider
    echo "Installing VLC..."
    brew cask install vlc
  fi

  if [[ "$choice" == *"spotify"* ]]; then
    print_divider
    echo "Installing Spotify..."
    brew cask install spotify
  fi

  if [[ "$choice" == *"notion"* ]]; then
    print_divider
    echo "Installing Notion..."
    brew cask install notion
  fi

  if [[ "$choice" == *"awscli"* ]]; then
    print_divider
    echo "Installing AWS CLI..."
    brew cask install awscli
  fi

  if [[ "$choice" == *"jq"* ]]; then
    print_divider
    echo "Installing JSON Query..."
    brew cask install jq
  fi

  if [[ "$choice" == *"jdi"* ]]; then
    print_divider
    echo "Installing JSON Query Interactive..."
    brew cask install jq
  fi

  if [[ "$choice" == *"keepingyouawake"* ]]; then
    print_divider
    echo "Installing Keeping You Awake..."
    brew cask install keepingyouawake
  fi

  if [[ "$choice" == *"vscode"* ]]; then
    print_divider
    echo "Installing VS Code..."
    brew cask install visual-studio-code
  fi

  if [[ "$choice" == *"moom"* ]]; then
    print_divider
    echo "Installing moom..."
    mas install 419330170
  fi

  if [[ "$choice" == *"magnet"* ]]; then
    print_divider
    echo "Installing Magnet..."
    mas install 441258766
  fi

  if [[ "$choice" == *"slack"* ]]; then
    print_divider
    echo "Installing Slack..."
    mas install 803453959
  fi

  if [[ "$choice" == *"istat"* ]]; then
    print_divider
    echo "Installing iStat..."
    mas install 1319778037
  fi

  if [[ "$choice" == *"alfred"* ]]; then
    print_divider
    echo "Installing Alfred..."
    brew cask install alfred
  fi

  if [[ "$choice" == *"paw"* ]]; then
    print_divider
    echo "Installing Paw.Cloud..."
    brew cask install paw
  fi

  if [[ "$choice" == *"sublime"* ]]; then
    print_divider
    echo "Installing SublimeText..."
    brew cask install sublime-text
  fi

  if [[ "$choice" == *"xcode"* ]]; then
    print_divider
    echo "Installing XCode..."
    mas install 497799835
  fi

  if [[ "$choice" == *"dockercore"* ]]; then
    print_divider
    echo "Installing Docker..."
    brew cask install docker
  fi

  if [[ "$choice" == *"docker-compose"* ]]; then
    print_divider
    echo "Installing Docker Compose..."
    brew install docker-compose
  fi

  if [[ "$choice" == *"mattermost"* ]]; then
    print_divider
    echo "Installing MatterMost..."
    brew cask install mattermost
  fi

  if [[ "$choice" == *"pyenv"* ]]; then
    print_divider
    echo "Installing pyenv and python versions..."
    brew install pyenv
    brew install pyenv-virtualenv
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Add to zshrc:"
    echo
    echo "export PYENV_ROOT=\"\$HOME/.pyenv\""
    echo "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    echo "echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval \"\$(pyenv init -)\"\nfi' >> ~/.zshrc"
    echo "eval \"\$(pyenv init -)\" >> ~/.zshrc"
    echo "eval \"\$(pyenv virtualenv-init -)\""
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo

    # This is to use pyenv now
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv init -
    pyenv virtualenv-init - 

    if [[ "$choice" == *"py27"* ]]; then
      echo "Installing Python 2.7..."
      pyenv install -s 2.7.17
    fi

    if [[ "$choice" == *"py35"* ]]; then
      echo "Installing Python 3.5..."
      pyenv install -s 3.7.7
    fi

    if [[ "$choice" == *"py36"* ]]; then
      echo "Installing Python 3.6..."
      pyenv install -s 3.6.9
    fi

    if [[ "$choice" == *"py37"* ]]; then
      echo "Installing Python 3.7..."
      pyenv install -s 3.5.7
    fi

    if [[ "$choice" == *"py38"* ]]; then
      echo "Installing Python 3.8..."
      pyenv install -s 3.8.2
    fi

  fi
}

###########################################################
#                                                         #
#           Install Dotfiles                              #
#                                                         #
###########################################################

install_dotfiles() {
  echo "Setting up .dotfiles"
  echo "Not Done Yet"
}

###########################################################
#                                                         #
#           Install ZSH                                   #
#                                                         #
###########################################################

install_zsh() {
  export ZSH_DISABLE_COMPFIX=true
  print_divider
  echo "Setting up ZSH and Oh-My-Zsh"
  print_divider
  echo "Installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  print_divider
  echo "Installing PowerLevel10K... (Used in my ZSH Config..)"
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k


  print_divider
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo
  echo "Done setting up Oh-My-Zsh..."
  echo "Please make sure to install dotfiles.."
  echo
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

###########################################################
#                                                         #
#           Start of main installer script                #
#                                                         #
###########################################################
clear

# Base Confirm Dialogue
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo "This script will try to setup your system for web development and "
echo "install standard productivity apps."
echo
echo "In the next step you can configure which programs you want to have installed."
echo
echo
echo "+––––––––––––––––+"
echo "| PLEASE NOTICE! |"
echo "+––––––––––––––––+"
echo
echo "The script needs homebrew to work. If you have already installed it. Fine."
echo "If not, it will install it for you."
echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo
confirm "Continue?"
CONTINUE=$?

clear

if [[ $CONTINUE -eq 1 ]]; then
    homebrew_install
    whiptail_install
    clear
else
  exit
fi

install_menu
install_zsh
install_dotfiles


