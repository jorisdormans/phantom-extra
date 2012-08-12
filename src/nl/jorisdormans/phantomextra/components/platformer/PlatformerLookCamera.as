package nl.jorisdormans.phantomextra.components.platformer 
{
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.CameraComponent;
	import nl.jorisdormans.phantom2D.core.Phantom;
	import nl.jorisdormans.phantom2D.util.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PlatformerLookCamera extends CameraComponent
	{
		/**
		 * Changes the current camera look position. Takes input {dx: Number, dy:Number}.
		 */
		public static const M_CAMERA_LOOK:String = "cameraLook";
		private var lookX:Number;
		private var lookY:Number;
		private var distanceX:Number;
		private var distanceY:Number;
		private var lookingUpOrDown:Number;
		private var target:Vector3D;
		
		public static var lookSpeedX:Number = 2.5;
		public static var lookSpeedY:Number = 1.5;
		public static var releaseSpeedY:Number = 0.75;
		
		public function PlatformerLookCamera(distanceX:Number, distanceY:Number) 
		{
			this.distanceX = distanceX;
			this.distanceY = distanceY;
			lookX = 0;
			lookY = 0;
			lookingUpOrDown = 0;
			target = new Vector3D();
		}
		
		override public function update(elapsedTime:Number):void 
		{
			super.update(elapsedTime);
			
			target.x = camera.target.x;
			target.y = camera.target.y;
			
			camera.target.x += lookX * distanceX;
			camera.target.y += lookY * distanceY;
			
			if (lookingUpOrDown > 0) {
				lookingUpOrDown -= elapsedTime;
			} else {
				if (lookY > 0) {
					lookY -= Math.min(elapsedTime * releaseSpeedY, lookY);
				} else if (lookY < 0) {
					lookY += Math.min(elapsedTime * releaseSpeedY, -lookY);
				}
			}
			
		}
		
		override public function handleMessage(message:String, data:Object = null, componentClass:Class = null):int 
		{
			if (message == M_CAMERA_LOOK) {
				lookX = (camera.position.x - target.x) / distanceX;
				lookY = (camera.position.y - target.y) / distanceY;
				
				lookX = MathUtil.clamp(lookX + data.dx, -1, 1);
				lookY = MathUtil.clamp(lookY + data.dy, -1, 1);
				if (data.dy != 0) {
					lookingUpOrDown = 0.05;
				}
				
				return Phantom.MESSAGE_CONSUMED;
			}
			
			return super.handleMessage(message, data);
		}
		
	}

}