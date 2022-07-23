Extension { #name : #RBRemovePackageChange }

{ #category : #'*Webside' }
RBRemovePackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'name' put: packageName;
		  yourself
]

{ #category : #'*Webside' }
RBRemovePackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	packageName := json at: 'name' ifAbsent: nil
]
