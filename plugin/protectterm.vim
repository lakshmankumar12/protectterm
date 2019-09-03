" Last modified 2017-11-30
" Dorai Sitaram

" By default, Neovim warns you only of unsaved file buffers
" before you exit, not of unclosed terminal buffers, which will
" be summarily killed. Unintentionally killing a terminal buffer
" can be frustrating, not only because of killed processes (which
" could be restarted) but also for the lost scroll history. This
" plugin prevents that loss.

" If you want to exit vi anyway, losing not just your terminals
" but also any changes to other buffers, use :qa!

" s:num_termbufs keeps track of the number of terminal buffers

let s:num_termbufs = 0

let s:vi_has_termbufs = tempname() . "_vi_session_has_open_terminal_buffers"

au termopen * call s:add1_num_termbufs()

" On opening a new terminal, increment s:num_termbufs
"
" If going from 0 to 1 terminal:
" - open a temp file buffer s:vi_has_termbufs, modify
"   it, but leave it unsaved
" - ensure 'confirm' turned off
"
" This ensures exit attempts will fail because of the unsaved
" buffer

func! s:add1_num_termbufs()
  let s:num_termbufs = s:num_termbufs + 1
  if s:num_termbufs == 1
    exec 'sp' s:vi_has_termbufs
    setl noswf
    %d
    $s/$/\=strftime("%c")/
    call append(line('^'), "You can close this buffer with a bn! or just close window with a q!")
    call append(line('^'), "You have some open terminal buffers. Close them first")
    setl ro
    close!
    let s:cf_sav = &cf
    set nocf
  endif
endfunc

au termclose * call s:sub1_num_termbufs()

" On closing a terminal, decrement s:num_termbufs. If there are
" now no more terminals, delete the s:vi_has_termbufs
" buffer so an exit attempt has no excuse to fail, at least not
" due to terminals. Also restore 'confirm' to its usual value

func! s:sub1_num_termbufs()
  let s:num_termbufs = s:num_termbufs - 1
  if s:num_termbufs == 0
    if bufexists(s:vi_has_termbufs)
      exec 'bd!' s:vi_has_termbufs
    endif
    let &cf = s:cf_sav
  endif
endfunc

" When trying exit with terminals running, vi will show up some
" unsaved buffer for your consideration. If this is the
" s:vi_has_termbufs buffer, you don't really need to see
" it: so have vi switch to something other buffer immediately

exec "au bufwinenter" s:vi_has_termbufs "bn!"
