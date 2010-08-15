# -*- Mode: coffee; tab-width: 2 -*-

Plugin = require 'lib/plugin'

module.exports = ->
  p = new Plugin {name: 'dummy', path: __filename}
  p

