Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [
	^ super asWebsideJson
		at: 'name' put: name;
		at: 'children' put: #();
		yourself
]
