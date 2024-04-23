Extension { #name : #RPackage }

{ #category : #'*Webside' }
RPackage >> asWebsideJson [

	| methods categories |
	methods := NeoJSONObject new.
	classExtensionSelectors keysAndValuesDo: [ :c :m |
		methods at: c asString put: m ].
	metaclassExtensionSelectors keysAndValuesDo: [ :c :m |
		methods at: c asString , ' class' put: m ].
	categories := self tagsForClasses.
	(classExtensionSelectors notEmpty or: [
		 metaclassExtensionSelectors notEmpty ]) ifTrue: [
		categories := categories , { 'Extensions' } ].
	categories := categories collect: [ :c |
		              NeoJSONObject new
			              at: 'name' put: c;
			              at: 'package' put: name;
			              yourself ].
	^ super asWebsideJson
		  at: 'name' put: name;
		  at: 'classes' put: self definedClassNames;
		  at: 'methods' put: methods;
		  at: 'categories' put: categories;
		  yourself
]
