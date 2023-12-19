# swiper.kak is a simple tool that applies on a given buffer to filter its content. It works by invoking a command
# (%opt{swiper_cmd}) on the original buffer content, displaying the result in another buffer. <ret> is then forwarded
# to the original buffer on the appropriate line.

declare-option str swiper_cmd 'grep -in'
declare-option str swiper_buf
declare-option str swiper_content

define-command -override swiper %{
  set-option global swiper_buf "*swiper*-%sh{ sed 's/*//g' <<< $kak_bufname }"

  evaluate-commands -draft %{
    execute-keys '%"ay'
    edit -scratch %opt{swiper_buf}
    set-register z %reg{a}
    execute-keys '"aR'
  }

  buffer %opt{swiper_buf}
}

define-command swiper--prompt %{
  prompt -on-change swiper--update-content swiper: %{}
}

define-command -override swiper--update-content %{
  evaluate-commands -draft %{
    # filter the content with the command
    execute-keys "%%""zR|%opt{swiper_cmd} ""%val{text}""<ret>"
  }
}
