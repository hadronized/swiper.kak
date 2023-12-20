# swiper.kak is a simple tool that applies on a given buffer to filter its content. It works by invoking a command
# (%opt{swiper_cmd}) on the original buffer content, displaying the result in another buffer. <ret> is then forwarded
# to the original buffer on the appropriate line.

declare-option str swiper_cmd 'grep -in'
declare-option str swiper_reduce_cmd 'grep -i'
declare-option bool swiper_enabled
declare-option str swiper_buf
declare-option str swiper_content
declare-option str swiper_callback 'x'

define-command swiper -docstring 'swiper: open a *swiper* buffer with the content of the current one' %{
  evaluate-commands %sh{
    if [ "$kak_opt_swiper_enabled" != 'true' ]; then
      echo "swiper--setup"
      echo "edit -scratch '*swiper*'"
      echo "map buffer normal <ret> ':swiper--jump<ret>'"
    fi

    echo 'swiper--prompt "%opt{swiper_cmd}"' 
  }
}

define-command swiper-reduce -docstring ':swiper-reduce: open swiper on the current buffer' %{
  evaluate-commands %sh{
    if [ "$kak_opt_swiper_enabled" != 'true' ]; then
      echo "swiper--setup"
    fi

    echo 'swiper--prompt "%opt{swiper_reduce_cmd}"' 
  }
}

define-command swiper--setup %{
  set-option global swiper_buf %val{bufname}
  set-option buffer swiper_enabled true

  evaluate-commands -draft %{
    execute-keys '%"ay'
    set-option global swiper_content %reg{a}
  }
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
  prompt -on-change "swiper--update-content ""%arg{1}""" -on-abort swiper--disable swiper: %{
    execute-keys 'gg'
  }
}

define-command -hidden swiper--update-content -params 1 %{
  evaluate-commands -draft %{
    # resume the original content
    set-register z %opt{swiper_content}

    # filter the content with the command
    execute-keys "%%""zR|%arg{1} ""%val{text}""<ret>"
  }
}

define-command swiper--disable %{
  swiper--cleanup
  set-option buffer swiper_enabled false
}

define-command -hidden swiper--cleanup %{
  buffer %opt{swiper_buf}
  set-option global swiper_buf ''

  try %{
    delete-buffer! '*swiper*'
  }

  # restore original content
  evaluate-commands -draft %{
    set-register z %opt{swiper_content}
    execute-keys '%"zR'
  }

  set-option global swiper_content ''
}

