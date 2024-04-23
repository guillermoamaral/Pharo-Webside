Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [

	| methods categories |
	methods := NeoJSONObject new.
	classExtensionSelectors keysAndValuesDo: [ :c :m |
		methods at: c asString put: m ].
	metaclassExtensionSelectors keysAndValuesDo: [ :c :m |
		methods at: c asString , ' class' put: m ].
	categories := self classTags reject: #isRoot thenCollect: #name.
	(classExtensionSelectors notEmpty or: [metaclassExtensionSelectors notEmpty]) ifTrue: [ categories := categories , { 'Extensions' } ].
	^ super asWebsideJson
		  at: 'name' put: name;
		  at: 'classes' put: self definedClassNames;
		  at: 'methods' put: methods;
		  at: 'categories' put: categories;
		  yourself
]
