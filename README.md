Alfred workflow configuration
-----------------------------

Language: `/bin/bash`
Script:

```
function call_tmux_script()
{
  ARGS=$*
  PREFIX=$1; shift
  PROJECTS=$*

  case $PREFIX in
    bj)
      PREFIX="bebanjo_"
      ;;
    pro)
      PREFIX="project_"
      ;;
    *)
      PREFIX=""
      PROJECTS=$ARGS
  esac

  source "${HOME}/.bash_profile"
  cd $HOME/Scripts/ruby/lib/
  ./com.bebanjo.tmux.rb --prefix="${PREFIX}" --projects="${PROJECTS}"
}

call_tmux_script {query}
```

Script configuration
--------------------

```
cd ~/Scrips/ruby
bundle
```
