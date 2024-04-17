Extension { #name : #RBRefactoryProtocolChange }

{ #category : #'*Webside' }
RBRefactoryProtocolChange >> asWebsideJson [
	^ super asWebsideJson
		at: 'category' put: protocol;
		yourself
]

{ #category : #'*Webside' }
RBRefactoryProtocolChange >> fromWebsideJson: json [
	super  fromWebsideJson: json.
	protocol := json at: 'category' ifAbsent: nil
]
