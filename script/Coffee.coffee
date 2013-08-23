window.HG ?= {}

class HG.Coffee extends HG.Beverage
	constructor: (price, beans) ->
		super price
		@_beans = beans

	getBeans: ->
		console.log @_beans
