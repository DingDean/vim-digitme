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
  let g:digitme#clientUrl = get(g:, 'digitme#clientUrl', "localhost:8763")
  let g:digitme#client = get(g:, 'digitme#client', 'digitme-cli')
  let g:digitme#tomatoState = 1 "idle
  if executable(g:digitme#client) == 0
    echom "DigitalMe Client is not installed"
    return
  endif

  "check client is running
  let isRunning = system(g:digitme#client . ' check')
  if isRunning == 0
    echom "DigitalMe Client is not running, starting now"
    system(g:digitme#client . ' start')
    if system(g:digitme#client . ' check' == 0)
      echom "Failed to start DigitalMe Client"
      return
    endif
  endif

  call s:OpenChannel()
  call digitme#tomatoInit()

  augroup digitme
    autocmd!
    autocmd CursorMovedI * :call digitme#ping()
    autocmd BufEnter * :call digitme#bufenter()
    autocmd BufLeave * :call digitme#bufleave()
  augroup END

  command DigitTomatoStart :call digitme#tomatoStart()
  command DigitTomatoPause :call digitme#tomatoPause()
  command DigitTomatoAbandon :call digitme#tomatoAbandon()
endfunction

" Ping Client When Cursor Moved
function! digitme#ping()
  " TODO: 2018-05-16 Benchmark and Improve
  " eventhough lag is not noticed,
  " still ping method should be benchmarked
  let l:msg = {'event': 'ping'}
  if digitme#canSend(l:msg) == v:true
    call ch_sendexpr( s:channel, l:msg )
  endif
endfunction

function! digitme#bufenter ()
  let l:msg = {'event': 'bufEnter'}
  let l:msg.data = s:GetFileInfo()
  if digitme#canSend( l:msg ) == v:true
    call ch_sendexpr( s:channel, l:msg )
  endif
endfunction

function! digitme#bufleave ()
  let l:msg = {'event': 'bufLeave'}
  let l:msg.data = s:GetFileInfo()
  if digitme#canSend( l:msg ) == v:true
    call ch_sendexpr( s:channel, l:msg )
  endif
endfunction

function! digitme#closeCallback(channel)
  echom "DigitalMe channel is closed"
  let g:digitme#client_is_set = v:false
endfunction

function! s:OpenChannel()
  let s:channel = ch_open(g:digitme#clientUrl,
        \ {"close_cb": "digitme#closeCallback"})
  if ch_status(s:channel) == "fail"
    echom "Failed to establish digitalme channel"
    let g:digitme#client_is_set = v:false
  endif
  let g:digitme#client_is_set = v:true
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

function! digitme#canSend( msg )
  if g:digitme#client_is_set != v:true
    return
  endif

  let l:isValid = digitme#validate( a:msg )
  if !l:isValid
    return v:false
  endif
  let a:msg['ts'] = localtime()
  if ch_status( s:channel ) == "open"
    return v:true
  else
    return v:false
  endif
endfunction

" Query Tomato Status
function! digitme#tomatoInit()
  let l:msg = {'event': 'tomatoQuery'}
  if digitme#canSend( l:msg ) == v:true
    call ch_sendexpr( s:channel, l:msg,
          \ {'callback': 'digitme#tomatoInitCallback'} )
  endif
endfunction

function! digitme#tomatoInitCallback(channel, msg)
  let l:state = a:msg.state
  let l:tEnd = a:msg.tEnd

  let g:digitme#tomatoState = l:state
  if l:tEnd != 0
    let g:digitme#tomatoEndTime = a:tEnd
  endif
endfunction

" Start the default timer with 25m interval
function! digitme#tomatoStart()
  echom 'tomato start'
  if g:digitme#tomatoState == 0
    echom 'tomato started'
    return
  endif
  let l:msg = {'event': 'tomatoStart'}
  let l:msg.data = {'name': 'default'}
  if digitme#canSend(l:msg) == v:true
    call ch_sendexpr( s:channel, l:msg,
          \ {'callback':'digitme#tomatoStartCallback'})
  endif
endfunction

function! digitme#tomatoStartCallback(channel, msg)
  if a:msg.ok == 0
    echom 'starting timer'
    let g:digitme#tomatoState = 0 "active
    let g:digitme#tomatoEndTime = a:msg.tEnd
  endif
endfunction

function! digitme#tomatoPause()
  let l:msg = {'event': 'tomatoPause'}
  if digitme#canSend(l:msg) == v:true
    call ch_sendexpr( s:channel, l:msg,
          \ {'callback': 'digitme#tomatoPauseCallback'})
  endif
endfunction

function! digitme#tomatoPauseCallback(channel, msg)
  if a:msg.ok == 0
    echom 'timer paused'
    let g:digitme#tomatoState = 2 "paused
  endif
endfunction

" Called by digitme client automatically when timer is finished
function! digitme#tomatoFinish()
  echom "timer finished"
  let g:digitme#tomatoState = 1 "idle
endfunction

function! digitme#tomatoAbandon()
  let l:msg = {'event': 'tomatoAbandon'}
  if digitme#canSend(l:msg) == v:true
    call ch_sendexpr( s:channel, l:msg,
          \ {'callback': 'digitme#tomatoAbandonCallback'})
  endif
endfunction

function! digitme#tomatoAbandonCallback(channel, msg)
  if a:msg.ok == 0
    echom 'timer abandoned'
    let g:digitme#tomatoState = 1 "idle
  endif
endfunction

function! digitme#tomatoGet()
  if g:digitme#tomatoState == 0
    let l:ts = g:digitme#tomatoEndTime
    if l:ts < localtime() * 1000
      return ''
    endif
    return printf('工作中[%d]', digitme#getRemainTime( l:ts ) )
  endif
  if g:digitme#tomatoState == 1
    return '-'
  endif
  return '暂停中'
endfunction

function! digitme#getRemainTime(ts)
  let diff = a:ts - localtime() * 1000
  if diff < 0
    return ''
  endif
  let remain = diff / 60000
  if (remain > 0)
    return printf('%d m', remain)
  else
    return printf('%d s', (remain/1000) % 60)
endfunction

function! s:GetFileInfo ()
  let l:info = {}
  let l:info.filename = expand('%:t')
  let l:info.filetype = expand('%:e')
  return l:info
endfunction

call digitme#init()

let &cpo = s:save_cpo
unlet s:save_cpo
