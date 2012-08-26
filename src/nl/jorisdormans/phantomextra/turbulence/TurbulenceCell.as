package nl.jorisdormans.phantomextra.turbulence 
{
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.util.DrawUtil;
	import nl.jorisdormans.phantom2D.util.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class TurbulenceCell 
	{
		private var pressure:Number = 0;
		private var newPressure:Number = 0;
		private var flowStrength:Number = 0;
		private var newFlowStrength:Number = 0;
		private var flowDirection:Number = 0;
		private var newFlowDirection:Number = 0;
		
		private static const INVERSE_PI:Number = 1 / Math.PI;
		private static const INVERSE_PI3:Number = 3 / Math.PI;
		private static const ANGULAR_OFFSET:Number = Math.PI * 0.1;
		static public const THIRD_PI:Number= Math.PI / 3; 
		
		private var neighbours:Vector.<TurbulenceCell>;
		
		/*public var direction:Number;
		public var directionDelta:Number;
		public var force:Number;
		public var forceDelta:Number;
		public var pressure:Number;
		public var pressureDelta:Number;
		public var up:TurbulenceCell;
		public var down:TurbulenceCell;
		public var left:TurbulenceCell;
		public var right:TurbulenceCell;*/
		
		public function TurbulenceCell() 
		{
			flowStrength = Math.random() * 0.1 +0.1;
			flowStrength = 0.2;
			flowDirection = Math.random() * Math.PI * 2;
			
			pressure = Math.random();
			neighbours = new Vector.<TurbulenceCell>();
			
			prepare();
		}
		
		public function render(graphics:Graphics, x:Number, y:Number, size:Number):void {
			x += size * 0.5;
			y += size * 0.5;
			graphics.beginFill(DrawUtil.lerpColor(0xffffff, 0xff0000, MathUtil.clamp(pressure, 0, 1)));
			graphics.drawCircle(x, y, size *0.3);
			graphics.endFill();
			graphics.lineStyle(1, 0xffffff);
			
			//graphics.drawRect(x + 2, y + size - 2, 2, (size -4) * pressure * -0.5);
			
			
			graphics.moveTo(x, y);
			graphics.lineTo(x + Math.cos(flowDirection) * flowStrength * size * 2, y + Math.sin(flowDirection) * flowStrength * size * 2);
			
			graphics.lineStyle();
		}
		
		public function prepare():void {
			newFlowDirection = flowDirection;
			newFlowStrength = flowStrength;
			//newPressure = pressure*0.98+0.01;
			newPressure = pressure;
		}
		
		public function applyChanges():void {
			if (newPressure>1) newPressure=1;
			if (newPressure<0) newPressure=0;
			pressure = newPressure;

			if (newFlowStrength<0) newFlowStrength=0;

			flowStrength=newFlowStrength;

			flowDirection=newFlowDirection;
			
			prepare();
			
		}
		
		private function neighbourFromDirection(direction:Number):Number {
			direction = (direction*INVERSE_PI3) % 6;
			while (direction<0) direction+=6;
			return direction;
		}
		

		public function update(elapsedTime:Number, turbulence:Number = 1):void {
			var flowFactor:Number = flowStrength * elapsedTime * turbulence*4;
			
			var direction:Number = neighbourFromDirection(flowDirection + ANGULAR_OFFSET);
			var neighbour1:int = Math.floor(direction)%6;
			var neighbour2:int = (neighbour1+1)%6;
			var factor:Number = direction - neighbour1;
			
			newPressure-= flowFactor;
			neighbours[neighbour1].newPressure += flowFactor * (1 - factor);
			neighbours[neighbour2].newPressure += flowFactor * factor;
			
			var difference:Number;
			
			var d:Number;
			d = elapsedTime* turbulence;
			
			for (var i:int = 0; i < 6; i++) {
				difference = MathUtil.angleDifference(neighbours[i].flowDirection, flowDirection);
				newFlowDirection += difference * neighbours[i].flowStrength * elapsedTime * 0.5;
			}
			
			for (i = -2; i < 3; i++) {
				var n:int = neighbourFromDirection(flowDirection + i * THIRD_PI);
				
				difference = pressure - neighbours[n].pressure;
				if (difference>0.2) {
					
					newPressure-=d*difference;
					neighbours[n].newPressure += d * difference;
				}
				if (difference>0) {
					newFlowDirection += i * THIRD_PI * elapsedTime * difference * 4;
					newFlowStrength = newFlowStrength * 0.95 + 0.05;
				} else {
					newFlowStrength = newFlowStrength * 0.95;
				}
			}
		}
		
		public function addNeighbour(neighbour:TurbulenceCell):void {
			neighbours.push(neighbour);
		}
		
		public function turbulenceX():Number 
		{
			return Math.cos(flowDirection) * flowStrength;
		}
		
		public function turbulenceY():Number 
		{
			return Math.sin(flowDirection) * flowStrength;
		}
		
	}

}