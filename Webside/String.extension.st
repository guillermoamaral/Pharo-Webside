Extension { #name : #String }

{ #category : #'*Webside' }
String >> asWebsideJson [
	^ super asWebsideJson
		removeKey: 'presentation' ifAbsent: [  ];
		yourself
]
