package nl.jorisdormans.phantomextra.advancedparticles 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.core.Composite;
	import nl.jorisdormans.phantom2D.core.Layer;
	import nl.jorisdormans.phantom2D.core.PhantomGame;
	import nl.jorisdormans.phantom2D.objects.ObjectLayer;
	import nl.jorisdormans.phantomextra.turbulence.TurbulanceGrid;
	import nl.jorisdormans.phantomextra.turbulence.Wind;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class AdvancedParticleLayer extends Layer
	{
		private var firstParticle:AdvancedParticle;
		private var lastParticle:AdvancedParticle;
		private var lastAddedParticle:AdvancedParticle;
		private var renderPasses:int;
		public var turbulenceGrid:TurbulanceGrid;
		public var wind:Wind;
		public var objectLayer:ObjectLayer;
		
		private var emitter:Number;
		private var particleCount:int;
		
		public function AdvancedParticleLayer(width:Number, height:Number, renderPasses:int = 1, particleCount:int = 128) 
		{
			this.particleCount = particleCount;
			this.renderPasses = renderPasses;
			for (var i:int = 0; i < particleCount; i++) {
				lastParticle = new AdvancedParticle();
				lastParticle.initialize(this, AdvancedParticle.TYPE_TEST, 0, 0, 0, 0, 0)
				if (!firstParticle) firstParticle = lastParticle;
				if (lastAddedParticle) lastAddedParticle.next = lastParticle;
				lastAddedParticle = lastParticle;
			}
			
			lastAddedParticle = null;
			
			emitter = 0;
			
			
			super(width, height);
			
		} 
		
		override public function onAdd(composite:Composite):void 
		{
			super.onAdd(composite);
			turbulenceGrid = parent.getComponentByClass(TurbulanceGrid) as TurbulanceGrid;
			objectLayer = parent.getComponentByClass(ObjectLayer) as ObjectLayer;
			wind = parent.getComponentByClass(Wind) as Wind;
			//createRain();
			createSnow();
		}
		
		private function createSnow():void 
		{
			for (var i:int = 0; i < particleCount; i++) {
				addParticle(AdvancedParticle.TYPE_SNOW, 100, 10, Math.random()*layerWidth, Math.random()*layerHeight, 0, 0, i/particleCount);
			}
		}
		
		
		private function createRain():void 
		{
			for (var i:int = 0; i < particleCount; i++) {
				addParticle(AdvancedParticle.TYPE_RAIN, 100, 10, Math.random()*layerWidth, Math.random()*layerHeight, 0, 0, i/particleCount);
			}
		}
		
		
		override public function updatePhysics(elapsedTime:Number):void 
		{
			//PhantomGame.profiler.begin("advanced particles update");
			
			if (emitter < 0) {
				emitter += 0.1;
				//addParticle(AdvancedParticle.TYPE_STEAM, 2, 20, 200, 500);
				//addParticle(AdvancedParticle.TYPE_SMOKE, 3, 40, 600, 500);
				//addParticle(AdvancedParticle.TYPE_SMOKE, 3, 40, 598, 500);
				//addParticle(AdvancedParticle.TYPE_FIRE, 1.2, 30, 337, 520);
				//addParticle(AdvancedParticle.TYPE_FIRE, 1.3, 35, 352, 522);
				//addParticle(AdvancedParticle.TYPE_FIRE, 1.2, 30, 367, 520);
				
				
				//addParticle(AdvancedParticle.TYPE_FIRE, 1.5, 20, 603, 520, 0, 0, 0);
				//addParticle(AdvancedParticle.TYPE_FIRE, 1.5, 15, 592, 520, 0, 0, 0);
			} else {
				emitter -= elapsedTime;
			}
			
			
			var current:AdvancedParticle = firstParticle;
			var previous:AdvancedParticle = null;
			while (current && current.life > 0) {
				current.update(elapsedTime);
				if (current.life <= 0 && current.next) {
					if (previous) {
						previous.next = current.next;
					} else {
						firstParticle = current.next;
						previous = null;
					}
					//move the particle to the end of the list
					lastParticle.next = current;
					lastParticle = current;
					current = current.next;
					lastParticle.next = null;
				} else {
					previous = current;
					current = previous.next;
				}
			}
			
			//PhantomGame.profiler.end("advanced particles update");
		}
		
		override public function render(camera:Camera):void 
		{
			//PhantomGame.profiler.begin("advanced particles render");
			sprite.graphics.clear();
			for (var i:int = 0; i < renderPasses; i++) {
				var current:AdvancedParticle = firstParticle;
				while (current && current.life > 0) {
					current.render(sprite.graphics, camera, i);
					current = current.next;
				}
			}
			//PhantomGame.profiler.end("advanced particles render");
			
			/*
			var l:int = particles.length
			for (var i:int = 0; i < l; i++) {
				var offsetX:Number = 0;
				var offsetY:Number = 0;
				var px:Number = particles[i].position.x;
				var py:Number = particles[i].position.y;
				if (renderWrappedHorizontal) {
					if (px < camera.left) {
						px += layerWidth;
						offsetX = layerWidth;
					} else if (px > camera.right) {
						px -= layerWidth;
						offsetX = -layerWidth;
					}
				}
				if (renderWrappedVertical) {
					if (py < camera.top) {
						py += layerHeight;
						offsetY = layerHeight;
					} else if (py > camera.bottom) {
						py -= layerHeight;
						offsetY = -layerHeight;
					}
				}
				if (px>camera.left-10 && px<camera.right+10 && py>camera.top-10 && py<camera.bottom+10) {
					//adjust camera for wrapping
					camera.left -= offsetX;
					camera.top -= offsetY;
					particles[i].render(sprite.graphics, camera);
					//readjust camera after wrapping
					camera.left += offsetX;
					camera.top += offsetY;
				}
			}
			*/
		}
		
		/**
		 * Adds a particle to the layer. If there are too many the oldest particles are removed to make space for new ones
		 * @param	particle	The Particle to be added
		 */
		public function addParticle(type:int, life:Number, size:Number, x:Number, y:Number, vx:Number = 0, vy:Number = 0, data:Number = 0):void {
			if (lastAddedParticle) {
				if (lastAddedParticle.next) {
					lastAddedParticle = lastAddedParticle.next;
				} else {
					return;
				}
			} else {
				lastAddedParticle = firstParticle;
			}
			lastAddedParticle.initialize(this, type, life, size, x, y, vx, vy, data);
		}		
		
		
	}

}