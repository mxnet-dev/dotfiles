#!/bin/bash

create_symlinks() {
    # Get the directory in which this script lives.
    script_dir=$(dirname "$(readlink -f "$0")")

    # Get a list of all files in this directory that start with a dot.
    files=$(find -maxdepth 1 -type f -name ".*")

    # Create a symbolic link to each file in the home directory.
    for file in $files; do
        name=$(basename $file)
        echo "Creating symlink to $name in home directory."
        rm -rf ~/$name
        ln -s $script_dir/$name ~/$name
    done
}

create_symlinks

echo -e "⤵ Upgrading packages..."
sudo apt-get update
sudo apt-get -y upgrade
echo -e "✅ Successfully upgraded packages"

# Add GPG forwarding
echo 'StreamLocalBindUnlink yes' | sudo tee -a /etc/ssh/sshd_config

# Set up zsh tools
PATH_TO_ZSH_DIR=$HOME/.oh-my-zsh
echo -e "Checking if .oh-my-zsh directory exists at $PATH_TO_ZSH_DIR..."
if [ -d $PATH_TO_ZSH_DIR ]
then
   echo -e "\n$PATH_TO_ZSH_DIR directory exists!\nSkipping installation of zsh tools.\n"
else
   echo -e "\n$PATH_TO_ZSH_DIR directory not found."
   echo -e "⤵ Configuring zsh tools in the $HOME directory..."

   (cd $HOME && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended)
   echo -e "✅ Successfully installed zsh tools"

   # Clone plugins
   echo -e "Cloning plugins..."
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $PATH_TO_ZSH_DIR/plugins/zsh-syntax-highlighting
   git clone https://github.com/zsh-users/zsh-autosuggestions.git $PATH_TO_ZSH_DIR/plugins/zsh-autosuggestions
   echo -e "Plugins cloned!"
fi

# Set up symlink for .zshrc
ZSHRC_LINK=$HOME/.zshrc
if [ -L ${ZSHRC_LINK} ] ; then
   if [ -e ${ZSHRC_LINK} ] ; then
      echo -e "\n.zshrc is symlinked corrected"
   else
      echo -e "\nOops! Your symlink appears to be broken."
   fi
elif [ -e ${ZSHRC_LINK} ] ; then
   echo -e "\nYour .zshrc exists but is not symlinked."
   # We have to symlink the .zshrc after we curl the install script
   # because the default zsh tools installs a new one, even if it finds ours
   rm $HOME/.zshrc
   echo -e "⤵ Symlinking your .zshrc file"
   ln -s $HOME/.config/coderv2/dotfiles/.zshrc $HOME/.zshrc
   echo -e "✅ Successfully symlinked your .zshrc file"
else
   echo -e "\nUh-oh! .zshrc missing."
fi

# Set the default shell
echo -e "⤵ Changing the default shell"
sudo chsh -s $(which zsh) $USER
echo -e "✅ Successfully modified the default shell"
