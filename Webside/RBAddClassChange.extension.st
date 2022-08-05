Extension { #name : #RBAddClassChange }

{ #category : #'*Webside' }
RBAddClassChange >> fromWebsideJson: json [

	| superclass |
	super fromWebsideJson: json.
	category := json at: 'package' ifAbsent: [ 'Undefined' ].
	definition := json at: 'definition' ifAbsent: [ 
		              superclass := json at: 'superclass'.
		              superclass , ' subclass: ' , className printString
		              ,
		              ' instanceVariableNames: '''' classVariableNames: '''' poolDictionaries: '''' category: #'
		              , category ].
	(definition includesSubstring: 'category:') ifFalse: [ 
		definition := definition , ' category: #' , category ].
    msg := (OpalCompiler new noPattern: true; parse: definition).
	className := msg arguments first value asString   
        
        
     
]
