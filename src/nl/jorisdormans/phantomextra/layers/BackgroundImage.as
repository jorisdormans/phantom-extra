package nl.jorisdormans.phantomextra.layers 
{
	import flash.display.Bitmap;
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.core.Layer;
	import nl.jorisdormans.phantomextra.graphics.PhantomSprite;
	import nl.jorisdormans.phantomextra.graphics.PhantomSpriteRenderer;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class BackgroundImage extends Layer
	{
		
		public function BackgroundImage(image:Class) 
		{
			super();
			
			var spr:PhantomSpriteRenderer = new PhantomSpriteRenderer(new PhantomSprite(image));
			spr.offset = new Vector3D(layerWidth / 2.0, layerHeight / 2.0);
			addComponent(spr);
		}
	}

}