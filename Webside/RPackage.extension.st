Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [
	| tags |
	tags := (classTags collect: #asWebsideJson).
	^ super asWebsideJson
		at: 'name' put: name;
		at: 'children' put: tags;
		yourself
]
