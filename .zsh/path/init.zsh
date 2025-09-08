#!/bin/zsh

local -a zpaths
zstyle -a ':zim:path' paths 'zpaths'

for p ("$zpaths[@]"); do
  if [ -d "$p" ]; then
    case :$PATH: in
      *:$p:*) ;;
      *) PATH=$p:$PATH ;;
    esac
  fi
done
