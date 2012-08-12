package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import nl.jorisdormans.phantom2D.core.Screen;
	import nl.jorisdormans.phantomextra.core.PhantomExtraGame;
	
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Main extends PhantomExtraGame 
	{
		
		public function Main():void 
		{
			super(800, 600);
			addScreen(new Screen());
			
		}
	}
	
}