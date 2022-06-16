Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [
	| tags selectors |
	tags := classTags collect: #asWebsideJson.
	selectors := OrderedCollection new.
	self classNamesAndExtensionSelectorsDo: [ :c :s | selectors add: (NeoJSONObject new at: 'class' put: c asString; at: 'selector' put: s asString; yourself) ].
	^ super asWebsideJson
		at: 'name' put: name;
		at: 'classes' put: self definedClassNames;
		at: 'methods' put: selectors;
		yourself
]
