## do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

## Confirmation #
alias mv='mv -iv'
alias cp='cp -iv'
alias ln='ln -iv'

## Parenting changing perms on / #
alias chown='chown -c --preserve-root'
alias chmod='chmod -c --preserve-root'
alias chgrp='chgrp -c --preserve-root'
