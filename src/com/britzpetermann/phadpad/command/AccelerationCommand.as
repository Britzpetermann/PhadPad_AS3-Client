package com.britzpetermann.phadpad.command
{
	import com.britzpetermann.phadpad.core.RemoteCommand;

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;

	[Event(name="acceleration", type="com.britzpetermann.phadpad.command.AccelerationEvent")]
	public class AccelerationCommand extends EventDispatcher implements RemoteCommand
	{
		public function execute(inputId : int, stream : ByteArray) : void
		{
			var touch : Vector3D = createTouch(stream);
			dispatchEvent(new AccelerationEvent(inputId, touch));
		}

		protected function createTouch(stream : ByteArray) : Vector3D
		{
			var result : Vector3D = new Vector3D();

			result.x = stream.readFloat();
			result.y = stream.readFloat();
			result.z = stream.readFloat();

			return result;
		}

		public function listen(listener : Function) : RemoteCommand
		{
			addEventListener(AccelerationEvent.ACCELERATION, listener);
			return this;
		}
	}
}
