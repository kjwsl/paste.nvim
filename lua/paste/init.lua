local M = {}

-- Function to get the absolute path of the current buffer (the file being edited)
M.get_current_buffer_path = function()
	return vim.api.nvim_buf_get_name(0)
end

-- Function to check if the provided path is absolute
M.is_absolute_path = function(path)
	return vim.fn.isdirectory(vim.fn.fnamemodify(path, ":p")) == 1
end

M.get_script_dir = function()
	local lua_path = debug.getinfo(1, "S").source:sub(2)
	return vim.fn.fnamemodify(lua_path, ":p:h")
end

-- Define the function to call the Python script
M.save_clipboard_image = function()
	local buffer_path = M.get_current_buffer_path()
	local buffer_dir = vim.fn.fnamemodify(buffer_path, ":p:h")
	local lua_path = M.get_script_dir()
	local script_path = lua_path .. "../../scripts/paste.py"
	-- Prompt the user for an output path
	local user_output_path = vim.fn.input("Enter output path for image: ", "output.png")

	local output_path = ""
	if M.is_absolute_path(user_output_path) then
		output_path = user_output_path
	else
		output_path = buffer_dir .. "/" .. user_output_path
	end

	-- Execute the Python script using the output path provided
	local cmd = string.format("python3 %s %s", script_path, output_path)
	local result = vim.fn.system(cmd)

	-- Notify the user of the result
	if vim.v.shell_error == 0 then
		vim.api.nvim_out_write("Image saved successfully to " .. output_path .. "\n")
	else
		vim.api.nvim_err_writeln("Failed to save image: " .. result)
	end
end

---Setup the keymap and command for saving clipboard images
---@param _ table
function M.setup(_)
	-- Define the command to call the function
	vim.api.nvim_create_user_command("SaveClipboardImage", M.save_clipboard_image, {})

	-- Set the keymap for the command
	vim.api.nvim_set_keymap("n", "<leader>ci", ":SaveClipboardImage<CR>", { noremap = true, silent = true })
end

return M
