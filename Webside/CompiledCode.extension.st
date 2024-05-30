Extension { #name : #CompiledCode }

{ #category : #'*Webside' }
CompiledCode >> websideIndexAccessor [

	^ super websideIndexAccessor
		  start: self initialPC;
		  end: self endPC;
		  yourself
]

{ #category : #'*Webside' }
CompiledCode >> websidePresentations [

	| source ast bytecodes |
	source := NeoJSONObject new
		          at: 'type' put: 'source';
		          at: 'title' put: 'Source';
		          at: 'code' put: self sourceCode;
		          yourself.
	ast := NeoJSONObject new
		       at: 'type' put: 'tree';
		       at: 'title' put: 'AST';
		       at: 'nodeLabel' put: 'printString';
		       at: 'roots' put: { self ast asWebsideJson };
		       yourself.
	bytecodes := NeoJSONObject new
		             at: 'type' put: 'table';
		             at: 'title' put: 'Bytecodes';
		             at: 'columns' put: { (NeoJSONObject new
				              at: 'field' put: 'value';
				              at: 'label' put: 'bytecode';
				              at: 'align' put: 'left';
				              yourself) };
		             at: 'rows'
		             put:
			             (self symbolicBytecodes withIndexCollect: [ :b :i |
				              NeoJSONObject new
					              at: 'value' put: b asString;
					              yourself ]);
		             yourself.
	^ {
		  source.
		  ast.
		  bytecodes } , super websidePresentations
]
