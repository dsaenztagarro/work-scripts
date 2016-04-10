Alfred workflow configuration
-----------------------------

Language: `/bin/bash`
Script:

```bash
query="{query}"
source "${HOME}/.bash_profile"
cd $HOME/Scripts/ruby/lib/
./com.bebanjo.tmux.rb --prefix='project_' --projects='{query}'
```

Script configuration
--------------------

```
cd ~/Scrips/ruby
bundle
```
