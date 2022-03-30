-- TODO make this better
--   currently lua's gsub expression '%b⟨⟩'
--   or any noon ascii character for that matter is not working
is_balanced = function(s)
  local sub = s:gsub('%b{}','')
  return util.is_empty(sub:match("{")) 
    and util.is_empty(sub:gsub('⟨', '{')
      :gsub('⟩', '}')
      :gsub('%b{}', '')
      :match("{"))
    and math.fmod(count_quote(s), 2) == 0
end

function count_quote(s)
  return select(2, s:gsub('"', ''))
end

util = {}
util.get_port_number = function()
  local exec = assert(io.popen([[netstat -aln | awk '
    $6 == "LISTEN" {
      if ($4 ~ "[.:][0-9]+$") {
        split($4, a, /[:.]/);
        port = a[length(a)];
        p[port] = 1
      }
    }
    END {
      for (i = 3000; i < 65000 && p[i]; i++){};
      if (i == 65000) {exit 1};
      print i
    }
  ']]))
  return tonumber(exec:read('*all'))
end

util.get_buffer_name = function()
  return vim.fn.expand('%:p'):gsub("^/", ""):gsub("/", ".")
end

util.is_empty = function(s) return s == nil or s == '' end

util.between = function(start, stop, line)
  return (start >= line.start and stop <= line.stop + 1)
end

util.parse = function(data)
  local head = table.remove(data, 1)
  head = head:match("(.*)#") or head

  local i = 0;
  return table.reduce(data, function(acc, line, k)
    i = i + 1
    if (util.is_empty(acc[#acc].data) or is_balanced(acc[#acc].data)) then
      if (not util.is_empty(line) and not util.is_empty(line:match("(.*)#") or line)) then
        table.insert(acc, {
          index = acc[#acc].index + 1,
          start = i,
          stop = i,
          data = line:match("(.*)#") or line
        })
      end
    else
      acc[#acc].stop = i
      acc[#acc].data = acc[#acc].data .. '\n' .. (line:match("(.*)#") or line)
    end
    return acc
  end, {{
    index = 0,
    start = i,
    stop = i,
    data = head
  }})
end

return util
