Extension { #name : 'ClyRenamePackageTagCommand' }

{ #category : '*Webside' }
ClyRenamePackageTagCommand >> asWebsideJson [


	| json |
	json := super asWebsideJson.
	json
		at: 'package' put: package name;
		at: 'category' put: packageTag name;
		at: 'newName' put: newName.
	^ json
]

{ #category : '*Webside' }
ClyRenamePackageTagCommand >> fromWebsideJson: json [

	| scope |
	super fromWebsideJson: json.
	newName := json at: 'newName' ifAbsent: nil.
	json at: 'package' ifPresent: [ :p |
		package := PackageOrganizer default packageNamed: p.
		scope := ClyPackageScope
			         of: package
			         in: ClyNavigationEnvironment new.
		json at: 'category' ifPresent: [ :c |
			packageTag := ClyTaggedClassGroup
				              withClassesFrom: scope
				              taggedBy: c ] ] 
]

{ #category : '*Webside' }
ClyRenamePackageTagCommand class >> websideType [

	^ 'RenameClassCategory'
]
