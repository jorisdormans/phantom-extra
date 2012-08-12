package nl.jorisdormans.phantomextra.core 
{
	import flash.events.Event;
	import nl.jorisdormans.phantom2D.core.PhantomGame;
	import com.furusystems.dconsole2.DConsole;
	import nl.jorisdormans.phantom2D.objects.ObjectFactory;
	import nl.jorisdormans.phantomextra.components.platformer.*;
	import nl.jorisdormans.phantomextra.components.spawners.*;
	import nl.jorisdormans.phantomextra.editor.Editor;
	
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PhantomExtraGame extends PhantomGame
	{
		public static var addDConsole:Boolean;
		public static var loggingToConsole:Boolean;
		private var consoleAdded:Boolean;
		
		public function PhantomExtraGame(width:Number, height:Number) 
		{
			addDConsole = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			super(width, height);
			registerExtraComponents();
		}
		
		private function onEnterFrame(e:Event):void 
		{
			if (addDConsole) {
				PhantomGame.log("Adding Doomsday Console...", PhantomGame.LOG_INFO, PhantomGame.LOG_TAG);
				//add DConsole
				addChild(DConsole.view);
				//by default, the console toggles on ctrl+shift+enter, but can also be shown with DConsole.show() and hidden with DConsole.hide()
				//DConsole.show();
				addDConsoleCommands();
				consoleAdded = true;
			}
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function registerExtraComponents():void 
		{
			ObjectFactory.getInstance().components["Spawner"] = Spawner;
			ObjectFactory.getInstance().components["SavePoint"] = SavePoint;
			
			ObjectFactory.getInstance().components["PlatformerKeyHandler"] = PlatformerKeyHandler;
			ObjectFactory.getInstance().components["PlatformerMover"] = PlatformerMover;
			ObjectFactory.getInstance().components["PlatformFriction"] = PlatformFriction;
		}
		
		
		protected function addDConsoleCommands():void {
			DConsole.createCommand("showDebugInfo", showDebugInfo);
			DConsole.createCommand("hideDebugInfo", hideDebugInfo);
			DConsole.createCommand("showFPS", showFPS);
			DConsole.createCommand("hideFPS", hideFPS);
			DConsole.createCommand("showProfiler", showProfiler);
			DConsole.createCommand("hideProfiler", hideProfiler);
			DConsole.createCommand("editor", showEditor);
		}
		
		private function showEditor():void 
		{
			if (!(currentScreen is Editor)) {
				DConsole.hide();
				addScreen(new Editor());
			}
		}
		
		override public function log(message:String, type:String = "Info", tag:String = ""):void {
			if (consoleAdded && loggingToConsole) {
				DConsole.console.print(message, type, tag)
			} else {
				super.log(message, type, tag);
			}
		}		
		
		
	}

}