Extension { #name : #RBAddClassChange }

{ #category : #'*Webside' }
RBAddClassChange >> fromWebsideJson: json [

	| doit |
	super fromWebsideJson: json.
	category := json at: 'package' ifAbsent: [ 'Undefined' ].
	json at: 'superclass' ifPresent: [ :n | superclassName := n ].
	instanceVariableNames := json
		                         at: 'instanceVariables'
		                         ifAbsent: [ #(  ) ].
	classVariableNames := json at: 'classVariables' ifAbsent: [ #(  ) ].
	poolDictionaryNames := json
		                       at: 'poolDictionaries'
		                       ifAbsent: [ #(  ) ].
	definition := json at: 'definition' ifAbsent: nil.
	(definition isNil and: [ superclassName notNil ]) ifTrue: [
		definition := String streamContents: [ :s |
			              s
				              nextPutAll: superclassName;
				              nextPutAll: ' subclass: ';
				              nextPutAll: className printString;
				              nextPutAll: ' instanceVariableNames: '''.
			              instanceVariableNames
				              do: [ :n | s nextPutAll: n ]
				              separatedBy: [ s space ].
			              s nextPutAll: ''' classVariableNames: '''.
			              classVariableNames
				              do: [ :n | s nextPutAll: n ]
				              separatedBy: [ s space ].
			              s nextPutAll: ''' poolDictionaries: '''.
			              classVariableNames
				              do: [ :n | s nextPutAll: n ]
				              separatedBy: [ s space ].
			              s
				              nextPutAll: ''' category: #';
				              nextPutAll: category ] ].
	doit := OpalCompiler new
		        noPattern: true;
		        parse: definition.
	className := doit body statements first value arguments first value
		             asString
]
