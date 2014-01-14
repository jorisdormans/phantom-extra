package nl.jorisdormans.phantomextra.graphics 
{
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.core.Phantom;
	import nl.jorisdormans.phantom2D.objects.IRenderable;
	import mx.core.MovieClipAsset;
	import flash.events.Event;
	import flash.display.LoaderInfo;
	/**
	 * ...
	 * @author ...
	 */
	public class PhantomSprite
	{
		private var _width:uint;
		private var _height:uint;
		private var mat:Matrix;
		private var frames:Vector.<BitmapData>;
		
		private var frameW:int;
		private var frameH:int;
		
		private var clipW:int;
		private var clipH:int;
		
		private var framesX:int;
		private var framesY:int;
		
		private var inst:IBitmapDrawable;
		
		private var loader:Loader;
		
		public function PhantomSprite( img:Class, width:int = 0, height:int = 0 )
		{
			inst = new img();
			
			frameW = width;
			frameH = height;
			
			if (inst is Bitmap)
			{
				clipW = (inst as Bitmap).width;
				clipH = (inst as Bitmap).height;
				
				if (frameW == 0) frameW = clipW;
				if (frameH == 0) frameH = clipH;
				
				this._width = frameW;
				this._height = frameH;
				
				loaded();
			}
			else
			{
				if (inst is AVM1Movie)
				{
					clipW = (inst as AVM1Movie).width;
					clipH = (inst as AVM1Movie).height;
				}
				else if (inst is MovieClip)
				{
					clipW = (inst as MovieClip).width;
					clipH = (inst as MovieClip).height;
				}
				
				if (frameW == 0) frameW = clipW;
				if (frameH == 0) frameH = clipH;
				
				this._width = frameW;
				this._height = frameH;
				
				var asset:MovieClipAsset = new img();				
				loader = Loader(asset.getChildAt(0));
				var info:LoaderInfo = loader.contentLoaderInfo;
				info.addEventListener(Event.COMPLETE, onLoadComplete);
			}
		}
		
		private function onLoadComplete(event:Event):void
        {
            var info:LoaderInfo = LoaderInfo(event.target);
            info.removeEventListener(Event.COMPLETE, onLoadComplete);
			
            inst = IBitmapDrawable(info.loader.content);
			
			loaded();
        }
		
		private function loaded():void
		{
			this.framesX = (clipW / this.width);
			this.framesY = (clipH / this.height);
			
			this.mat = new Matrix();
			this.mat.identity();
			
			//this.frameCount = this.framesX * this.framesY;
			//this.frame = 0;
			
			frames = new Vector.<BitmapData>();
			for (var y:int = 0; y < framesY; y++) {
				for (var x:int = 0; x < framesX; x++) {
					var fx:Number = this.width * x;
					var fy:Number = this.height * y;
					
					this.mat.identity();
					this.mat.translate( -fx, -fy);
					
					var bmpData:BitmapData = new BitmapData(this.width, this.height, true, 0x00888888);
					bmpData.draw(inst, mat);
					frames.push(bmpData);
				}
			}
			
			inst = null;
		}
		
		public function renderFrame(graphics:Graphics, x:Number, y:Number, frame:int, angle:Number = 0, zoom:Number = 1):void 
		{
			if (inst == null)
			{
				if (frame<0 || frame >= frames.length) return;
				var dx:Number = x - (this.width / 2) * zoom;
				var dy:Number = y - (this.height / 2) * zoom;
				
				this.mat.identity();
				this.mat.translate( - this.width * 0.5, - this.height * 0.5);

				/*if ( horizontalFlip )
					angle += Math.PI;
				if ( verticalFlip )
					angle += Math.PI;
				angle %= Math.PI*2;*/
				
				this.mat.rotate(angle);
				//this.mat.scale( (horizontalFlip ? -1 : 1)* zoom, (verticalFlip ? -1 : 1) * zoom);
				this.mat.scale( zoom, zoom);
				
				this.mat.translate( dx + this.width * 0.5*zoom, dy + this.height * 0.5*zoom );
				
				graphics.beginBitmapFill(this.frames[frame], this.mat, false, true);
				graphics.drawRect(dx, dy, this.width*zoom, this.height*zoom);
				graphics.endFill();
			}
		}	
		
		public function renderFast(graphics:Graphics, x:Number, y:Number, frame:int):void {
			if (inst == null)
			{
				if (frame<0 || frame >= frames.length) return;
				var dx:Number = x - (this.width / 2);
				var dy:Number = y - (this.height / 2);
				
				this.mat.identity();
				this.mat.translate( - this.width * 0.5, - this.height * 0.5);
				this.mat.translate( dx + this.width * 0.5, dy + this.height * 0.5 );
				
				graphics.beginBitmapFill(this.frames[frame], this.mat, false, true);
				graphics.drawRect(dx, dy, this.width, this.height);
				graphics.endFill();
			}
		}
		
		public function get width():uint 
		{
			return _width;
		}
		
		public function get height():uint 
		{
			return _height;
		}
		
		public function get frameCount():uint {
			return frames.length;
		}
			
	}

}