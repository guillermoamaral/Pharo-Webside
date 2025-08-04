Extension { #name : 'NECGlobalEntry' }

{ #category : '*Webside' }
NECGlobalEntry >> websideType [

	| global |
	global := Smalltalk at: contents ifAbsent: [  ].
	(global notNil and: [ global isClass ]) ifTrue: [ ^ 'class' ].
	^ 'variable'
]
