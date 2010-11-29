package com.britzpetermann.phadpad.command
{
	import flash.geom.Vector3D;

	public class AccelerationEvent extends InputEvent
	{
		public static const ACCELERATION : String = "acceleration";
		public var acceleration : Vector3D;

		public function AccelerationEvent(inputId : int, acceleration : Vector3D, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(ACCELERATION, inputId, bubbles, cancelable);
			this.acceleration = acceleration;
		}
	}
}
