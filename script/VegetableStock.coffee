window.HG ?= {}

class HG.VegetableStock extends HG.Beverage
	constructor: (price, ingredients) ->
		super price
		@_ingredients = ingredients

	getIngredients: ->
		console.log @_ingredients