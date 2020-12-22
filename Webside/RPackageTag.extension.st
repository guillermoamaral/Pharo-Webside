Extension { #name : #RPackageTag }

{ #category : #'*Webside' }
RPackageTag >> asWebsideJson [
	^ super asWebsideJson
		at: 'name' put: name;
		at: 'classNames' put: classNames;
		yourself
]
