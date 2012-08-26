package nl.jorisdormans.phantomextra.advancedparticles 
{
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	import nl.jorisdormans.phantom2D.cameras.Camera;
	import nl.jorisdormans.phantom2D.objects.GameObject;
	import nl.jorisdormans.phantom2D.util.DrawUtil;
	import nl.jorisdormans.phantom2D.util.MathUtil;
	/**
	 * ...
	 * @author Joris Dormans
	 */
	public class AdvancedParticle 
	{
		/**
		 * Specifies how long a particle has left to live (in seconds)
		 */
		public var life:Number;
		/**
		 * Specifies how long a particle has been living (in seconds)
		 */
		protected var living:Number;
		/**
		 * The particle's current position
		 */
		public var x:Number;
		public var y:Number;
		/**
		 * The particle's current velocity
		 */
		private var vx:Number;
		private var vy:Number;
		
		/**
		 * The particle's current gravity
		 */
		private var gx:Number;
		private var gy:Number;
		
		private var windEffect:Number;
		
		
		private var drag:Number;
		/**
		 * The particle's current color
		 */
		public var color1:uint;
		public var color2:uint;
		public var color3:uint;
		
		public var layer:AdvancedParticleLayer;
		
		public var next:AdvancedParticle;
		
		public var type:int;
		
		private var size:Number;
		private var currentSize:Number;
		
		private var random1:Number;
		private var random2:Number;
		private var random3:Number;
		private var data:Number;
		private static var p:Vector3D = new Vector3D();
		
		public static const TYPE_NONE:int = -1;
		public static const TYPE_TEST:int = 0;
		public static const TYPE_SMOKE:int = 2;
		public static const TYPE_STEAM:int = 3;
		public static const TYPE_FIRE:int = 4;
		public static const TYPE_SPARK:int = 5;
		public static const TYPE_SNOW:int = 10;
		public static const TYPE_SNOW_LYING:int = 11;
		public static const TYPE_RAIN:int = 12;
		public static const TYPE_RAIN_SPLASH:int = 13;
		
		public function AdvancedParticle() 
		{
			
		}
		
		/**
		 * Creates an instance of the particle class
		 * @param	life		The number of seconds a particle will live
		 * @param	position	The starting position
		 * @param	velocity	The initial velocity
		 */
		public function initialize(layer:AdvancedParticleLayer, type:int, life:Number, size:Number, x:Number, y:Number, vx:Number = 0, vy:Number = 0, data:Number = 0):void
		{
			this.data = data;
			this.layer = layer;
			this.type = type;
			this.living = 0;
			this.life = life;
			this.x = x;
			this.y = y;
			this.vx = vx;
			this.vy = vy;
			this.color1 = 0xffffff;
			this.color2 = 0xffffff;
			this.color3 = 0xffffff;
			this.drag = 1.0;
			this.size = size;
			this.gx = 0;
			this.gy = 0;
			this.windEffect = 0;
			this.random1 = Math.random();
			this.random2 = Math.random();
			this.random3 = Math.random();
			
			switch (type) {
				case TYPE_SMOKE:
					this.gy = -80 - 12 * this.size;
					this.windEffect = 140+this.size*2;
					this.drag = 0.95;
					color1 = 0x000000;
					color2 = 0x111111;
					color3 = 0x222222;
					this.vx += (Math.random() - Math.random()) * 10;
					break;
				case TYPE_STEAM:
					this.gy = -80 - 12 * this.size;
					this.windEffect = 140+this.size*2;
					this.drag = 0.95;
					color1 = 0xd0d0ff;
					color2 = 0xe8e8ff;
					color3 = 0xffffff;
					this.vx += (Math.random() - Math.random()) * 10;
					
					break;
				case TYPE_FIRE:
					this.gy = -40 - 8 * this.size;
					this.windEffect = 70+this.size*2;
					this.drag = 0.91;
					color1 = 0xff0000;
					color2 = 0xff4400;
					color3 = 0xffff00;
					this.vx += (Math.random() - Math.random()) * 10;
					
					if (Math.random() < size * 0.0005+0.03) {
						layer.addParticle(AdvancedParticle.TYPE_SPARK, 3+Math.random()*2, 10, x + (Math.random()-Math.random())*size, y - (Math.random()+Math.random())*size);
					}
					break;
				case TYPE_SPARK:
					this.gy = -60;
					this.windEffect = 100;
					this.drag = 0.91;
					this.vx += (Math.random() - Math.random()) * 30;
					this.vy -= (Math.random() + Math.random()) * 120;
					break;
				case TYPE_SNOW:
					this.gy = 150+data*150;
					this.windEffect = 100+data*100;
					this.drag = 0.98;
					this.size = 4 + data * 3 + Math.random();
					this.vy += (Math.random() + Math.random()) * 6 * size;
					this.color1 = DrawUtil.lerpColor(0x88ccff, 0xffffff, MathUtil.clamp(data, 0, 1));
					this.random2 = this.random3*4+1;
					if (Math.random() < 0.5) random2 *= -1;
					break;
				case TYPE_RAIN:
					this.gy = 550+data*350;
					this.windEffect = 350+data*250;
					this.drag = 0.98;
					this.size = 2 + data * 1;
					this.vy += (Math.random() + Math.random()) * 60 * (1+data);
					this.color1 = DrawUtil.lerpColor(0x222266, 0x111122, MathUtil.clamp(data, 0, 1));
					break;
			}
			
			update(0);
		}
		
		/**
		 * Updates a particle's position and life.
		 * @param	elapsedTime
		 */
		public function update(elapsedTime:Number):void {
			if (type == TYPE_SNOW_LYING) {
				life -= elapsedTime;
				this.currentSize = Math.min(this.size, life*10);
				if (life <= 0) {
					type = TYPE_SNOW;
					life = 100;
					x = Math.random() * layer.layerWidth;
					y = 0;
				}
				return;
			}
			
			life -= elapsedTime;
			living += elapsedTime;
			x += vx * elapsedTime;
			y += vy * elapsedTime;
			
			if (layer.turbulenceGrid && windEffect > 0) {
				vx += layer.turbulenceGrid.getTurbulenceX(x, y) * elapsedTime * windEffect;
				vy += layer.turbulenceGrid.getTurbulenceY(x, y) * elapsedTime * windEffect;
			}
			if (layer.wind && windEffect > 0) {
				vx += layer.wind.windStrength * elapsedTime * windEffect *2.0;
			}
			
			vx += gx * elapsedTime;
			vy += gy * elapsedTime;
			
			vx *= drag;
			vy *= drag;
			
			if (type == TYPE_SNOW || type == TYPE_RAIN) {
				p.x = x;
				p.y = y;
				var o:GameObject;
				if (this.x < -this.currentSize) {
					this.x += layer.layerWidth + this.currentSize * 2;
					this.y = Math.random() * layer.layerHeight;
					life = 100;
				} else if (this.x > layer.layerWidth + this.currentSize) {
					this.x -= layer.layerWidth + this.currentSize * 2;
					this.y = Math.random() * layer.layerHeight;
					life = 100;
				} else if (this.y < -this.currentSize) {
					this.y += layer.layerHeight + this.currentSize * 2;
					this.x = Math.random() * layer.layerWidth;
					life = 100;
				} else if (this.y > layer.layerHeight + this.currentSize) {
					this.y -= layer.layerHeight + this.currentSize * 2;
					this.x = Math.random() * layer.layerWidth;
					life = 100;
				} else if (layer.objectLayer && (o = layer.objectLayer.getObjectAt(p, null, false, true)) && o.mover == null) {
					if (type == TYPE_SNOW) {
						type = TYPE_SNOW_LYING;
						life = 3 + Math.random();
					} else if (type == TYPE_RAIN) {
						type = TYPE_RAIN_SPLASH;
						life = 0.15 + Math.random() * 0.1;
						y -= vy * elapsedTime * 1.1;
						vy *= -0.2-Math.random()*0.1;
						vx *= 0.4;
						this.drag = 0.95;
					} else {
						this.y = 0;
						this.x = Math.random() * layer.layerWidth;
						life = 100;
					}
					
				}
			}
			
			switch (type) {
				default:
					this.currentSize = Math.min(this.size, life * 10);
					break;
				case TYPE_SPARK:
					this.currentSize = Math.min(this.size * 0.3, life * 10);
					this.color1 = DrawUtil.lerpColor(0xff0000, 0xffff00, 0.5 + Math.cos(living * 10 + random1 * 7) * 0.35 + Math.cos(living * 25 + random2 * 7) * 0.15);
					this.color1 = DrawUtil.lerpColor(0x000000, color1, MathUtil.clamp(life * 5 - 2 - random1*5, 0, 1));
					this.gy -= elapsedTime * 40;
					this.windEffect += elapsedTime * 100;
					break;
				case TYPE_RAIN_SPLASH:
					if (this.life <= 0) {
						this.type = TYPE_RAIN;
						this.life = 100;
						this.x = Math.random() * layer.layerWidth;
						this.vy += (Math.random() + Math.random()+4) * 30 * (1+data);
						this.y = 0;
						this.drag = 0.98;
					}
					break;
				case TYPE_RAIN:
				case TYPE_SNOW:
					this.currentSize = Math.min(this.size, life * 10);
					break;
				case TYPE_STEAM:
				case TYPE_SMOKE:
					this.currentSize = this.size*Math.min(0.2 + 0.5 * Math.min(living * 8, 3) * living * (random1 * 0.3 + 0.7), (random2 * 0.8) + 0.5);
					this.currentSize = Math.min(this.currentSize, life * this.size);
					if (life < 1) {
						vx *= drag;
						vy *= drag;
					}
					if (gy < 0) gy += elapsedTime * 200;
					
					break;
				case TYPE_FIRE:
					this.currentSize = this.size*Math.min(0.4 + 0.3 * Math.min(living * 8, 3) * living * (random1 * 0.3 + 0.7), (random2 * 0.2) + 0.5);
					this.currentSize = Math.min(this.currentSize, life * this.size * 0.5);
					
					color1 = DrawUtil.lerpColor(0x880000, 0xff0000, MathUtil.clamp(life, 0, 1));
					color2 = DrawUtil.lerpColor(0xff0000, 0xffff00, MathUtil.clamp(life * 0.8 - 0.3, 0, 1));
					
					if (life <= 0) {
						life = 2*(data+1);
						size = (size-5) * 2 * (data + 1);
						if (life > 0 && size > 5) {
							initialize(layer, TYPE_SMOKE, life, size, x-vx*0.4, y-vy*0.4, vx, vy);
						} else {
							life = -1;
						}
					}

					
					break;
			}
			
			if (x < -this.size || x > layer.layerWidth + this.size || y < -this.size || y > layer.layerHeight + this.size) {
				life = 0;
			}
			
			
			
			
			
			
		}
		
		/**
		 * Renders the partice to the screen
		 * @param	graphics	The Graphics object the particle is to be rendered on
		 * @param	camera		The screen's camera
		 */
		public function render(graphics:Graphics, camera:Camera, pass:int = 0):void {
			if (x - camera.left<-currentSize || x-camera.right>currentSize || y-camera.top<-currentSize || y-camera.bottom>currentSize) return;
			var w:Number;
			var h:Number;
			switch (type) {
				default:
					if (pass == 0) {
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left, y - camera.top, this.currentSize);
						graphics.endFill();
					}
					break;
				case TYPE_SNOW:
				case TYPE_SNOW_LYING:
					if (pass == 0) {
						graphics.beginFill(color1);
						DrawUtil.drawRegularPolygon(graphics, x - camera.left, y - camera.top, currentSize, 6, living * random2);
						graphics.endFill();
					}
					break;
				case TYPE_RAIN_SPLASH:
					if (pass == 0) {
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left, y - camera.top, currentSize*0.6);
						graphics.endFill();
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left + vx * 0.06, y - camera.top - vy * 0.06, currentSize*0.5);
						graphics.endFill();
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left - vx * 0.1, y - camera.top + vy * 0.1, currentSize*0.4);
						graphics.endFill();
					}
					break;
				case TYPE_RAIN:
					if (pass == 0) {
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left, y - camera.top, currentSize);
						graphics.endFill();
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left - vx * 0.006, y - camera.top - vy * 0.006, currentSize*0.8);
						graphics.endFill();
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left - vx * 0.01, y - camera.top - vy * 0.01, currentSize*0.6);
						graphics.endFill();
					}
					break;
				case TYPE_SPARK:
					if (pass == 3) {
						graphics.beginFill(color1);
						graphics.drawEllipse(x - camera.left, y - camera.top, this.currentSize*(0.75+0.25*Math.cos(living * (8-random2*4) + random3 * 7)), this.currentSize*(0.75+0.25*Math.cos(living * (4+random2*4) + random1 * 7)));
						graphics.endFill();
					}
					break;
				case TYPE_FIRE:
					if (pass == 0) {
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left, y - camera.top, this.currentSize);
						graphics.endFill();
					}
					if (pass == 1) {
						var s:Number = (this.currentSize * (random3 * 0.2 + 0.5));
						var d:Number = (this.currentSize - s) * 0.4;
						//s *= MathUtil.clamp(living*2+0.2, 0, 1);
						graphics.beginFill(color2);
						graphics.drawCircle(x - camera.left + d *(random1-0.5), y - camera.top+d*(random2-0.5), s);
						//graphics.drawCircle(x - camera.left + d *(random1-0.5), y - camera.top+d*(random2-0.5), s);
						graphics.endFill();
					}
					break;
				case TYPE_STEAM:
				case TYPE_SMOKE:
					if (pass == 0) {
						graphics.beginFill(color1);
						graphics.drawCircle(x - camera.left, y - camera.top, this.currentSize);
						graphics.endFill();
					}
					if (pass == 1) {
						s = (this.currentSize * (random3 * 0.2 + 0.6));
						d = (this.currentSize - s) * 0.8;
						s *= MathUtil.clamp(living*2+0.2, 0, 1);
						graphics.beginFill(color2);
						graphics.drawCircle(x - camera.left + d *(random1-0.5), y - camera.top+d*(random2-0.5), s);
						graphics.endFill();
					}
					if (pass == 2) {
						s = (this.currentSize * (random1 * 0.4 + 0.2));
						d = (this.currentSize - s) * 0.4;
						s *= MathUtil.clamp(living*2-0.5, 0, 1);
						graphics.beginFill(color3);
						graphics.drawCircle(x - camera.left + d *(random2-0.5), y - camera.top+d*(random3-0.5), s);
						graphics.endFill();
					}
					break;
			}
		}
		
	}

}