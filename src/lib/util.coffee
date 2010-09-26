# -*- Mode: coffee; tab-width: 2 -*-

exports.randpick = (arr) ->
  return null unless arr.length > 0
  index = Math.floor(Math.random()*arr.length)
  arr[index]