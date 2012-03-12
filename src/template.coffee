exports.templates=
	qunit:
		html:"""
		    	<link rel="stylesheet" href="http://code.jquery.com/qunit/qunit-git.css" type="text/css"></link>
		    	<script type="text/javascript" src="http://code.jquery.com/qunit/qunit-git.js"></script>
		    	<script type="text/javascript" src="#jsFilePath#"></script>
		    	<h1 id="qunit-header">#title#</h1>
		    	<h2 id="qunit-banner"></h2>
		    	<div id="qunit-testrunner-toolbar"></div>
		    	<h2 id="qunit-userAgent"></h2>
		    	<ol id="qunit-tests"></ol>
		    	<div id="qunit-fixture">test markup, will be hidden</div>
		    	<script type="text/javascript" src="#testJsFilePath#"></script>
		    """
		js:"""
				test("Don't let me alone",function(){
					ok(false,"Will you?");
				});
			"""
