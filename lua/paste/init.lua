local M = {}

-- Define the function to call the Python script
M.save_clipboard_image = function()
	-- Prompt the user for an output path
	local output_path = vim.fn.input("Enter output path for image: ", "output.png")

	-- Execute the Python script using the output path provided
	local cmd = string.format("python3 ../../scripts/paste.py %s", output_path)
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
