local M = {}

-- Function to get the absolute path of the current buffer (the file being edited)
M.get_current_buffer_path = function()
	return vim.api.nvim_buf_get_name(0)
end

-- Function to check if the provided path is absolute
M.is_absolute_path = function(path)
	return vim.fn.isdirectory(vim.fn.fnamemodify(path, ":p")) == 1
end

M.save_clipboard_image = function()
	-- Get the current buffer's path (absolute)
	local buffer_path = M.get_current_buffer_path()

	-- Get the directory of the current buffer
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":p:h")

	-- Prompt the user for an output path
	local user_output_path = vim.fn.input("Enter output path for image (relative or absolute): ", "output.png")

	-- Determine if the provided path is absolute or relative
	local output_path = ""
	if M.is_absolute_path(user_output_path) then
		-- If it's an absolute path, use it directly
		output_path = user_output_path
	else
		-- If it's a relative path, resolve it relative to the current buffer's directory
		output_path = buffer_dir .. "/" .. user_output_path
	end

	-- Construct the path to the Python script (relative to this Lua file)
	local lua_dir = debug.getinfo(1, "S").source:sub(2)
	local lua_abs_dir = vim.fn.fnamemodify(lua_dir, ":p:h")

	-- Ensure correct concatenation of the path
	local script_path = lua_abs_dir .. "/../../scripts/paste.py"

	-- Execute the Python script using the constructed script path and output path
	local cmd = string.format("python3 %s %s", script_path, output_path)
	local result = vim.fn.system(cmd)

	-- Notify the user of the result
	if vim.v.shell_error == 0 then
		vim.api.nvim_out_write("Image saved successfully to " .. output_path .. "\n")
	else
		vim.api.nvim_err_writeln("Failed to save image: " .. result)
	end
end

--- Setup function to set the keybinding for the command
---@param _ table
function M.setup(_)
	-- Define the command to call the function
	vim.api.nvim_create_user_command("SaveClipboardImage", M.save_clipboard_image, {})
	-- Set the keybinding for the command
	vim.api.nvim_set_keymap("n", "<leader>pi", ":SaveClipboardImage<CR>", { noremap = true, silent = true })
end

return M
