Extension { #name : #RBAddPackageChange }

{ #category : #'*Webside' }
RBAddPackageChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'package' put: packageName;
		  yourself
]

{ #category : #'*Webside' }
RBAddPackageChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	packageName := json at: 'package' ifAbsent: nil.

]
