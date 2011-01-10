package com.britzpetermann.phadpad.core
{
	import flash.events.Event;

	public class RemoteConnectionEvent extends Event
	{
		public static const START : String = "start";
		public static const DISCONNECT : String = "disconnect";
		public static const CONNECT : String = "connect";
		public static const CONNECT_ERROR : String = "connectError";
		public static const WAIT_AND_RECONNECT : String = "waitAndReconnect";
		public static const CLOSE : String = "close";
		public static const CONNECT_SUCCESS : String = "connectSuccess";
		
		public function RemoteConnectionEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
