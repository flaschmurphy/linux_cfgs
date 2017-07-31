#
# Install script for vim plugins
#

set -u    # Die if trying to access variables that are undefined
set -e    # Exit if any command has a non-zero return value

DATE=$(date +%Y%m%d%H%M%S)

install_vimrc() {
    # Backup and install .vimrc
    if [[ -f ~/.vimrc ]]; then
        cp ~/.vimrc ~/.vimrc_$(DATE)
        echo 'Backed up current .vimrc file to ~/.vimrc_DATETIME'
    fi
    cp vimrc ~/.vimrc
    HOME=~
    echo 'Installed new vimrc file as' ${HOME}'/.vimrc'
}

install_pathogen() {
    # Pathogen setup, see https://gist.github.com/romainl/9970697
    [[ -d ~/.vim ]] || mkdir ~/.vim
    echo 'Installing Pathogen...'
    [[ -d ~/.vim/autoload ]] || mkdir ~/.vim/autoload/
    [[ -d ~/.vim/bundle ]] || mkdir ~/.vim/bundle/
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
}

install_delimitmate() {
    # Install delimitmate
    echo 'Installing Delimitmate (if not alread installed)...'
    cd ~/.vim/bundle
    [[ -d delimitMate ]] || git clone https://github.com/Raimondi/delimitMate.git
    cd -
}


main() {

    # Move to the dir this script resides in, then move back once done
    ORIG_DIR=$(pwd)
    SCRPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $SCRPT_DIR

    install_vimrc
    install_pathogen
    install_delimitmate

    echo 'Done.'
    cd $ORIG_DIR
}

main
