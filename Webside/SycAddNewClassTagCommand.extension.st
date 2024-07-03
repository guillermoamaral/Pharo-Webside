Extension { #name : 'SycAddNewClassTagCommand' }

{ #category : '*Webside' }
SycAddNewClassTagCommand >> asWebsideJson [

	^ super asWebsideJson
		  at: 'package' put: package name;
		  at: 'category' put: tagName ;
		  yourself
]

{ #category : '*Webside' }
SycAddNewClassTagCommand >> fromWebsideJson: json [

	super fromWebsideJson: json.
	json at: 'package' ifPresent: [ :p |
		package := PackageOrganizer default packageNamed: p ifAbsent: nil ].
	tagName := json at: 'category' ifAbsent: nil
]

{ #category : '*Webside' }
SycAddNewClassTagCommand class >> websideType [

	^ 'AddClassCategory'
]
