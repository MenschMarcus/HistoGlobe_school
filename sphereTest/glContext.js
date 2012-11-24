function glContext(canvas) {
	this.context;
	
	this.init = function(canvas) {
	    try {
	    	this.context = canvas.getContext("experimental-webgl");
	    	this.context.viewportWidth = canvas.width;
	    	this.context.viewportHeight = canvas.height;
	    	this.context.clearColor(0.0, 0.0, 0.0, 1.0);
	    	this.context.enable(this.context.DEPTH_TEST);
	    } catch (e) {
	    }
	    if (!this.context) {
	        alert("Could not initialise WebGL!");
	    }   
	}
	
	this.init(canvas);
	
	this.getContext = function() {
		return this.context;
	}
}