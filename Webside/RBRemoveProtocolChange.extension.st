Extension { #name : #RBRemoveProtocolChange }

{ #category : #'*Webside' }
RBRemoveProtocolChange >> websideExecute [

	| category remotions changes |
	category := self changeClass organization protocolNamed: protocol.
	category isEmpty ifTrue: [ ^ super websideExecute ].
	remotions := category methodSelectors collect: [ :s |
		             RBRemoveMethodChange remove: s from: self changeClass ].
	changes := OrderedCollection withAll: remotions.
	changes add: self.
	(WebsideChangeError from: self)
		suggest:
			'Category is not empty. Do you want to remove all its methods?'
		withChanges: changes;
		signal
]

{ #category : #'*Webside' }
RBRemoveProtocolChange class >> websideType [

	^ 'RemoveCategory'
]
