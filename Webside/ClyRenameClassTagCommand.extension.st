Extension { #name : #ClyRenameClassTagCommand }

{ #category : #'*Webside' }
ClyRenameClassTagCommand >> asWebsideJson [

	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."

	| json |
	json := super asWebsideJson.
	json
		at: 'package' put: classGroup package name;
		at: 'category' put: classGroup name;
		at: 'newName' put: newName.
	^ json
]

{ #category : #'*Webside' }
ClyRenameClassTagCommand >> fromWebsideJson: json [

	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."
	
	super fromWebsideJson: json.
	newName := json at: 'newName' ifAbsent: nil.
	json at: 'package' ifPresent: [ :p |
		package := RPackageOrganizer default packageNamed: p.
		json
			at: 'category'
			ifPresent: [ :c |
			classGroup := package classTagNamed: c ifAbsent: nil ] ]
]

{ #category : #'*Webside' }
ClyRenameClassTagCommand >> websideExecute [

	"To review: we are using here RPackage and RPackageTag (instead of ClyTaggedClassGroup),
	since it was easier/faster to implement."
	classGroup renameTo: newName
]

{ #category : #'*Webside' }
ClyRenameClassTagCommand class >> websideType [

	^ 'RenameClassCategory'
]
