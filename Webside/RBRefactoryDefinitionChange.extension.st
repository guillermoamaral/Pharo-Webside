Extension { #name : #RBRefactoryDefinitionChange }

{ #category : #'*Webside' }
RBRefactoryDefinitionChange class >> acceptsWebsideJson: json [
	| ast context |
	(super acceptsWebsideJson: json) ifFalse: [ ^false ].
	ast := RBParser
		parseExpression: (json at: 'definition' ifAbsent: '')
		onError: nil.
	ast ifNil: [ ^false ].
	context := SmallDictionary new.
	^self definitionPatterns
				anySatisfy: [ :pattern | 
					((RBParser parseRewriteExpression: pattern)
						match: ast
						inContext: context empty)]
]

{ #category : #'*Webside' }
RBRefactoryDefinitionChange >> asWebsideJson [
	^super asWebsideJson
		at: 'sourceCode' put: self definition;
		yourself
]

{ #category : #'*Webside' }
RBRefactoryDefinitionChange >> fromWebsideJson: json [
	| ast context dictionary |
	super fromWebsideJson: json.
	definition := json at: 'definition'.
	ast := RBParser
		parseExpression: (json at: 'definition' ifAbsent: '')
		onError: nil.
	ast ifNil: [ ^ false ].
	context := SmallDictionary new.
	self class definitionPatterns
		do: [ :pattern | 
			((RBParser parseRewriteExpression: pattern)
				match: ast
				inContext: context empty)
				ifTrue: [ dictionary := SmallDictionary new.
					context
						keysAndValuesDo: [ :key :node | 
							dictionary
								at: key formattedCode
								put:
									(node isVariable
										ifTrue: [ node name ]
										ifFalse: [ node isLiteralNode
												ifTrue: [ node value ]
												ifFalse: [ node ] ]) ].
					self fillOutDefinition: dictionary ] ]
]
