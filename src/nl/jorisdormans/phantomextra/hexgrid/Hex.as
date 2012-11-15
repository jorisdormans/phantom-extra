package nl.jorisdormans.phantomextra.hexgrid 
{
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.objects.GameObject;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Hex 
	{
		public var neighbors:Vector.<Hex>
		public var position:Vector3D;
		public static var corners:Vector.<Number>;
		public var mark:int;
		public var distance:int;
		public var selected:Boolean;
		public var object:GameObject;
		public var grid:HexGridLayer;
		
		public function Hex(grid:HexGridLayer, position:Vector3D) 
		{
			this.grid = grid;
			neighbors = new Vector.<Hex>();
			for (var i:int = 0; i < 6; i++) {
				neighbors.push(null);
			}
			this.position = position;
			
			if (!corners) {
				corners = new Vector.<Number>();
				var a:Number = Math.PI * -0.5;
				while (a < Math.PI * 1.5) {
					corners.push(Math.cos(a), Math.sin(a));
					a += Math.PI * 2 / 6;
				}
			}
		}
		
		public function render(graphics:Graphics, x:Number, y:Number, hexSize:Number, perspective:Number):void {
			if (selected) graphics.lineStyle(3, 0x00ff00);
			else if (mark > 0) graphics.lineStyle(2, 0xff0000);
			else graphics.lineStyle(1, 0x000000);
			graphics.moveTo(x + corners[10] * hexSize * 0.5, y + corners[11] * hexSize * perspective * 0.5);
			for (var i:int = 0; i < 12; i+=2) {
				graphics.lineTo(x + corners[i] * hexSize * 0.5, y + corners[i + 1] * hexSize*perspective * 0.5);
			}
			graphics.lineStyle();
			
			if (object) {
				object.render(graphics, x, y, 0, 1);
			}
		}
		
		public function canMoveHere(selected:Hex):Boolean {
			if (!selected.object) return false;
			var mover:HexMover = selected.object.getComponentByClass(HexMover) as HexMover;
			if (!mover) return false;
			if (mover.path && mover.path.length > 0 && mover.path[0] == this) {
				mover.go();
			} else {
				mover.path = HexDijkstra.findPath(grid, selected, this);
				mover.markPath();
			}
			return (mover.path != null);
			
		}
		
		public function onClick(selected:Hex):Boolean{
			if (this.object == null) {
				canMoveHere(selected);
				return false;
			}
			return true;
		}
		
		
	}

}