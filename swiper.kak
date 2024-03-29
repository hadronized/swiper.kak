# swiper.kak is a simple tool that applies on a given buffer to filter its content. It works by invoking a command
# (%opt{swiper_cmd}) on the original buffer content, displaying the result in another buffer. <ret> is then forwarded
# to the original buffer on the appropriate line.

declare-option str swiper_cmd 'grep -in'
declare-option str swiper_reduce_cmd 'grep -i'
declare-option bool swiper_enabled
declare-option str swiper_terms
declare-option str swiper_buf
declare-option str swiper_content
declare-option str swiper_callback 'x'

define-command swiper -docstring 'swiper: open a *swiper* buffer with the content of the current one' %{
  evaluate-commands %sh{
    if [ "$kak_opt_swiper_enabled" != 'true' ]; then
      echo "swiper--setup"
      echo "edit -scratch '*swiper*'"
      echo "swiper--add-highlighters"
      echo "map buffer normal <ret> ':swiper--jump<ret>'"
    fi

    echo 'swiper--prompt "%opt{swiper_cmd}"' 
  }
}

define-command swiper-reduce -docstring ':swiper-reduce: open swiper on the current buffer' %{
  evaluate-commands %sh{
    if [ "$kak_opt_swiper_enabled" != 'true' ]; then
      echo "swiper--setup"
      echo "set-option buffer swiper_enabled true"
    fi

    echo 'swiper--prompt "%opt{swiper_reduce_cmd}"' 
  }
}

define-command -hidden swiper--setup %{
  set-option global swiper_buf %val{bufname}

  evaluate-commands -draft %{
    execute-keys '%"ay'
    set-option global swiper_content %reg{a}
  }
}

define-command -hidden swiper--add-highlighters %{
  add-highlighter -override buffer/swiper regex '^([0-9]+:)([^\n]*)$' 1:green 2:cyan
}

define-command -hidden swiper--jump %{
  evaluate-commands -save-regs 'a' %{
    execute-keys 'git:"ay'
    swiper--cleanup
    execute-keys "%reg{a}g"
    execute-keys -with-maps -with-hooks %opt{swiper_callback}
  }
}

define-command -hidden swiper--prompt -params 1 %{
  prompt -on-change "swiper--update-content ""%arg{1}""" -on-abort swiper-disable swiper: %{
    execute-keys 'gg'
  }
}

define-command -hidden swiper--update-content -params 1 %{
  evaluate-commands -draft %{
    # resume the original content
    set-register z %opt{swiper_content}

    # filter the content with the command
    execute-keys "%%""zR|%arg{1} ""%val{text}""<ret>"

    # set the swiper terms
    set-option buffer swiper_terms %val{text}
  }
}

define-command swiper-disable %{
  swiper--cleanup
  unset-option buffer swiper_terms
  unset-option buffer swiper_enabled 
}

define-command -hidden swiper--cleanup %{
  try %{
    buffer %opt{swiper_buf}
    set-option global swiper_buf ''

    # restore original content
    evaluate-commands -draft %{
      set-register z %opt{swiper_content}
      execute-keys '%"zR'
    }

    set-option global swiper_content ''
  }

  try %{
    delete-buffer! '*swiper*'
  }
}
