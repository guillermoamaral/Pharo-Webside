Class {
	#name : 'WebsideIndexAccessor',
	#superclass : 'Object',
	#instVars : [
		'object',
		'accessor',
		'start',
		'end'
	],
	#category : 'Webside-Base',
	#package : 'Webside',
	#tag : 'Base'
}

{ #category : 'accessing' }
WebsideIndexAccessor >> accessor [

	^ accessor
]

{ #category : 'accessing' }
WebsideIndexAccessor >> accessor: anObject [

	accessor := anObject
]

{ #category : 'accessing' }
WebsideIndexAccessor >> at: index [

	^ object perform: accessor with: index
]

{ #category : 'enumerating' }
WebsideIndexAccessor >> do: aBlock [

	| element |
	start to: end do: [ :i |
		element := self at: i.
		aBlock value: element ]
]

{ #category : 'accessing' }
WebsideIndexAccessor >> end [

	^ end
]

{ #category : 'accessing' }
WebsideIndexAccessor >> end: anObject [

	end := anObject
]

{ #category : 'initialization' }
WebsideIndexAccessor >> initialize [

	super initialize.
	accessor := #at:.
	start := 1
]

{ #category : 'accessing' }
WebsideIndexAccessor >> object [

	^ object
]

{ #category : 'accessing' }
WebsideIndexAccessor >> object: anObject [

	object := anObject.
	object ifNotNil: [ end := object size ]
]

{ #category : 'accessing' }
WebsideIndexAccessor >> start [

	^ start
]

{ #category : 'accessing' }
WebsideIndexAccessor >> start: anObject [

	start := anObject
]
