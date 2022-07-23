Extension { #name : #RBAddPackageChange }

{ #category : #'*Webside' }
RBAddPackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'name' put: packageName;
		  yourself
]

{ #category : #'*Webside' }
RBAddPackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	packageName := json at: 'name' ifAbsent: nil
]
