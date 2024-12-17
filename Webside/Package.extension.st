Extension { #name : 'Package' }

{ #category : '*Webside' }
Package >> asWebsideJson [

	| methods categories |
	methods := NeoJSONObject new.
	extensionSelectors keysAndValuesDo: [ :c :m |
		methods at: c asString put: m ].
	categories := self tagsForClasses.
	extensionSelectors notEmpty ifTrue: [
		categories := categories , { 'Extensions' } ].
	categories := categories asArray sort collect: [ :c |
		              NeoJSONObject new
			              at: 'name' put: c;
			              at: 'package' put: name;
			              yourself ].
	^ super asWebsideJson
		  at: 'name' put: name;
		  at: 'classes' put: self definedClassNames;
		  at: 'methods' put: methods;
		  at: 'categories' put: categories;
		  at: 'iconName' put: #package;
		  yourself
]
