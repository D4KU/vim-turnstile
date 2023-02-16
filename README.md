# vim-turnstile

This [Vim](https://github.com/vim/vim) plugin allows to swap the left neighbor
of a given word in the current line with its right neighbor. This is useful
when you want to swap operands of an arithmetic or boolean expression, such as
`a` and `b` in `a - b`. The plugin is build with the syntax of C-like
programming languages in mind.

## Installation

When using [vim-plug](https://github.com/junegunn/vim-plug), paste the
following into your vimrc file and customize the mapping to your wishes:

```
Plug 'D4KU/vim-turnstile'
nnoremap <Leader>s :<C-U>call turnstile#turn('')<Left><Left>
```

## Usage

When you use the mapping your cursor is put in the command line between the
quotes, ready to insert the word of which its neighbors to swap. So if you
want to swap `a` and `b` in the expression `a && b`, pass `&&`.

The function also accepts a count, allowing you to specify which word you want
to swap neighbors of, if it appears multiple times in the current line. For
example pressing `2\s+` and enter in normal mode with backslash as your
leader key over the line `y = a + b + c;` swaps `b` and `c`. A count of 1 is
assumed if none is given.
