package nl.jorisdormans.phantomextra.components.spawners 
{
	import nl.jorisdormans.phantom2D.cameras.FollowObject;
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.objects.GameObject;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class SavePoint extends Spawner
	{
		public static var xmlDescription:XML = <SavePoint recipe="String" delay="Number" active="Boolean"/>;
		public static var xmlDefault:XML = <SavePoint recipe="" delay="0.5" active="false"/>;
		
		public static function generateFromXML(xml:XML):Component {
			var comp:Component = new SavePoint();
			comp.readXML(xml);
			return comp;
		}		
		
		public var active:Boolean;
		
		public function SavePoint() 
		{
			active = false;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			if (xml.@active.length() > 0) active = (xml.@active == "true");
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@active = active ? "true" : "false";
			return xml;
		}
		
		override protected function spawn():GameObject 
		{
			var player:GameObject = super.spawn();
			gameObject.objectLayer.screen.camera.handleMessage(FollowObject.M_FOLLOW_OBJECT, { followObject: player } );
			return player;
		}
		
		override public function update(elapsedTime:Number):void 
		{
			if (active) {
				super.update(elapsedTime);
			}
		}
		
	}

}