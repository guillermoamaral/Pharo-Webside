Extension { #name : #RBAssignmentNode }

{ #category : #'*Webside' }
RBAssignmentNode >> asWebsideJson [

	^ super asWebsideJson at: 'children' put: { 
			  variable asWebsideJson.
			  value asWebsideJson }; yourself 
]
