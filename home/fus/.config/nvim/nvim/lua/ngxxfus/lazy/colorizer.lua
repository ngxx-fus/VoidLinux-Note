return {
	{
	  "NvChad/nvim-colorizer.lua",
	  event = { "BufReadPre", "BufNewFile" },
	  config = function()
	    require("colorizer").setup({
	      filetypes = {
	        "*",
	        rasi = {
	          rgb_fn = true,    -- still needed
	          hsl_fn = true,
	          names = true,
	        },
	      },
	      user_default_options = {
	        css = true,
	        rgb_fn = true,
	        hsl_fn = true,
	        tailwind = false,
	        mode = "foreground",
	      },
	    })
	    -- Optional: auto-attach
	    vim.cmd [[autocmd BufReadPost,BufNewFile *.rasi ColorizerAttachToBuffer]]
	  end,
	},
}

