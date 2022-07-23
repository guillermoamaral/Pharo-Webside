Extension { #name : #RBRenamePackageChange }

{ #category : #'*Webside' }
RBRenamePackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'name' put: oldName;
		  at: 'newName' put: newName;
		  yourself
]

{ #category : #'*Webside' }
RBRenamePackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	oldName := json at: 'name' ifAbsent: nil.
	newName := json at: 'newName' ifAbsent: nil
]
