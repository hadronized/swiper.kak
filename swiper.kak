# swiper.kak is a simple tool that applies on a given buffer to filter its content. It works by invoking a command
# (%opt{swiper_cmd}) on the original buffer content, displaying the result in another buffer. <ret> is then forwarded
# to the original buffer on the appropriate line.

declare-option str swiper_cmd 'grep -in'
declare-option str swiper_buf

define-command swiper %{
  set-option global swiper_buf %val{bufname}

  evaluate-commands -draft %{
    execute-keys '%"ay'
    edit -scratch '*swiper*'
    set-register z %reg{a}
    execute-keys '"aR'
  }

  buffer '*swiper*'
  swiper--prompt

  map buffer normal <ret> ':swiper--jump<ret>'
}

define-command -hidden swiper--jump %{
  evaluate-commands -save-regs 'a' %{
    execute-keys 'git:"ay'
    swiper--cleanup
    execute-keys "%reg{a}gx"
  }
}

define-command -hidden swiper--prompt %{
  prompt -on-change swiper--update-content swiper: %{
    execute-keys 'gg'
  }
}

define-command -hidden swiper--update-content %{
  evaluate-commands -draft %{
    # filter the content with the command
    execute-keys "%%""zR|%opt{swiper_cmd} ""%val{text}""<ret>"
  }
}

define-command -hidden swiper--cleanup %{
  buffer %opt{swiper_buf}
  set-option global swiper_buf ''
  delete-buffer! '*swiper*'
}

