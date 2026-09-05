return {

  {
    'echasnovski/mini.animate',
    event = 'VeryLazy',
    config = function()
      require('mini.animate').setup({
        cursor = {
          enable = true,
          timing = require('mini.animate').gen_timing.linear({ duration = 100, unit = 'total' }),
        },
        scroll = {
          enable = false,
        },
        resize = {
          enable = false,
        },
        open = {
          enable = false,
        },
        close = {
          enable = false,
        },
      })
    end
  },

  {
    'rainbowhxch/beacon.nvim',
    event = 'VeryLazy',
    config = function()
      vim.g.beacon_size = 40
      vim.g.beacon_minimal_jump = 10
      vim.g.beacon_shrink = 1
      vim.g.beacon_timeout = 500
    end
  },
}
