package nl.jorisdormans.phantomextra.components.spawners 
{
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.core.Composite;
	import nl.jorisdormans.phantom2D.core.ContentManager;
	import nl.jorisdormans.phantom2D.core.PhantomGame;
	import nl.jorisdormans.phantom2D.objects.GameObject;
	import nl.jorisdormans.phantom2D.objects.GameObjectComponent;
	import nl.jorisdormans.phantom2D.objects.ObjectFactory;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class Spawner extends GameObjectComponent
	{
		public static var xmlDescription:XML = <Spawner recipe="String" count="int" delay="Number"/>;
		public static var xmlDefault:XML = <Spawner recipe="" count="1" delay="0.5"/>;
		
		public static function generateFromXML(xml:XML):Component {
			var comp:Component = new Spawner();
			comp.readXML(xml);
			return comp;
		}		
		
		
		private var recipe:XML;
		private var recipeId:String;
		private var spawnedObjects:Vector.<GameObject>
		private var count:int;
		private var delay:Number;
		private var timer:Number;
		
		public function Spawner() 
		{
			count = 1;
			delay = 0.5;
			recipe = null;
			timer = 0;
			spawnedObjects = new Vector.<GameObject>();
		}
		
		override public function onAdd(composite:Composite):void 
		{
			super.onAdd(composite);
			gameObject.doResponse = false;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@recipe = recipeId;
			xml.@count = count;
			xml.@delay = delay;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			recipe = null;
			if (xml.@recipe.length() > 0) recipeId = xml.@recipe; 
			if (xml.@count.length() > 0) count = xml.@count;
			if (xml.@delay.length() > 0) delay = xml.@delay;
		}
		
		override public function update(elapsedTime:Number):void 
		{
			for (var i:int = spawnedObjects.length - 1; i >= 0; i--) {
				if (spawnedObjects[i].destroyed) {
					spawnedObjects.splice(i, 1);
				}
			}
			if (count > spawnedObjects.length) {
				timer += elapsedTime;
				if (delay <= timer) {
					timer = 0;
					spawn();
					
				}
			}
			super.update(elapsedTime);
		}
		
		protected function spawn():GameObject {
			if (!recipe) {
				recipe = ContentManager.getInstance().getObject(recipeId);
			}
			if (recipe) {
				var go:GameObject = ObjectFactory.getInstance().generateFromXML(recipe);
				if (go) {
					spawnedObjects.push(go);
					this.gameObject.objectLayer.addGameObjectSorted(go, this.gameObject.position.clone());
				}
				return go;
			} else {
				return null;
			}
		}
		
		override public function reset():void 
		{
			super.reset();
			while (spawnedObjects.length > 0) {
				spawnedObjects.pop().destroyed = true;
			}
		}
		
	}

}