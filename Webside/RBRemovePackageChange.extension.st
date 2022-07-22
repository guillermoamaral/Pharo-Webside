Extension { #name : #RBRemovePackageChange }

{ #category : #'*Webside' }
RBRemovePackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'package' put: packageName;
		  yourself
]

{ #category : #'*Webside' }
RBRemovePackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	packageName := json at: 'package' ifAbsent: nil
]
