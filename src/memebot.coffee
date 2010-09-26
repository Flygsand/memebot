# -*- Mode: coffee; tab-width: 2 -*-

require 'underscore'
fs = require 'fs'
sys = require 'sys'
path = require 'path'
Bot = require './lib/bot'

config = ->
  data = fs.readFileSync path.join(__dirname, 'config', 'common.json')
  defaults =
    plugin_dir: path.join(__dirname, 'lib/plugins')
  return _.extend({}, defaults, JSON.parse(data))

try
  bot = new Bot config()
  bot.load_plugin 'about'
  bot.load_plugin 'control'
  bot.load_plugin 'linuxoutlaws'
  bot.connect()
catch error
  sys.print "error: #{error}\n"



