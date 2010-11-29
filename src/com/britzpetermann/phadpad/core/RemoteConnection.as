package com.britzpetermann.phadpad.core
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	public class RemoteConnection
	{
		public static const RECONNECT_TIME : Number = 3000;

		public var socket : Socket;
		public var inputId : int;

		private var remoteInput : CommandProcessor;
		private var location : String;
		private var port : int;
		private var timer : Timer;

		public function RemoteConnection()
		{
			timer = new Timer(0);
			timer.addEventListener(TimerEvent.TIMER, getData);
			timer.start();
		}

		public function setInput(remoteInput : CommandProcessor) : void
		{
			this.remoteInput = remoteInput;
		}

		public function catchErrors(loaderInfo : LoaderInfo) : void
		{
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrors);
		}

		public function connect(location : String, port : int) : void
		{
			trace("Try to connect...", inputId);

			this.port = port;
			this.location = location;

			reconnect();
		}

		private function reconnect() : void
		{
			trace("reconnect", inputId);
			if (socket != null)
			{
				if (socket.connected)
					socket.close();

				socket.removeEventListener(Event.CONNECT, handleConnect);
				socket.removeEventListener(Event.CLOSE, handleClose);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			}

			try
			{
				socket = new Socket();
				socket.endian = Endian.LITTLE_ENDIAN;
				socket.addEventListener(Event.CONNECT, handleConnect);
				socket.addEventListener(Event.CLOSE, handleClose);
				socket.addEventListener(IOErrorEvent.IO_ERROR, handleError);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
				socket.connect(location, port);
			}
			catch(error : Error)
			{
				setTimeout(reconnect, RECONNECT_TIME);
			}
		}

		private function getData(event : TimerEvent) : void
		{
			if (socket.connected)
				handleData(null);
		}

		private function handleData(event : ProgressEvent) : void
		{
			try
			{
				while (socket.bytesAvailable > 0)
				{
					var command : int = socket.readByte();
					var length : int = socket.readInt();

					var ba : ByteArray = new ByteArray();
					ba.endian = Endian.LITTLE_ENDIAN;
					socket.readBytes(ba, 0, length);

					remoteInput.process(inputId, command, ba);
				}
			}
			catch(error : Error)
			{
				trace("Protocoll error: ", inputId, error.getStackTrace());
			}
		}

		private function handleError(event : IOErrorEvent) : void
		{
			// trace("Could not connect to ", event.text);

			setTimeout(reconnect, RECONNECT_TIME);
		}

		private function handleClose(event : Event) : void
		{
			reconnect();
		}

		private function handleSecurityError(event : SecurityErrorEvent) : void
		{
			trace("Security Error...", inputId, event.text);
			setTimeout(reconnect, RECONNECT_TIME);
		}

		private function handleConnect(event : Event) : void
		{
			trace("Connection success!", inputId);
		}

		private function handleUncaughtErrors(event : UncaughtErrorEvent) : void
		{
			if (event.error is SecurityErrorEvent)
			{
				event.preventDefault();
			}
		}
	}
}
