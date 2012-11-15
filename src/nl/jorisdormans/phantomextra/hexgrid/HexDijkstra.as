package nl.jorisdormans.phantomextra.hexgrid 
{
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class HexDijkstra 
	{
		private static var check:Vector.<Hex> = new Vector.<Hex>();
		
		public function HexDijkstra() 
		{
			
		}
		
		public static function findPath(grid:HexGridLayer, start:Hex, end:Hex):Vector.<Hex> {
			//clear all marks
			grid.clearMarks();
			grid.clearDistance();
			start.distance = 0;
			
			while (check.length > 0) check.pop();
			
			var it:int = grid.hexes.length;
			
			while (end.mark == 0) {
				for (var i:int = 0; i < start.neighbors.length; i++) {
					var checking:Hex = start.neighbors[i];
					if (checking && checking.mark == 0 && (checking.object == null || checking == end)) {
						if (checking.distance > start.distance + 1) {
							checking.distance = start.distance + 1;
							check.push(checking);
						}
					}
				}
				start.mark = 1;
				start = check.shift();
				it--;
				if (it<=0 || start == null) {
					grid.clearMarks();
					return null;
				}
			}
			
			var path:Vector.<Hex> = new Vector.<Hex>();
			while (end.distance>0) {
				path.push(end);
				var closest:Hex;
				var distance:int = end.distance;
				for (i = 0; i < end.neighbors.length; i++) {
					checking = end.neighbors[i];
					if (checking && checking.distance < distance) {
						distance = checking.distance;
						closest = checking;
					}
				}
				end = closest;
				
				it--;
				if (it<=0) return null;
			}
			
			grid.clearMarks();
			
			return path;
		}
		
		
	}

}