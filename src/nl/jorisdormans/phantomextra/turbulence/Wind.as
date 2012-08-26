package nl.jorisdormans.phantomextra.turbulence 
{
	import flash.display.Graphics;
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.objects.IRenderable;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Wind extends Component implements IRenderable
	{
		private var wantDirection:int;
		private var currentDirection:Number;
		private var lowStrength:Number;
		private var highStrength:Number;
		private var lowPeriod:Number;
		private var highPeriod:Number;
		private var lowRandom:Number;
		private var highRandom:Number;
		private var periodTimer:Number;
		private var noiseTimer:Number;
		private var wantPeriod:Number;
		private var currentPeriod:Number;
		private var variance:Number;
		public var windStrength:Number;
		
		
		public function Wind(direction:int, lowStrength:Number, highStrength:Number, lowPeriod:Number, highPeriod:Number, lowRandom:Number = 0, highRandom:Number = 0 ) 
		{
			this.highRandom = highRandom;
			this.lowRandom = lowRandom;
			this.highPeriod = highPeriod;
			this.lowPeriod = lowPeriod;
			this.highStrength = highStrength - lowStrength;
			this.lowStrength = lowStrength;
			this.wantDirection = direction;
			this.currentDirection = direction;
			
			periodTimer = lowPeriod;
			wantPeriod = 0;
			currentPeriod = 0;
			noiseTimer = Math.random()*100;
			windStrength = 0;
			
			variance = Math.min(lowStrength, 0.1);
		}
		
		override public function update(elapsedTime:Number):void 
		{
			noiseTimer += elapsedTime;
			periodTimer -= elapsedTime;
			if (periodTimer <= 0) {
				wantPeriod = 1 - wantPeriod;
				if (wantPeriod == 1) {
					periodTimer = highPeriod + highRandom * Math.random();
				} else {
					periodTimer = lowPeriod + lowRandom * Math.random();
				}
			}
			
			currentPeriod = currentPeriod * 0.95 + wantPeriod * 0.05;
			currentDirection = currentDirection * 0.95 + wantDirection * 0.05;
			
			windStrength = lowStrength + highStrength * currentPeriod + variance * (Math.cos(noiseTimer * 5) * 0.7 + Math.cos(noiseTimer * 2.3 * 5) * 0.3);
			windStrength *= currentDirection;
			
			super.update(elapsedTime);
		}
		
		/* INTERFACE nl.jorisdormans.phantom2D.objects.IRenderable */
		
		public function render(graphics:Graphics, x:Number, y:Number, angle:Number = 0, zoom:Number = 1):void 
		{
			graphics.lineStyle(1, 0xffffff);
			graphics.drawRect(10, 10, 200, 10);
			graphics.moveTo(110, 10);
			graphics.lineTo(110, 20);
			graphics.lineStyle();
			var c:uint = 0x0088ff;
			if (windStrength > 1 || windStrength < -1) c = 0xff0000;
			graphics.beginFill(c);
			graphics.drawRect(110+wantDirection, 12, windStrength * 50, 7);
			graphics.endFill();
		}
		
		
	}

}