window.HG ?= {}

class HG.Tea extends HG.Beverage
	constructor: (price, sort) ->
		super price
		@_sort = sort

	getSort: ->
		console.log @_sort