Extension { #name : #ClyRemoveClassGroupCommand }

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand >> fromWebsideJson: json [

	| package |
	super fromWebsideJson: json.
	json at: 'package' ifPresent: [ :p |
		package := RPackageOrganizer default packageNamed: p.
		json
			at: 'category'
			ifPresent: [ :c |
			classGroup := package classTagNamed: c ifAbsent: nil ] ]
]

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand >> websideExecute [

	| classes remotions changes |
	classes := classGroup classes.
	classes isEmpty ifTrue: [ ^ super websideExecute ].
	remotions := classes collect: [ :c |
		             RBRemoveClassChange remove: c ].
	changes := OrderedCollection withAll: remotions.
	changes add: self.
	(WebsideChangeError from: self)
		messageText: 'Remove category';
		suggest:
			'Category is not empty. Do you want to remove all its classes?'
		withChanges: changes;
		signal
]

{ #category : #'*Webside' }
ClyRemoveClassGroupCommand class >> websideType [ 
	^'RemoveClassCategory'
]
