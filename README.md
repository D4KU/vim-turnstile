# vim-turnstile

This [Vim](https://github.com/vim/vim) plugin allows to swap the left neighbor
of a given word in the current line with its right neighbor. This is useful
when you want to swap operands of an arithmetic or boolean expression, such as
`a` and `b` in `a - b`.

## Installation

When using [vim-plug](https://github.com/junegunn/vim-plug), paste the
following into your vimrc file and customize the mapping to your wishes:

```
Plug 'D4KU/vim-turnstile'
nnoremap <Leader>s :<C-U>call turnstile#turn('')<Left><Left>
```

## Usage

The mapping positions your cursor in the command line between the quotes,
ready to enter the word whose neighbors are to be swapped. For example to
swap `a` and `b` in the expression `a && b`, pass `&&`.

The function also accepts a count, allowing you to specify a word to swap
neighbors of if it appears multiple times in the current line. For example
pressing `2\s+` and enter in normal mode - assuming backslash is your leader
key - over the line `y = a + b + c;` swaps `b` and `c`. A count of 1 is
assumed if none is given.

## Similar Plugins

* [vim-swap](https://github.com/kurkale6ka/vim-swap)
* [vim-pivot](https://github.com/hwayne/vim-pivot)
