function! BQNEvalLine()
    return luaeval(
          \ 'require("bqn").repl.eval(_A[1] - 1, _A[1])',
          \ [line(".")])
endfunction

function! BQNEvalRange() range
    return luaeval(
          \ 'require("bqn").repl.eval(_A[1] - 1, _A[2])',
          \ [a:firstline, a:lastline])
endfunction

function! BQNConstantEval() range
  return luaeval(
          \ 'vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"},  {command=[[lua if vim.bo.filetype == "bqn" then require("bqn").repl.eval() end]] })')
endfunction

function! BQNClearAfterLine()
    return luaeval(
          \ 'require("bqn").repl.clear(_A[1] - 1, -1)',
          \ [line(".")])
endfunction

function! BQNClearRange()
    return luaeval(
          \ 'require("bqn").repl.clear(_A[1] - 1, _A[2])',
          \ [a:firstline, a:lastline])
endfunction

function! BQNStartRepl()
    return luaeval(
          \ 'require("bqn").repl.ensure_repl_exists()',
          \ [a:firstline, a:lastline])
endfunction

hi link bqnoutok Comment
hi link bqnouterr Error

command! BQNEvalLine call BQNEvalLine()
command! -range BQNEvalRange <line1>,<line2>call BQNEvalRange()
command! BQNEvalFile :lua require("bqn").repl.eval(0, -1, true)

command! BQNClearAfterLine call BQNClearAfterLine()
command! BQNConstantEval call BQNConstantEval()
command! -range BQNClearRange <line1>,<line2>call BQNClearRange()
command! BQNClearFile :lua require("bqn").repl.clear(0, -1)

nnoremap <silent> <plug>(bqn_eval_line) :BQNEvalLine<CR>
xnoremap <silent> <plug>(bqn_eval_range) :BQNEvalRange<CR>
nnoremap <silent> <plug>(bqn_eval_file) :BQNEvalFile<CR>

nnoremap <silent> <plug>(bqn_clear_after_line) :BQNClearAfterLine<CR>
xnoremap <silent> <plug>(bqn_clear_range) :BQNClearRange<CR>
nnoremap <silent> <plug>(bqn_clear_file) :BQNClearFile<CR>
nnoremap <silent> <plug>(bqn_constant_eval) :BQNConstantEval<CR>
nnoremap <silent> <plug>(start_repl) :BQNStartRepl<CR>
