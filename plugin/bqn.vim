function! BQNEvalTillLine()
    return luaeval(
          \ 'require("bqn").eval(0, _A[1], true)',
          \ [line(".")])
endfunction

function! BQNEvalRange() range
    return luaeval(
          \ 'require("bqn").eval(_A[1] - 1, _A[2], true)',
          \ [a:firstline, a:lastline])
endfunction

function! BQNClearAfterLine()
    return luaeval(
          \ 'require("bqn").clear(_A[1] - 1, -1)',
          \ [line(".")])
endfunction

function! BQNClearRange()
    return luaeval(
          \ 'require("bqn").clear(_A[1] - 1, _A[2])',
          \ [a:firstline, a:lastline])
endfunction

function! BQNYankResult()
    return luaeval(
          \ 'require("bqn").yank(_A[1] - 1, _A[2])',
          \ [a:firstline, a:lastline])
endfunction

hi link bqnoutok Comment
hi link bqnouterr Error

command! BQNEvalTillLine call BQNEvalTillLine()
command! -range BQNEvalRange <line1>,<line2>call BQNEvalRange()
command! BQNEvalFile :lua require("bqn").eval(0, -1, true)

command! BQNClearAfterLine call BQNClearAfterLine()
command! -range BQNClearRange <line1>,<line2>call BQNClearRange()
command! BQNClearFile :lua require("bqn").clear(0, -1)

nnoremap <silent> <plug>(bqn_eval_till_line) :BQNEvalTillLine<CR>
xnoremap <silent> <plug>(bqn_eval_range) :BQNEvalRange<CR>
nnoremap <silent> <plug>(bqn_eval_file) :BQNEvalFile<CR>

nnoremap <silent> <plug>(bqn_clear_after_line) :BQNClearAfterLine<CR>
xnoremap <silent> <plug>(bqn_clear_range) :BQNClearRange<CR>
nnoremap <silent> <plug>(bqn_clear_file) :BQNClearFile<CR>
nnoremap <silent> <plug>(bqn_yank_result) :BQNYankResult<CR>
