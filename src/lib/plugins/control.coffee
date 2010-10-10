# -*- Mode: coffee; tab-width: 2 -*-

Plugin = require '../plugin'
sys = require 'sys'

plugin = (e, bot) ->
  [action, plugin] = e.matches.text[1..2]
  switch action
    when 'load' then bot.load_plugin plugin
    when 'unload' then bot.unload_plugin plugin
    when 'reload' then bot.reload_plugin plugin

module.exports = ->
  p = new Plugin {name: 'control'}
  p.command /plugin (load|unload|reload) (\w+)/, plugin
  p