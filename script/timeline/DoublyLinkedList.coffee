
window.HG ?= {}

class HG.DoublyLinkedList

	constructor: () ->
		@_length = 0
		@_head = null
		@_tail = null

	addFirst : (data) ->
		node =
			nodeData: data
			prev: null
			next: null
		if @_length == 0
			@_head = node
			@_tail = node
		else
			@_head.prev = node
			node.next = @_head
			@_head = node
		@_length++

	addLast : (data) ->
		node =
			nodeData: data
			prev: null
			next: null
		if @_length == 0
			@_head = node
			@_tail = node
		else
			@_tail.next = node
			node.prev = @_tail
			@_tail = node
		@_length++

	get : (index) ->
		return @_head if index == 0
		return @_tail if index >= @_length
		tmpIndex = 0
		tmpNode = @_head
		while tmpIndex < index
			tmpNode = tmpNode.next
			tmpIndex++
		tmpNode

	getLength : -> @_length

	insert : (index, data) ->
		if index == 0
			addFirst(data)
		if index >= _length
			addLast(data)
		node =
			nodeData: data
			prev: null
			next: null
		tmpIndex = 0
		tmpNode = @_head
		while tmpIndex < index
			tmpNode = tmpNode.next
			tmpIndex++
		node.next = tmpNode.next
		tmpNode.next.prev = node
		tmpNode.next = node
		node.prev = tmpNode


