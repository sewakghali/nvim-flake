---------------------------------------------------
-- Function to commit with a message
---------------------------------------------------
-- strip surrounding quotes
local function strip_quotes(str)
  return str:gsub("^[\"']", ""):gsub("[\"']$", "")
end

-- commit with optional quotes or interactive prompt
local function git_commit(args)
  local message = nil

  if args.fargs and #args.fargs > 0 then
    message = table.concat(args.fargs, " ")
    message = strip_quotes(message)
  else
    -- Prompt interactively if no arguments
    message = vim.fn.input("Git commit message: ")
  end

  if message == "" then
    print("Commit cancelled: no message provided")
    return
  end

  -- Run git commit
  local cmd = 'git commit -m "' .. message .. '"'
  local result = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    print("Committed: " .. message)
  else
    print("Git commit failed:\n" .. result)
  end
end

-- Create the :Gc command, accepting multiple words
vim.api.nvim_create_user_command("Gc", git_commit, { nargs = "*" })
