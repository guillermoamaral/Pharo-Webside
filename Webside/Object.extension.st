Extension { #name : 'Object' }

{ #category : '*Webside' }
Object >> asWebsideJson [

	| printed |
	printed := [ self printString ]
		           on: Error
		           do: [
		           'Error while printing ' , self class name , ' instance' ].
	^ NeoJSONObject new
		  at: 'class' put: self class name;
		  at: 'hasNamedSlots' put: self class isPointers;
		  at: 'hasIndexedSlots' put: self class isVariable;
		  at: 'size' put: (self class isVariable
				   ifTrue: [ self size ]
				   ifFalse: [ 0 ]);
		  at: 'printString' put: printed;
		  yourself
]

{ #category : '*Webside' }
Object >> websideIndexAccessor [

	^ WebsideIndexAccessor new
		  object: self;
		  yourself
]

{ #category : '*Webside' }
Object >> websideViews [

	^#()
]
