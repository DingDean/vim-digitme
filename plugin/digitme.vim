" File: digitme
" Description: A Vim Plugin To Abstract Coding Process
" Last Change:	2018 May 04
" Maintainer:	Ke Ding <me@dingkewz.com>
" License:	MIT

" channel only available in vim version >= 8.0
if v:version < 800
  finish
endif

" Only load once
if exists("g:loaded_digitme")
  finish
endif
let g:loaded_digitme = 1

let s:save_cpo = &cpo
set cpo&vim

" Default Plugin Options
function! digitme#init()
  let g:hitme#clientUrl = get(g:, 'hitme#clientUrl', "localhost:8763")
  let g:hitme#client = get(g:, 'hitme#client', 'digitme-cli')
  if executable(g:hitme#client) == 0
    echom "DigitalMe Client is not installed"
    return
  endif

  "check client is running
  let isRunning = system(g:hitme#client . ' check')
  if isRunning == 0
    echom "DigitalMe Client is not running, starting now"
    system(g:hitme#client . ' start')
    if system(g:hitme#client . ' check' == 0)
      echom "Failed to start DigitalMe Client"
      return
    endif
  endif

  call s:OpenChannel()
endfunction

" Ping Client When Cursor Moved
function! digitme#ping()
  " TODO: 2018-05-16 Benchmark and Improve
  " eventhough lag is not noticed,
  " still ping method should be benchmarked
  call digitme#send( {'event': 'ping'} )
endfunction

function! digitme#bufenter ()
  let l:msg = {'event': 'bufEnter'}
  let l:msg.data = s:GetFileInfo()
  call digitme#send( l:msg )
endfunction

function! digitme#bufleave ()
  let l:msg = {'event': 'bufLeave'}
  let l:msg.data = s:GetFileInfo()
  call digitme#send( l:msg )
endfunction

function! s:MyCloseCallback(channel)
  echom "DigitalMe channel is closed"
  let g:hitme#client_is_set = v:false
endfunction

function! s:OpenChannel()
  let s:channel = ch_open(g:hitme#clientUrl,
        \ {"close_cb": "s:MyCloseCallback"})
  if ch_status(s:channel) == "fail"
    echom "Failed to establish digitalme channel"
    let g:hitme#client_is_set = v:false
  endif
  let g:hitme#client_is_set = v:true
endfunction

function! digitme#validate( msg )
  if type(a:msg) != v:t_dict
    return v:false
  endif
  if !has_key(a:msg, 'event')
    return v:false
  endif
  if type( a:msg['event'] ) != v:t_string
    return v:false
  endif
  return v:true
endfunction

function! digitme#send( msg )
  if g:hitme#client_is_set != v:true
    return
  endif

  let l:isValid = digitme#validate( a:msg )
  if !l:isValid
    return v:false
  endif
  let a:msg['ts'] = localtime()
  if ch_status( s:channel ) == "open"
    call ch_sendexpr( s:channel, a:msg )
    return v:true
  else
    return v:false
  endif
endfunction

function! s:GetFileInfo ()
  let l:info = {}
  let l:info.filename = expand('%:t')
  let l:info.filetype = expand('%:e')
  return l:info
endfunction

call digitme#init()
augroup digitme
  autocmd!
  autocmd CursorMovedI * :call digitme#ping()
  autocmd BufEnter * :call digitme#bufenter()
  autocmd BufLeave * :call digitme#bufleave()
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
