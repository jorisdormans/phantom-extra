package nl.jorisdormans.phantomextra.hexgrid 
{
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.objects.GameObjectComponent;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class HexMover extends GameObjectComponent
	{
		public var distance:int;
		public var path:Vector.<Hex>;
		public var hex:Hex;
		private var going:Boolean;
		public var speed:Number;
		private var timer:Number;
		private var moved:int;
		
		public function HexMover(hex:Hex, distance:int, speed:Number) 
		{
			this.speed = speed;
			this.distance = distance;
			path = new Vector.<Hex>();
			this.hex = hex;
			this.going = false;
			this.timer  = 0;
		}
		
		override public function update(elapsedTime:Number):void 
		{
			super.update(elapsedTime);
			if (going) {
				timer += speed * elapsedTime;
				if (timer > 1) {
					timer--;
					moveToNextHex();
					moved++;
					if (path.length == 0 || moved >= distance) {
						going = false;
					}
				}
			}
			
		}
		
		private function moveToNextHex():void 
		{
			if (path.length > 0) {
				var selected:Boolean = hex.selected;
				hex.mark = 0;
				hex.object = null;
				hex = path.pop();
				hex.object = this.gameObject;
				if (selected) {
					hex.grid.selected = hex;
				}
			}
		}
		
		public function go():void {
			going = true;
			timer = 0;
			moved = 0;
		}
		
		public function markPath():void 
		{
			if (!path) return;
			for (var i:int = 0; i < path.length; i++) {
				path[i].mark = 1;
			}
		}
		
	}

}