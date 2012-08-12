package nl.jorisdormans.phantomextra.components.platformer 
{
	import nl.jorisdormans.phantom2D.core.Component;
	import nl.jorisdormans.phantom2D.core.Composite;
	import nl.jorisdormans.phantom2D.core.InputState;
	import nl.jorisdormans.phantom2D.objects.GameObjectComponent;
	import nl.jorisdormans.phantom2D.objects.IInputHandler;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class PlatformerKeyHandler extends GameObjectComponent implements IInputHandler
	{
		/**
		 * Event generated when the direction changes. Passes data: {direction:int} where direction indicates the direction on horizontal axis (1 is facing right, -1 is facing left)
		 */
		public static const E_CHANGE_DIRECTION:String = "changeDirection";
		
		public static var xmlDescription:XML = <PlatformerKeyHandler />;
		public static var xmlDefault:XML = <PlatformerKeyHandler />;
		
		public static function generateFromXML(xml:XML):Component {
			var comp:Component = new PlatformerKeyHandler();
			comp.readXML(xml);
			return comp;
		}
		
		private var direction:int;
		private var platformerMover:PlatformerMover;
		
		public function PlatformerKeyHandler() 
		{
			this.direction = 1;
		}
		
		override public function onAdd(composite:Composite):void 
		{
			super.onAdd(composite);
			platformerMover = gameObject.mover as PlatformerMover
			if (!platformerMover) {
				throw new Error("PlatformerKeyHandler requires that this GameObject has a PlatformerMover component.");
			}
		}
		
		public function handleInput(elapsedTime:Number, currentState:InputState, previousState:InputState):void 
		{
			var dx:int= 0;
			var dy:int= 0;
			if (currentState.arrowLeft) dx -= 1;
			if (currentState.arrowRight) dx += 1;
			if (currentState.arrowUp) dy -= 1;
			if (currentState.arrowDown) dy += 1;
			
			platformerMover.moving = dx;
			if (dx!=0) {
				if (direction != dx) {
					direction = dx;
					parent.handleMessage(E_CHANGE_DIRECTION, { direction: direction } );
				}
			}
			
			if (dx != 0 || dy != 0) {
				//if (dx * platformerMover.velocity.x < -300) dx = 0;
				gameObject.objectLayer.screen.camera.handleMessage(PlatformerLookCamera.M_CAMERA_LOOK, { dx : dx * elapsedTime * PlatformerLookCamera.lookSpeedX, dy: dy * elapsedTime * PlatformerLookCamera.lookSpeedY } );
			}
			
			if (currentState.keySpace && !previousState.keySpace) {
				platformerMover.jump();
			}
			
			if (currentState.keySpace) {
				platformerMover.jumping = 1;
			} else {
				platformerMover.jumping = 0;
			}
			
			
			
			
		}
		
	}

}