Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [
	| methods |
	methods := NeoJSONObject new.
	classExtensionSelectors
		keysAndValuesDo: [ :c :m | methods at: c asString put: m ].
	metaclassExtensionSelectors
		keysAndValuesDo: [ :c :m | methods at: c asString put: m ].
	^ super asWebsideJson
		at: 'name' put: name;
		at: 'classes' put: self definedClassNames;
		at: 'methods' put: methods;
		yourself
]
