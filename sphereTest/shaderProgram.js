function shaderProgram(context, vertexShader, fragmentShader) {
	this.program;
	
	var getShader = function(gl, id){
        var shaderScript = document.getElementById(id);
        if (!shaderScript) {
            return null;
        }

        var str = "";
        var k = shaderScript.firstChild;
        while (k) {
            if (k.nodeType == 3) {
                str += k.textContent;
            }
            k = k.nextSibling;
        }

        var shader;
        if (shaderScript.type == "x-shader/x-fragment") {
            shader = gl.createShader(gl.FRAGMENT_SHADER);
        } else if (shaderScript.type == "x-shader/x-vertex") {
            shader = gl.createShader(gl.VERTEX_SHADER);
        } else {
            return null;
        }

        gl.shaderSource(shader, str);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            alert(gl.getShaderInfoLog(shader));
            return null;
        }

        return shader;
    }
	
	this.init = function(context, vertexShader, fragmentShader) {
		gl = context.getContext();

		var fragmentShader = getShader(gl, fragmentShader);
        var vertexShader = getShader(gl, vertexShader);
        
        this.program = gl.createProgram();
        gl.attachShader(this.program, vertexShader);
        gl.attachShader(this.program, fragmentShader);
        gl.linkProgram(this.program);

        if (!gl.getProgramParameter(this.program, gl.LINK_STATUS)) {
            alert("Could not initialise shaders");
        }

        gl.useProgram(this.program);

        this.program.vertexPositionAttribute = gl.getAttribLocation(this.program, "vertexPosition");
        gl.enableVertexAttribArray(this.program.vertexPositionAttribute);

        this.program.vertexNormalAttribute = gl.getAttribLocation(this.program, "vertexNormal");
        gl.enableVertexAttribArray(this.program.vertexNormalAttribute);
        
        this.program.textureCoordAttribute = gl.getAttribLocation(this.program, "textureCoord");
        gl.enableVertexAttribArray(this.program.textureCoordAttribute);

        this.program.projectionMatUniform = gl.getUniformLocation(this.program, "projectionMat");
        this.program.normalMatUniform = gl.getUniformLocation(this.program, "normalMat");
        this.program.modelViewMatUniform = gl.getUniformLocation(this.program, "modelViewMat");
        this.program.textureUniform = gl.getUniformLocation(this.program, "texture");
	}
	
	this.init(context, vertexShader, fragmentShader);
	
	this.getProgram = function() {
		return this.program;
	}
}