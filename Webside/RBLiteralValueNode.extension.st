Extension { #name : #RBLiteralValueNode }

{ #category : #'*Webside' }
RBLiteralValueNode >> asWebsideJson [
	^ super asWebsideJson
		at: 'value' put: value asString;
		yourself
]
