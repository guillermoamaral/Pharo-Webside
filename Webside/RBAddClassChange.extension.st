Extension { #name : #RBAddClassChange }

{ #category : #'*Webside' }
RBAddClassChange >> fromWebsideJson: json [

	| superclass doit |
	super fromWebsideJson: json.
	category := json at: 'package' ifAbsent: [ 'Undefined' ].
	definition := json at: 'definition' ifAbsent: [ 
		              superclass := json at: 'superclass'.
		              superclass , ' subclass: ' , className printString
		              ,
		              ' instanceVariableNames: '''' classVariableNames: '''' poolDictionaries: '''' category: #'
		              , category ].
	doit := OpalCompiler new
		       noPattern: true;
		       parse: definition.
	className := doit body statements first value arguments first value asString
]
