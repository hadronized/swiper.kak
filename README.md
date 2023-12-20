# swiper, a simple tool to filter your buffers

This tool is a composable tool used to _filter your Kakoune buffers_. It comes with two main commands:

- `swiper`
- `swiper-reduce`

<p align="center">
  <img src="https://github.com/phaazon/swiper.kak/assets/506592/b2599870-b346-4841-b48a-57ff83401c32"/>
</p>

## Reducing buffers

The `swiper-reduce` command is probably the most useful one, as it filters a buffer in-place (it _reduces_ it). It does
so by prompting the user a regex and passing it live (as the user types) to a UNIX filter command (set by the
`swiper_reduce_cmd` option) — which defaults to `grep -i`. This is done on the whole current buffer. It replaces live
the content of the buffer with the output of the filter.

Once `swiper-reduce` is called in a buffer, the buffer knows it’s altered by `swiper-reduce`. You can use the `bool`
option named `swiper_enabled`, which is set at the `buffer` level, to implement a specific modeline modifier, for
instance. `swiper_enabled` is removed when you abort the prompt (`<esc>`, for instance), of if you explicitly call
the `swiper-disable` command.

## The swiper callback

The `swiper` command works similarily, but instead of working on the current buffer, it creates a dedicated `*swiper*`
buffer containing a copy of the current buffer, and run the `swiper_cmd` UNIX filter on it — defaulting to `grep -in`.
The difference is that lines are preppended with the line number of the regex match, and validating (pressing `<cr>`) in
a `*swiper*` buffer will take the head line number and will jump to that line in the original buffer.

The `swiper` command accepts a _callback_, set by the `swiper_callback` option (which defaults to `x`, to select the
whole line), that is passed to `execute-keys` after jumping from a `*swiper*` buffer (pressing `<ret>`). For example,
you can easily grab all the files from your projects and fuzzy search them with the following snippet:

```kak
define-command file-picker %{
  try %{
    edit -scratch '*file-picker*'

    map buffer normal <ret> 'x_gf'
    add-highlighter buffer/file-picker-item regex (.*) 1:cyan
    set-option buffer swiper_callback 'x_gf'

    execute-keys '|fd --type=file<ret>gg'
  }
}
```

Run `:file-picker`, and then invoke `:swiper` on it. It will open a new `*swiper*` buffer, containing all the file
paths and line numbers in front. Type the regex you want, and submit the prompt by pressing `<ret>`. You can see that
the `*swiper*` buffer got filtered. Navigate to the line of the file you want to open, then press `<ret>` to jump to it.
This will jump to the line of the original buffer (here, `*file-picker*`) and will execute the callback, here `x_gf`,
which will in turns jump to the file location.
