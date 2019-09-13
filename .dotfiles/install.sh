git clone --single-branch --branch arch --bare https://github.com/chadac/dotfiles.git $HOME/.cfg
function config {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} sh -c 'mkdir -p .config-backup/$(dirname {}); mv {} .config-backup/{};'
fi;
config checkout
config config status.showUntrackedFiles no
