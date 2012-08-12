package nl.jorisdormans.phantomextra.components.platformer 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.objects.CollisionData;
	import nl.jorisdormans.phantom2D.objects.GameObject;
	import nl.jorisdormans.phantom2D.objects.Mover;
	import nl.jorisdormans.phantom2D.objects.renderers.BoundingShapeRenderer;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PlatformerMover extends Mover
	{
		public static var xmlDescription:XML = <PlatformerMover velocityX="Number" velocityY="Number" velocityZ="Number" gravity="Number" acceleration="Number" jumpPower="Number" platformFriction="Number" airFriction="Number" bounceRestitution="Number" gripBounceRestitution="0.1"/>;
		public static var xmlDefault:XML = <PlatformerMover velocityX="0" velocityY="0" velocityZ="0" gravity="1400" acceleration="800" jumpPower="320" platformFriction="4.0" airFriction="1.0" bounceRestitution="0.5" gripBounceRestitution="0.1"/>;
		
		public static var onPlatformThreshold:Number = 0.3;
		public static var platformDotProduct:Number = 0.7;
		public static var p:Vector3D = new Vector3D();
		
		
		public static function generateFromXML(xml:XML):Component {
			var comp:Component = new PlatformerMover(new Vector3D());
			comp.readXML(xml);
			return comp;
		}
		
		public var currentPlatform:GameObject;
		private var onPlatform:Number;
		
		public var moving:Number;
		private var acceleration:Number;
		
		public var jumping:Number;
		private var jumpPower:Number;
		private var jumpBoost:Number;
		
		private var defaultPlatformFriction:Number;
		private var airFriction:Number;
		private var currentPlatformFriction:Number;
		
		private var gravityForce:Number;
		private var gravityDirection:Vector3D;
		
		private var gripBounceRestitution:Number;
		private var defaultBounceRestitution:Number;
		
		
		public function PlatformerMover(velocity:Vector3D, friction:Number = 2, bounceRestitution:Number = 0.5) 
		{
			super(velocity, friction, bounceRestitution, true);
			currentPlatform = null;
			onPlatform = 0;
			moving = 0;
			acceleration = 800;
			jumpPower = 320;
			defaultPlatformFriction = 4;
			airFriction = 1;
			currentPlatformFriction = defaultPlatformFriction;
			gravityForce = 1400;
			gravityDirection = new Vector3D(0, 1);
			defaultBounceRestitution = bounceRestitution;
			gripBounceRestitution = 0.1;
		}
		
		override public function generateXML():XML 
		{
			var xml:XML = super.generateXML();
			xml.@gravity = gravityForce;
			xml.@acceleration = acceleration;
			xml.@jumpPower = jumpPower;
			xml.@platformFriction = defaultPlatformFriction;
			xml.@airFriction = airFriction;
			return xml;
		}
		
		override public function readXML(xml:XML):void 
		{
			super.readXML(xml);
			if (xml.@gravity.length() > 0) gravityForce = xml.@gravity;
			if (xml.@acceleration.length() > 0) acceleration = xml.@acceleration;
			if (xml.@jumpPower.length() > 0) jumpPower = xml.@jumpPower;
			if (xml.@platformFriction.length() > 0) defaultPlatformFriction = xml.@platformFriction;
			if (xml.@airFriction.length() > 0) airFriction = xml.@airFriction;
			if (xml.@gripBounceRestitution.length() > 0) gripBounceRestitution = xml.@gripBounceRestitution;
			defaultBounceRestitution = bounceRestitution;
			currentPlatformFriction = defaultPlatformFriction;
		}
		
		override public function updatePhysics(elapsedTime:Number):void 
		{
			super.updatePhysics(elapsedTime);
			
			//apply gravity
			velocity.x += elapsedTime * gravityForce * gravityDirection.x;
			velocity.y += elapsedTime * gravityForce * gravityDirection.y;
			
			//apply moving
			velocity.x += elapsedTime * acceleration * moving * gravityDirection.y;
			velocity.y += elapsedTime * acceleration * moving * -gravityDirection.x;
			
			onPlatform *= 0.9;
			if (onPlatform > onPlatformThreshold) {
				if (moving != 0) {
					friction = airFriction;
				} else {
					friction = currentPlatformFriction;
				}
			} else {
				leavePlatform();
			}
			
			jumpBoost -= Math.min(elapsedTime, jumpBoost);
			
			if (jumping>0) {
				if (jumpBoost>0 && velocity.y<0) {
					velocity.y -= jumpPower * elapsedTime * 12;
				}
			}
		}
		
		public function isOnPlatform():Boolean {
			return onPlatform > onPlatformThreshold;
		}
		
		override public function respondToCollision(collision:CollisionData, other:GameObject, factor:Number):void 
		{
			super.respondToCollision(collision, other, factor);
			if (collision.normal.y > platformDotProduct) {
				onPlatform = 1;
				bounceRestitution = gripBounceRestitution;
				if (currentPlatform != other) {
					//if (currentPlatform) currentPlatform.sendMessage(BoundingShapeRenderer.M_SET_RENDER_STYLE, { strokeWidth:-1 } );
					currentPlatform = other;
					var f:Object = other.getProperty(PlatformFriction.P_FRICTION);
					if (f != null) {
						currentPlatformFriction = f as Number;
					} else {
						currentPlatformFriction = defaultPlatformFriction;
					}
					//if (currentPlatform) currentPlatform.sendMessage(BoundingShapeRenderer.M_SET_RENDER_STYLE, { strokeWidth:2, strokeColor:0xffffff } );
				}
				if (currentPlatformFriction>airFriction) {
					gravityDirection.x = collision.normal.x;
					gravityDirection.y = collision.normal.y;
				} else {
					gravityDirection.x = 0;
					gravityDirection.y = 1;
				}
			} else {
				bounceRestitution = defaultBounceRestitution;
			}
		}
		
		public function jump():void {
			if (isOnPlatform()) {
				velocity.y = -jumpPower;
				jumpBoost = 0.25;
				leavePlatform();
			}
		}
		
		private function leavePlatform():void 
		{
			friction = airFriction;
			gravityDirection.x = 0;
			gravityDirection.y = 1;
			//if (currentPlatform) currentPlatform.sendMessage(BoundingShapeRenderer.M_SET_RENDER_STYLE, { strokeWidth:-1 } );
			currentPlatform = null;
			onPlatform = 0;
		}
		
		
	}

}