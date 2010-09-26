# -*- Mode: coffee; tab-width: 2 -*-

path = require 'path'
Bot = require './lib/bot'

opts =
  plugin_dir: path.join(__dirname, 'lib/plugins')
  server: 'localhost',
  nick: 'memebot',
  channels: ['#test']

bot = new Bot opts
bot.load_plugin 'about'
bot.load_plugin 'control'
bot.load_plugin 'linuxoutlaws'
bot.connect()