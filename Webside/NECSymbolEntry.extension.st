Extension { #name : 'NECSymbolEntry' }

{ #category : '*Webside' }
NECSymbolEntry >> websideType [
	| global |
	global := Smalltalk at: contents ifAbsent: [].
	(global notNil and:[global isClass ]) ifTrue: [ ^'class' ].  
	^ 'variable'
]
