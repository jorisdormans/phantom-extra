package nl.jorisdormans.phantomextra.components.platformer 
{
	import nl.jorisdormans.phantom2D.core.Component;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PlatformFriction extends Component
	{
		/**
		 * Gets the friction value. Returns a Number;
		 */
		static public const P_FRICTION:String = "friction";
		
		public static var xmlDescription:XML = <PlatformFriction friction="Number"/>;
		public static var xmlDefault:XML = <PlatformFriction friction="4.0"/>;
		
		public static function generateFromXML(xml:XML):Component {
			var comp:Component = new PlatformFriction();
			comp.readXML(xml);
			return comp;
		}
		
		private var friction:Number;
		
		public function PlatformFriction(friction:Number = 4.0) 
		{
			this.friction = friction;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@friction = friction;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			if (xml.@friction.length() > 0) friction = xml.@friction;
		}
		
		override public function getProperty(property:String, data:Object = null, componentClass:Class = null):Object 
		{
			if (property == P_FRICTION) return friction;
			return super.getProperty(property, data, componentClass);
		}
		
		
		
		
		
	}

}