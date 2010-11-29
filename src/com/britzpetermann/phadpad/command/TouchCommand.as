package com.britzpetermann.phadpad.command
{
	import com.britzpetermann.phadpad.core.RemoteCommand;

	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	public class TouchCommand extends EventDispatcher implements RemoteCommand
	{
		protected var eventType : String;

		public function execute(inputId : int, stream : ByteArray) : void
		{
			var touch : Touch = createTouch(stream);
			dispatchEvent(new TouchEvent(eventType, inputId, touch));
		}

		protected function createTouch(stream : ByteArray) : Touch
		{
			var result : Touch = new Touch();

			result.x = stream.readFloat();
			result.y = stream.readFloat();
			result.id = stream.readInt();

			return result;
		}

		public function listen(listener : Function) : RemoteCommand
		{
			addEventListener(eventType, listener);
			return this;
		}
	}
}
