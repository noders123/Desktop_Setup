# set up brew
  #Install Necessary Dependencies
  sudo apt-get install build-essential curl git

  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to Your PATH
  (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # Test brew
  brew --version
  brew doctor
  

# argocd CLI
brew install argocd

# Setup lazygit
brew install lazygit

# Setup cursor as wsl command for opening folders in cursor
echo -e '\n# Cursor \nexport PATH="$PATH:/mnt/c/'Program Files'/cursor/resources/app/bin/"' >> ~/.bashrc

# Install ncdu
sudo apt install -y ncdu

# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Install Terragrunt
brew install terragrunt

# Install AWSCLI
sudo snap install aws-cli --classic
