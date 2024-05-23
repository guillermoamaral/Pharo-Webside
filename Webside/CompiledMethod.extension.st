Extension { #name : #CompiledMethod }

{ #category : #'*Webside' }
CompiledMethod >> asWebsideJson [

	| json status |
	json := super asWebsideJson.
	json
		at: 'selector' put: self selector;
		at: 'methodClass' put: (self methodClass ifNotNil: [ :c | c name ]);
		at: 'category' put: self category;
		at: 'package' put: (self package ifNotNil: [ :p | p name ]);
		at: 'source' put: self sourceCode;
		at: 'author' put: self author;
		at: 'timestamp' put: self timeStamp;
		at: 'overriding' put: self isOverriding;
		at: 'overriden' put: self isOverridden;
		at: 'needsRecompilation' put: self usesUndeclareds.
	self isTestMethod ifTrue: [
		status := self isPassedTest
			          ifTrue: [ 'passed' ]
			          ifFalse: [
				          self isFailedTest
					          ifTrue: [ 'failed' ]
					          ifFalse: [
						          self isErrorTest
							          ifTrue: [ 'error' ]
							          ifFalse: [ 'unknown' ] ] ].
		json at: 'status' put: status ].
	^ json
]
