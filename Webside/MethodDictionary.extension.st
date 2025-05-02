Extension { #name : 'MethodDictionary' }

{ #category : '*Webside' }
MethodDictionary >> websideIndexAccessor [

	^ super websideIndexAccessor
		  accessor: #basicAt:;
		  yourself
]
