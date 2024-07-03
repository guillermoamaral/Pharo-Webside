Extension { #name : 'PackageTag' }

{ #category : '*Webside' }
PackageTag >> asWebsideJson [

	^ super asWebsideJson
		  at: 'name' put: name;
		  at: 'classes' put: self classNames;
		  yourself
]
