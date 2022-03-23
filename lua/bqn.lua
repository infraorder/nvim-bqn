local ns = vim.api.nvim_create_namespace('bqnout')

vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"},  {
  command=[[lua if vim.bo.filetype == "bqn" then require("bqn").eval() end]] })

function execute_command(command)
    local tmpfile = os.tmpname()
    local exit = os.execute(command .. ' > ' .. tmpfile .. ' 2> ' .. tmpfile .. '.err')

    local stdout_file = io.open(tmpfile, "r")
    local stdout = stdout_file:read("*all")

    local stderr_file = io.open(tmpfile .. '.err', "r")
    local stderr = stderr_file:read("*all")

    stdout_file:close()
    stderr_file:close()

    return exit, stdout, stderr
end

function is_balanced(s)
  --Lua pattern matching has a 'balanced' pattern that matches sets of balanced characters.
  --Any two characters can be used.
  return s:gsub('%b{}','')=='' and true or false
end

function clear(start, stop)
  vim.diagnostic.reset(ns, 0)
  vim.api.nvim_buf_clear_namespace(0, ns, start, stop)
  vim.api.nvim_command("redraw!")
end

function eval(start, stop)
  local start = start
  local stop = stop

  if start == nil then
    start = 0
  end
  if stop == nil then
    stop = vim.api.nvim_buf_line_count(0)
  end

  local program = table.concat(
    vim.api.nvim_buf_get_lines(0, start, stop, true), 
    "\n")
  
  -- while is_balanced(program) ~= true do
  --   program = program .. table.concat(
  --     vim.api.nvim_buf_get_lines(0, stop, stop + 1, true), 
  --     "\n")
  --   print(program)
  --   stop = stop + 1
  -- end

  -- Escape input for shell
  program = string.gsub(program, '"', '\\"')
  program = string.gsub(program, '`', '\\`')

  print(is_balanced(program))

  local cmd = 'BQN -p "' .. program .. '"'
  local exit, stdout, stderr = execute_command(cmd)

  local error = nil
  local output = nil
  local hl = 'bqnoutok'
  if exit ~= 0 then
    local message = stderr:match("^Error: (.-)\n")
    hl = 'bqnouterr'
    local line_number = tonumber(stderr:match(":(%d+):"))
    if (line_number == nil) then
      line_number = 0
    end

    error = {message=message, lnum=line_number + start - 1}
    output = stderr
  else
    output = stdout
  end

  local lines = {}
  for line in output:gmatch("[^\r\n]+") do
      table.insert(lines, {{' ' .. line, hl}})
  end

  -- Reset and show diagnostics
  vim.diagnostic.reset(ns, 0)
  if error ~= nil and error.lnum ~= nil then
    vim.diagnostic.set(ns, 0, {{
      message=error.message,
      lnum=error.lnum,
      col=0,
      severity=vim.diagnostic.severity.ERROR,
      source='BQN',
    }})
  end

  local cto = stop
  while cto < vim.api.nvim_buf_line_count(0) do
    local line = vim.api.nvim_buf_get_lines(0, cto, cto + 1, true)[1]
    if #line ~= 0 and line:find("^%s*#") == nil then break end
    cto = cto + 1
  end

  vim.api.nvim_buf_clear_namespace(0, ns, stop - 1, cto)
  vim.api.nvim_buf_set_extmark(0, ns, stop -1, 0, {
    virt_lines=lines
  })

  vim.api.nvim_command("redraw!")
end

return {
    eval = eval,
    clear = clear,
}
