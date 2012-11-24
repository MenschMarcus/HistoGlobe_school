function sphere(radius, latitudeBands, longitudeBands) {
	this.radius = radius;
	this.latitudeBands = latitudeBands;
	this.longitudeBands = longitudeBands;
	this.vertexPositionBuffer;
	this.vertexNormalBuffer;
	this.vertexTexCoordBuffer;
	this.vertexIndexBuffer;
	this.program; 
	this.transform = mat4.create();
	this.yRot = 0.0;
	
	var texture;
	
    var handleLoadedTexture = function(gl, texture) {
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, texture.image);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

        gl.bindTexture(gl.TEXTURE_2D, null);
    }
	
	this.uploadTo = function(context) {
		this.program = new shaderProgram(context, "vertexShader", "fragmentShader");
		
		gl = context.getContext();
		
        var vertexPositionData = [];
        var normalData = [];
        var textureCoordData = [];
        for (var latNumber=0; latNumber <= this.latitudeBands; latNumber++) {
            var theta = latNumber * Math.PI / this.latitudeBands;
            var sinTheta = Math.sin(theta);
            var cosTheta = Math.cos(theta);

            for (var longNumber=0; longNumber <= this.longitudeBands; longNumber++) {
                var phi = longNumber * 2 * Math.PI / this.longitudeBands;
                var sinPhi = Math.sin(phi);
                var cosPhi = Math.cos(phi);

                var x = cosPhi * sinTheta;
                var y = cosTheta;
                var z = sinPhi * sinTheta;
                var u = 1 - (longNumber / this.longitudeBands);
                var v = 1 - (latNumber / this.latitudeBands);

                normalData.push(x);
                normalData.push(y);
                normalData.push(z);
                textureCoordData.push(u);
                textureCoordData.push(v);
                vertexPositionData.push(radius * x);
                vertexPositionData.push(radius * y);
                vertexPositionData.push(radius * z);
            }
        }

        var indexData = [];
        for (var latNumber=0; latNumber < this.latitudeBands; latNumber++) {
            for (var longNumber=0; longNumber < this.longitudeBands; longNumber++) {
                var first = (latNumber * (this.longitudeBands + 1)) + longNumber;
                var second = first + this.longitudeBands + 1;
                indexData.push(first);
                indexData.push(second);
                indexData.push(first + 1);

                indexData.push(second);
                indexData.push(second + 1);
                indexData.push(first + 1);
            }
        }

        this.vertexNormalBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normalData), gl.STATIC_DRAW);
        this.vertexNormalBuffer.itemSize = 3;
        this.vertexNormalBuffer.numItems = normalData.length / 3;

        this.vertexTexCoordBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTexCoordBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(textureCoordData), gl.STATIC_DRAW);
        this.vertexTexCoordBuffer.itemSize = 2;
        this.vertexTexCoordBuffer.numItems = textureCoordData.length / 2;

        this.vertexPositionBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexPositionBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertexPositionData), gl.STATIC_DRAW);
        this.vertexPositionBuffer.itemSize = 3;
        this.vertexPositionBuffer.numItems = vertexPositionData.length / 3;

        this.vertexIndexBuffer = gl.createBuffer();
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(indexData), gl.STATIC_DRAW);
        this.vertexIndexBuffer.itemSize = 1;
        this.vertexIndexBuffer.numItems = indexData.length;
        
        texture = gl.createTexture();
        texture.image = new Image();
        
        texture.image.onload = function() {
        	handleLoadedTexture(gl, texture);
        }
        
        texture.image.src = "world.jpg";
    }
	
	this.update = function(elapsedTime) {
		this.yRot += (Math.PI * elapsedTime) / 10000.0;
	}
	
	this.draw = function(context, pMatrix) {
		var gl = context.getContext();
		var shaderProgram = this.program.getProgram();
		
		gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexPositionBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexPositionAttribute, this.vertexPositionBuffer.itemSize, gl.FLOAT, false, 0, 0);
        
        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexNormalBuffer);
        gl.vertexAttribPointer(shaderProgram.vertexNormalAttribute, this.vertexNormalBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexTexCoordBuffer);
        gl.vertexAttribPointer(shaderProgram.textureCoordAttribute, this.vertexTexCoordBuffer.itemSize, gl.FLOAT, false, 0, 0);

        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, texture);
        gl.uniform1i(shaderProgram.textureUniform, 0);
        
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        
        mat4.identity(this.transform);
        
        mat4.translate(this.transform, [0.0, 0.0, -15.0]);
        
        mat4.rotate(this.transform, this.yRot, [0, 1, 0]);
        
        var nMatrix = mat4.create();
        mat4.inverse(this.transform, nMatrix);
        mat4.transpose(nMatrix, nMatrix);  
        
        gl.uniformMatrix4fv(shaderProgram.projectionMatUniform, false, pMatrix);
        gl.uniformMatrix4fv(shaderProgram.normalMatUniform, false, nMatrix);
        gl.uniformMatrix4fv(shaderProgram.modelViewMatUniform, false, this.transform);
        
        gl.drawElements(gl.TRIANGLES, this.vertexIndexBuffer.numItems, gl.UNSIGNED_SHORT, 0);		
	}
}