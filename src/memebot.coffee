# -*- Mode: coffee; tab-width: 2 -*-

fs = require 'fs'
sys = require 'sys'
path = require 'path'
Bot = require './lib/bot'

opts = ->
  data = fs.readFileSync path.join(__dirname, 'config', 'common.json')
  return JSON.parse(data)

try
  bot = Bot::run opts
catch error
  sys.print "error: #{error}\n"



