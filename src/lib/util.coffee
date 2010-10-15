# -*- Mode: coffee; tab-width: 2 -*-

rpad = (v, n, p) ->
  p ?= ' '
  s = v.toString()
  Array.prototype.join.call({length: Math.max(0, n - s.length) + 1}, p) + s

pad_date = (d) ->
  rpad d, 2, '0'

module.exports =
  randpick: (arr) ->
    return null unless arr.length > 0
    index = Math.floor(Math.random()*arr.length)
    arr[index]

  format_date: (d) ->
    [d.getFullYear(), d.getMonth(), d.getDate()].map(pad_date).join('-')

  format_time: (d) ->
    @format_date(d) + ' ' + [d.getHours(), d.getMinutes(), d.getSeconds()].map(pad_date).join(':')