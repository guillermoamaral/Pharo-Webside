Extension { #name : #RBRenamePackageChange }

{ #category : #'*Webside' }
RBRenamePackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'package' put: oldName;
		  at: 'newName' put: newName;
		  yourself
		
]

{ #category : #'*Webside' }
RBRenamePackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	oldName := json at: 'package' ifAbsent: nil.
	newName := json at: 'newName' ifAbsent: nil.
]
