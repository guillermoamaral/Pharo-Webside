Extension { #name : #RBMethodProtocolChange }

{ #category : #'*Webside' }
RBMethodProtocolChange >> fromWebsideJson: json [

	| method |
	super fromWebsideJson: json.
	source ifNil: [ 
		method := self changeClass >> selector.
		method ifNotNil: [ source := method sourceCode ] ]
]

{ #category : #'*Webside' }
RBMethodProtocolChange class >> websideType [

	^ 'ClassifyMethod'
]
