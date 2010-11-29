package com.britzpetermann.phadpad.command
{

	public class TouchEvent extends InputEvent
	{
		public static const BEGIN : String = "begin";
		public static const MOVE : String = "move";
		public static const END : String = "end";

		public var touch : Touch;

		public function TouchEvent(type : String, inputId : int, touch : Touch, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, inputId, bubbles, cancelable);
			this.touch = touch;
		}
	}
}
