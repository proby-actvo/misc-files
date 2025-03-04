# general aliases
alias brewit='brew update && brew upgrade && brew cleanup && brew doctor'
alias ll='ls -lAh'

# ACTVO aliases
alias act='cd $HOME/code/backend && source .venv/bin/activate && export PYTHONPATH=.'
alias rbe='act && python app/main.py'
alias tests='TESTING=1 pytest '
alias testing='tests'

alias ahist='alembic history --indicate-current | head'
alias alist='ahist'
alias adown='alembic downgrade $(alist | grep "(current)" | cut -d " " -f 1)'
alias aup='alembic upgrade head'

alias thist='TESTING=1 ahist'
alias tlist='thist'
alias tdown='TESTING=1 alembic downgrade $(tlist | grep "(current)" | cut -d " " -f 1)'
alias tup='TESTING=1 aup'
