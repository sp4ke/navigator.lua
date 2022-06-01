local M = {}
local ListView = require('guihua.listview')
local TextView = require('guihua.textview')
local util = require('navigator.util')
local log = util.log
local trace = require('navigator.util').trace
local api = vim.api
local active_list_view -- only one listview at a time

function M.new_list_view(opts)
  -- log(opts)
  local config = require('navigator').config_values()

  if active_list_view ~= nil then
    trace(active_list_view)
    local winnr = active_list_view.win
    local bufnr = active_list_view.buf

    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and winnr and vim.api.nvim_win_is_valid(winnr) then
      log('list view already present')
      return active_list_view
    end
  end
  local items = opts.items

  opts.min_width = opts.min_width or 0.3
  opts.min_height = opts.min_height or 0.3

  opts.height_ratio = config.height
  opts.width_ratio = config.width
  opts.preview_height_ratio = _NgConfigValues.preview_height or 0.3
  opts.preview_lines = _NgConfigValues.preview_lines
  if opts.rawdata then
    opts.data = items
  else
    opts.data = require('navigator.render').prepare_for_render(items, opts)
  end
  opts.border = _NgConfigValues.border or 'shadow'
  if vim.fn.hlID('TelescopePromptBorder') > 0 then
    opts.border_hl = 'TelescopePromptBorder'
  end
  if not items or vim.tbl_isempty(items) then
    log('empty data return')
    return
  end

  opts.transparency = _NgConfigValues.transparency
  if #items >= _NgConfigValues.lines_show_prompt then
    opts.prompt = true
  end

  opts.external = _NgConfigValues.external
  opts.preview_lines_before = 3
  log(opts)
  active_list_view = require('guihua.gui').new_list_view(opts)
  return active_list_view
end

function M.select(items, opts, on_choice)
  return
end

return M

-- Doc

--[[
    -- each item should look like this
    -- update if API changes
    {
      call_by = { <table 1> },
      col = 40,
      display_filename = "./curry.js",
      filename = "/Users/username/lsp_test/js/curry.js",
      lnum = 4,
      range = {
        end = {
          character = 46,
          line = 3  -- note: C index
        },
        start = {
          character = 39,
          line = 3
        }
      },
      rpath = "js/curry.js",
      text = "      (sum, element, index) => (sum += element * vector2[index]),",
      uri = "file:///Users/username/lsp_test/js/curry.js"
    }
  --]]

-- on move item:
--[[

 call_by = { {
      kind = " ",
      node_scope = {
        end = {
          character = 1,
          line = 7
        },
        start = {
          character = 0,
          line = 0
        }
      },
      node_text = "curriedDot",
      type = "var"
    } },
  col = 22,
  display_filename = "./curry.js",
  filename = "/Users/username/lsp_test/js/curry.js",
  lnum = 4,
  range = {
    end = {
      character = 26,
      line = 3
    },
    start = {
      character = 21,
      line = 3
    }
  },
  rpath = "js/curry.js",
  text = "    4:        (sum, element, index) => (sum += element * vector     curriedDot()",
  uri = "file:///Users/username/lsp_test/js/curry.js"
--
]]
