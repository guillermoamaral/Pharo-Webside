Extension { #name : #RBAddClassChange }

{ #category : #'*Webside' }
RBAddClassChange >> fromWebsideJson: json [
	| ast |
	super fromWebsideJson: json.
	definition := json at: 'definition' ifAbsent: ''.
	(definition includesSubstring: 'category:') 
		ifFalse: [ definition := definition , ' category: #Undefined' ].
	ast := RBParser parseExpression: definition onError: nil.
	ast ifNil: [ ^ self ].
	superclassName := ast receiver name asSymbol.
	instanceVariableNames := self
		namesIn:
			(ast arguments
				at: (ast keywords indexOf: 'instanceVariableNames:')
				ifAbsent: '') value.
	classVariableNames := self
		namesIn:
			(ast arguments
				at: (ast keywords indexOf: 'classVariableNames:')
				ifAbsent: '') value.
	poolDictionaryNames := self
		namesIn:
			(ast arguments
				at: (ast keywords indexOf: 'poolDictionaries:')
				ifAbsent: '') value.
	category := self
		namesIn:
			(ast arguments at: (ast keywords indexOf: 'category:') ifAbsent: '')
				value
]

{ #category : #'*Webside' }
RBAddClassChange class >> webSTType [
	^ 'ClassDefinition'
]
