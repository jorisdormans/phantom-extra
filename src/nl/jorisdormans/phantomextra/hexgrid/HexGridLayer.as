package nl.jorisdormans.phantomextra.hexgrid 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.core.InputState;
	import nl.jorisdormans.phantom2D.core.Layer;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class HexGridLayer extends Layer
	{
		public var hexes:Vector.<Hex>
		private var hexesX:int;
		private var hexesY:int;
		private var hexSize:Number;
		private var perspective:Number;
		
		private var hexWidth:Number;
		private var hexHeight:Number;
		private var hexHeigthOffset:Number;
		
		private var _hovering:Hex;
		private var _selected:Hex;
		
		public function HexGridLayer(width:int, height:int, hexSize:Number, perspective:Number) 
		{
			this.perspective = perspective;
			this.hexSize = hexSize;
			this.hexesX = width;
			this.hexesY = height;
			
			hexWidth = hexSize * Math.cos(Math.PI * 1 / 6)
			hexHeight = hexSize * perspective * (1 - (Math.sin(Math.PI * 1 / 12)));
			hexHeigthOffset = (Math.sin(Math.PI * 1 / 12)) * hexSize * perspective;
			
			width = hexWidth * (width + 0.5);
			height = hexSize * height * perspective * (1 - (Math.sin(Math.PI * 1 / 12))) + hexHeigthOffset;
			super(width, height);
			
			hexes = new Vector.<Hex>();
			
			createHexes();
			
		}
		
		private function createHexes():void 
		{
			while (hexes.length > 0) hexes.pop();
			for (var y:int = 0; y < hexesY; y++) {
				for (var x:int = 0; x < hexesX; x++) {
					var p:Vector3D = new Vector3D();
					p.x = hexWidth * (x + 0.5 + (y % 2) * 0.5);
					p.y = hexHeight * (y + 0.5) + hexHeigthOffset *0.5;
					hexes.push(new Hex(this, p));
				}
			}
			
			//connect hexes
			for (y = 0; y < hexesY; y++) {
				for (x = 0; x < hexesX; x++) {
					var hex:int = x + y * hexesX;
					if (x > 0) hexes[hex].neighbors[3] = hexes[hex - 1];
					if (x < hexesX - 1) hexes[hex].neighbors[0] = hexes[hex + 1];
					if (y % 2 == 1) {
						hexes[hex].neighbors[4] = hexes[hex - hexesX];
						if (x < hexesX - 1) hexes[hex].neighbors[5] = hexes[hex - hexesX + 1];
						if (y < hexesY - 1) {
							hexes[hex].neighbors[2] = hexes[hex + hexesX];
							if (x < hexesX - 1) hexes[hex].neighbors[1] = hexes[hex + hexesX + 1];
							
						}
					} else {
						hexes[hex].neighbors[1] = hexes[hex + hexesX];
						if (x > 0) hexes[hex].neighbors[2] = hexes[hex + hexesX - 1];
						if (y > 0) {
							hexes[hex].neighbors[5] = hexes[hex - hexesX];
							if (x > 0) hexes[hex].neighbors[4] = hexes[hex - hexesX - 1];
						}
					}
				}
			}
		}
		
		override public function render(camera:Camera):void 
		{
			super.render(camera);
			sprite.graphics.lineStyle(1, 0xff0000);
			sprite.graphics.drawRect(0, 0, this.layerWidth, this.layerHeight);
			
			for (var i:int = 0; i < hexes.length; i++) {
				var rx:Number = hexes[i].position.x - camera.left;
				var ry:Number = hexes[i].position.y - camera.top;
				hexes[i].render(sprite.graphics, rx, ry, hexSize, perspective);
			}
			
			var l:int = renderables.length;
			while (i < l) {
				renderables[i].render(sprite.graphics, 0, 0, camera.angle, camera.zoom);
				i++;
			}
		}
		
		public function get selected():Hex 
		{
			return _selected;
		}
		
		public function set selected(value:Hex):void 
		{
			if (_selected == value) return;
			if (_selected) {
				_selected.selected = false;
			}
			_selected = value;
			if (_selected) {
				_selected.selected = true;
			}
		}
		
		override public function handleInput(elapsedTime:Number, currentState:InputState, previousState:InputState):void 
		{
			super.handleInput(elapsedTime, currentState, previousState);
			if (currentState.mouseButton && !previousState.mouseButton) {
				var hex:Hex = getHex(currentState.localX, currentState.localY);
				if (hex.onClick(selected)) {
					selected = hex;
				}
			}
		}
		
		public function getHex(x:Number, y:Number):Hex {
			var result:Hex = null;
			
			var hy:int = Math.floor((y - hexHeigthOffset*0.5) / hexHeight);
			var hx:int = Math.floor((x - (hy % 2) * hexWidth * 0.5) / hexWidth);
			
			if (hx >= 0 && hx < this.hexesX && hy >= 0 && hy < this.hexesY) result = hexes[hx + hy * this.hexesX];
			
			return result;
		}
		
		public function getRandomHex():Hex {
			var r:int = Math.random() * hexes.length;
			return hexes[r];
		}
		
		public function clearMarks():void 
		{
			for (var i:int = 0; i < hexes.length; i++) {
				hexes[i].mark = 0;
			}
		}
		
		public function clearDistance():void 
		{
			for (var i:int = 0; i < hexes.length; i++) {
				hexes[i].distance = hexes.length;
			}
		}
		
		override public function update(elapsedTime:Number):void 
		{
			super.update(elapsedTime);
			
			for (var i:int = 0; i < hexes.length; i++) {
				if (hexes[i].object) {
					hexes[i].object.update(elapsedTime);
				}
			}
		}
		
		
	}

}