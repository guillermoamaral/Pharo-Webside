Extension { #name : #Object }

{ #category : #'*Webside' }
Object >> asWebsideJson [
	^ NeoJSONObject new
		at: 'class' put: self class name;
		at: 'indexable' put: self class isVariable;
		at: 'size' put: self size;
		at: 'printString' put: self printString;
		yourself
]
