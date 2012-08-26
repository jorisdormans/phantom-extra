package nl.jorisdormans.phantomextra.turbulence 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.core.Composite;
	import nl.jorisdormans.phantom2D.core.Layer;
	import nl.jorisdormans.phantom2D.core.PhantomGame;
	import nl.jorisdormans.phantom2D.core.Screen;
	import nl.jorisdormans.phantom2D.util.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class TurbulanceGrid extends Layer
	{
		private var cellSize:Number;
		private var cells:Vector.<TurbulenceCell>;
		private var cellsX:int;
		private var cellsY:int;
		private var splicing:int;
		private var currentSplice:int;
		private var turbulance:Number;
		
		public function TurbulanceGrid(cellSize:Number, turbulance:Number, splicing:int = 4) 
		{
			this.turbulance = turbulance;
			this.cellSize = cellSize;
			this.splicing = splicing;
			this.currentSplice = 0;
		}
		
		override public function onAdd(composite:Composite):void 
		{
			super.onAdd(composite);
			
			var screen:Screen = getParentByType(Screen) as Screen;
			if (!screen) {
				throw new Error("TurbulanceGrid needs an Screen as parent or ancestor."); 
			}
			
			cellsX = screen.screenWidth / cellSize;
			cellsY = screen.screenHeight / cellSize;
			
			layerWidth = cellsX * cellSize;
			layerHeight = cellsY * cellSize;
			
			cells = new Vector.<TurbulenceCell>();
			
			for (var y:int = 0; y < cellsY; y++) {
				for (var x:int = 0; x < cellsX; x++) {
					cells.push(new TurbulenceCell());
				}
			}
			
			for (y = 0; y < cellsY; y++) {
				for (x = 0; x < cellsX; x++) {
					var i:int = x + y * cellsX;
					if (y%2 == 0) {
						cells[i].addNeighbour(cells[(x + 1) % cellsX          + y * cellsX]);
						//cells[i].addNeighbour(cells[(x + 1) % cellsX          + ((y + 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[x                         + ((y + 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + ((y + 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + y * cellsX]);
						cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + ((y + cellsY - 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[x                         + ((y + cellsY - 1) % cellsY) * cellsX]);
						//cells[i].addNeighbour(cells[(x + 1) % cellsX          + ((y + cellsY - 1) % cellsY) * cellsX]);
					} else {
						cells[i].addNeighbour(cells[(x + 1) % cellsX          + y * cellsX]);
						cells[i].addNeighbour(cells[(x + 1) % cellsX          + ((y + 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[x                         + ((y + 1) % cellsY) * cellsX]);
						//cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + ((y + 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + y * cellsX]);
						//cells[i].addNeighbour(cells[(x + cellsX - 1) % cellsX + ((y + cellsY - 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[x                         + ((y + cellsY - 1) % cellsY) * cellsX]);
						cells[i].addNeighbour(cells[(x + 1) % cellsX          + ((y + cellsY - 1) % cellsY) * cellsX]);
					}
				}
			}
			
			for (i = 0; i < 150; i++) update(1 / 20);
			
		}
		
		override public function render(camera:Camera):void 
		{
			super.render(camera);
			/*
			for (var y:int = 0; y < cellsY; y++) {
				for (var x:int = 0; x < cellsX; x++) {
					cells[x+y*cellsX].render(sprite.graphics, x * cellSize + (y % 2) * cellSize*0.5, y * cellSize, cellSize);
				}
			}
			//*/
		}
		
		override public function update(elapsedTime:Number):void 
		{
			PhantomGame.profiler.begin("turbulence update");
			super.update(elapsedTime);
			for (var i:int = currentSplice; i < cells.length; i += splicing) {
				cells[i].update(elapsedTime * splicing*turbulance, turbulance);
			}
			for (i = currentSplice; i < cells.length; i += splicing) {
				cells[i].applyChanges();
			}
			currentSplice++;
			currentSplice %= splicing;
			PhantomGame.profiler.end("turbulence update");
		}
		
		public function getTurbulenceX(px:Number, py:Number):Number
		{
			/*var fy:Number = ((position.y + height) % height) / cellSize;
			var y:int = Math.floor(fy);
			fy -= y;
			
			var fx:Number = ((position.x + width - (y%2)*cellSize*0.5) % width) / cellSize;
			var x:int = Math.floor(fx);
			fx -= x;*/
			
			var y:int = MathUtil.clamp(Math.floor(((py + layerHeight) % layerHeight) / cellSize), 0, cellsY);
			var x:int = MathUtil.clamp(Math.floor(((px + layerWidth - (y % 2) * cellSize * 0.5) % layerWidth) / cellSize), 0, cellsX);
			
			var cell:TurbulenceCell = cells[x + y * cellsX];
			
			return cell.turbulenceX();
			
			//var r:Number = (cell.turbulenceX() * (1 - fx) + cell.right.turbulenceX() * (1 - fx)) *(1-fy);
			//r += (cell.down.turbulenceX() * (1 - fx) + cell.down.right.turbulenceX() * (1 - fx)) * fy;
			//return r;
			
		}
		
		public function getTurbulenceY(px:Number, py:Number):Number
		{
			/*var fy:Number = ((position.y + layerHeight) % layerHeight) / cellSize;
			var y:int = Math.floor(y);
			fy -= y;
			
			var fx:Number = ((position.x + layerWidth - (y%2)*cellSize*0.5) % layerWidth) / cellSize;
			var x:int = Math.floor(x);
			fx -= x;*/
			
			var y:int = MathUtil.clamp(Math.floor(((py + layerHeight) % layerHeight) / cellSize), 0, cellsY);
			var x:int = MathUtil.clamp(Math.floor(((px + layerWidth - (y%2)*cellSize*0.5) % layerWidth) / cellSize), 0, cellsX);
			
			var cell:TurbulenceCell = cells[x + y * cellsX];
			
			return cell.turbulenceY();
			
			//var r:Number = (cell.turbulenceY() * (1 - fx) + cell.right.turbulenceY() * (1 - fx)) *(1-fy);
			//r += (cell.down.turbulenceY() * (1 - fx) + cell.down.right.turbulenceY() * (1 - fx)) * fy;
			//return r;
			
		}
		
	}

}