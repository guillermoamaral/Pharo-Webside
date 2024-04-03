Extension { #name : #RBInsertClassRefactoring }

{ #category : #'*Webside' }
RBInsertClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'newName' put: className asString;
		 at: 'className' put: subclasses first name asString;
		at: 'superclassName' put: superclass name asString; 
			yourself
]

{ #category : #'*Webside' }
RBInsertClassRefactoring >> fromWebsideJson: json [

	| target |
	
			comment := ''.
	className := json at: 'newName' ifAbsent: nil.
	json at: 'className' ifPresent: [ :name |
		target := self classObjectFor: name asSymbol.
		target ifNotNil: [
			category := target category.
			superclass := target superclass.
			subclasses := { target } ] ]
]
