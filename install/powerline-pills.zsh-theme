pills_dir="$(cd ${0:a:h}/..; pwd)"

function set-prompt {
  # turn off the right prompt set by vi-mode
  RPS1=""
  PROMPT="\$(ruby ${pills_dir}/lib/powerline_pills.rb ${1} \$?)"
}

function set-pills-prompt {
  set-prompt "${KEYMAP}"
  zle reset-prompt
}

zle -N zle-line-init set-pills-prompt
zle -N zle-keymap-select set-pills-prompt

set-prompt "main"