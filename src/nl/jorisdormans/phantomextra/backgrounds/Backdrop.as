package nl.jorisdormans.phantomextra.backgrounds 
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.core.Layer;
	import nl.jorisdormans.phantom2D.util.PseudoRandom;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Backdrop extends Layer
	{
		public static const MOUNTAINS:String = "mountains";
		
		private var parrallax:Number;
		private var detail:Number;
		private var noise:Number;
		private var averageY:Number;
		private var random:PseudoRandom;
		private var colorTop:uint;
		private var colorMiddle:uint;
		private var colorBottom:uint;
		private var middlePos:Number;
		private var type:String;
		
		public function Backdrop(type:String, width:Number, height:Number, parrallax:Number, averageY:Number, detail:Number, noise:Number, colorTop:uint, colorMiddle:uint, colorBottom:uint, middlePos:Number = 0.5, randomSeed:int = 0) 
		{
			super(width, height);
			this.type = type;
			this.middlePos = middlePos;
			this.colorBottom = colorBottom;
			this.colorMiddle = colorMiddle;
			this.colorTop = colorTop;
			this.averageY = averageY;
			this.noise = noise;
			this.detail = detail;
			this.parrallax = parrallax;
			random = new PseudoRandom();
			if (randomSeed == 0) randomSeed = Math.random() * (int.MAX_VALUE - 1)+1;
			random.seed = randomSeed;
			
			create();
			createMountains();
		}
		
		private function create():void 
		{
			switch (type) {
				case MOUNTAINS:
					createMountains();
					break;
			}
			//sprite.cacheAsBitmap = true;
		}
		
		private function createMountains():void 
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox( layerHeight, layerWidth );
			matrix.rotate( Math.PI * 0.5);
			
			var top:int = Math.max(0, 255 * (averageY - noise) / layerHeight);
			var bottom:int = Math.min(255, 255 * (averageY + noise + noise) / layerHeight);
			var middle:int = top + (bottom - top) * middlePos;
			
			sprite.graphics.clear();
			sprite.graphics.beginGradientFill(GradientType.LINEAR, [colorTop, colorMiddle, colorBottom], [1.0, 1.0, 1.0], [top, middle, bottom], matrix);
			
			//random settings for the perlin noise generator
			var periodBase:Number = random.nextFloat() * 100;
			var periodLarge:Number = random.nextFloat() * 0.01+0.01;
			var periodMedium:Number = random.nextFloat() * 0.03+0.02;
			var periodSmall:Number = random.nextFloat() * 0.07 + 0.07;
			var amplitudeLarge:Number = (random.nextFloat() * 0.2 + 0.4) * noise;
			var amplitudeMedium:Number = (random.nextFloat() * 0.1 + 0.1) * noise;
			var amplitudeSmall:Number = (random.nextFloat() * 0.05 + 0.05) * noise;
			
			var data:Vector.<Number> = new Vector.<Number>();
			
			var x:Number = 0;
			var y:Number = 0;
			var prevX:Number;
			var prevY:Number;
			while (true) {
				y = this.averageY;
				y += Math.cos((periodBase + x) * periodLarge) * amplitudeLarge;
				y += Math.cos((periodBase + x) * periodMedium) * amplitudeMedium;
				y += Math.cos((periodBase + x) * periodSmall) * amplitudeSmall;
				if (x == 0) {
					sprite.graphics.moveTo(x, y);
					data.push(x, y);
				} else {
					var p:Number = (0.5 + random.nextJFloat(0.3));
					var cx:Number = prevX + (x - prevX) * p;
					var cy:Number = prevY + (y - prevY) * p;
					cy += Math.abs(y - prevY) * (0.2 + random.nextJFloat(0.4));
					sprite.graphics.curveTo(cx, cy, x, y);
					data.push(cx, cy);
					data.push(x, y);
				}
				prevX = x;
				prevY = y;
				if (x == layerWidth) break;
				x += detail * (1 + random.nextJFloat(0.5));
				if (x > layerWidth) x = layerWidth;
				periodBase += random.nextFloat() * detail * 0.5;
				
			}
			
			sprite.graphics.lineTo(layerWidth, y);
			sprite.graphics.lineTo(layerWidth, layerHeight);
			sprite.graphics.lineTo(0, layerHeight);
			
			sprite.graphics.endFill();
			
			//add details
			
			sprite.graphics.beginFill(colorTop);
			for (var i:int = 2; i < data.length; i += 4) {
				if (random.nextFloat() < (averageY+noise-data[i+1]) / (noise) && Math.abs(data[i-1]-data[i+3])>noise*0.2) {
					var lower:Number = (0.05 + random.nextJFloat(0.02)) * noise;
					var xVariance:Number = random.nextJFloat(detail * 0.2);
					var yVariance:Number = detail * (0.4 + random.nextJFloat(0.2));
					var smaller:Number = detail*0.05;
					if (random.nextFloat() < 0.5) {
						lower += (0.3 + random.nextFloat()) * noise * 0.2;
						yVariance += detail * 0.3;
						smaller = detail*0.2;
					}
					sprite.graphics.moveTo(data[i - 2] + smaller, data[i - 1] + lower);
					sprite.graphics.curveTo(data[i], data[i + 1] + lower, data[i + 2] - smaller, data[i + 3] + lower);
					sprite.graphics.curveTo(data[i] + xVariance, data[i + 1] + lower+yVariance, data[i - 2] + smaller, data[i - 1] + lower);
				}
			}
			sprite.graphics.endFill();
			
			
		}
		
		override public function render(camera:Camera):void 
		{
			//super.render(camera);
			sprite.x = -camera.left * parrallax;
			sprite.y = -camera.top * parrallax;
		}
		
		
		
	}

}