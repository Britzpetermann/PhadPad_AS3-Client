package com.britzpetermann.phadpad.command
{
	import flash.events.Event;

	public class InputEvent extends Event
	{
		public var inputId : int;

		public function InputEvent(type : String, inputId : int, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.inputId = inputId;
		}
	}
}
