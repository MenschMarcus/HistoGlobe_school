
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
		return @_tail if index == @_length - 1
		tmpIndex = 0
		tmpNode = @_head
		while tmpIndex < index
			tmpNode = tmpNode.next
			tmpIndex++
		tmpNode

	getLength : -> @_length

	insertAfter : (id, data) ->
		node =
			nodeData: data
			prev: null
			next: null
		tmpIndex = 0
		tmpNode = @_head
		while tmpIndex < id
			tmpNode = tmpNode.next
			tmpIndex++
		after = tmpNode.next
		tmpNode.next = node
		node.prev = tmpNode
		node.next = after
		after.prev = node
		@_length++

	remove : (index) ->
		if index >= 0 or index < @_length
			if index == 0
				@_head = @_head.next
				if @_length > 1
					@_head.prev = null
			else
				if index == @_length - 1
					@_tail = @_tail.prev
					@_tail.next = null
				else
				    tmpIndex = 0
				    tmpNode = @_head
				    while tmpIndex < index
					    tmpNode = tmpNode.next
					    tmpIndex++
				    tmpNode.prev.next = tmpNode.next
				    tmpNode.next.prev = tmpNode.prev
			@_length--



