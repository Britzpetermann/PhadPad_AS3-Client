package com.britzpetermann.phadpad.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;

	[Event(name="start", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="connect", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="disconnect", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="connectError", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="waitAndReconnect", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="close", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	[Event(name="connectSuccess", type="com.britzpetermann.phadpad.core.RemoteConnectionEvent")]
	public class RemoteConnection extends EventDispatcher
	{
		public static const RECONNECT_TIME : Number = 3000;

		[Bindable]
		public var isConnected : Boolean = false;

		[Bindable]
		public var isConnectedOrConnecting : Boolean = false;

		public var oldSockets : Vector.<Socket> = new Vector.<Socket>();

		public var socket : Socket;
		public var inputId : int;

		private var remoteInput : CommandProcessor;
		private var location : String;
		private var port : int;
		private var timer : Timer;
		private var reconnectTimer : Timer;

		public function RemoteConnection()
		{
			timer = new Timer(0);
			timer.addEventListener(TimerEvent.TIMER, getData);
			timer.start();

			reconnectTimer = new Timer(RECONNECT_TIME, 0);
			reconnectTimer.addEventListener(TimerEvent.TIMER, handleReconnectTimer);
		}

		private function handleReconnectTimer(event : TimerEvent) : void
		{
			reconnectTimer.stop();
			reconnect();
		}

		public function setInput(remoteInput : CommandProcessor) : void
		{
			this.remoteInput = remoteInput;
		}

		public function connect(location : String, port : int) : void
		{
			trace("Try to connect...", inputId);

			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.START));

			isConnectedOrConnecting = true;

			this.port = port;
			this.location = location;

			reconnect();
		}

		public function disconnect() : void
		{
			isConnected = false;
			isConnectedOrConnecting = false;

			reconnectTimer.stop();

			dismissSocket();
			removeSocket();
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.DISCONNECT));
		}

		private function removeSocket() : void
		{
			if (socket != null)
			{

				if (socket.connected)
					socket.close();

				socket.removeEventListener(Event.CONNECT, handleConnect);
				socket.removeEventListener(Event.CLOSE, handleClose);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);

				socket = null;
			}
		}

		private function reconnect() : void
		{
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.CONNECT));
			trace("reconnect", inputId);

			removeSocket();

			try
			{
				// Security.loadPolicyFile("xmlsocket://" + location + ":" + port);
				socket = new Socket();
				socket.timeout = 5000;
				socket.endian = Endian.LITTLE_ENDIAN;
				socket.addEventListener(Event.CONNECT, handleConnect);
				socket.addEventListener(Event.CLOSE, handleClose);
				socket.addEventListener(IOErrorEvent.IO_ERROR, handleError);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
				socket.connect(location, port);
			}
			catch(error : Error)
			{
				waitAndReconnect();
			}
		}

		private function waitAndReconnect() : void
		{
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.WAIT_AND_RECONNECT));
			reconnectTimer.reset();
			reconnectTimer.start();
		}

		private function getData(event : TimerEvent) : void
		{
			if (socket != null && socket.connected)
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
			trace("io error...");

			isConnected = false;

			dismissSocket();

			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.CONNECT_ERROR));
			waitAndReconnect();
		}

		private function dismissSocket() : void
		{
			socket.removeEventListener(IOErrorEvent.IO_ERROR, handleError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);

			socket.addEventListener(IOErrorEvent.IO_ERROR, handleDismissedIOError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleDismissedSecurityError);

			oldSockets.push(socket);
		}

		private function handleDismissedSecurityError(event : SecurityErrorEvent) : void
		{
			trace("handleDismissedSecurityError");
		}

		private function handleDismissedIOError(event : IOErrorEvent) : void
		{
			trace("handleDismissedIOError");
		}

		private function handleClose(event : Event) : void
		{
			isConnected = false;
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.CLOSE));
			waitAndReconnect();
		}

		private function handleSecurityError(event : SecurityErrorEvent) : void
		{
			trace("security error...", event.text);
			dismissSocket();

			isConnected = false;
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.CONNECT_ERROR));
			waitAndReconnect();
		}

		private function handleConnect(event : Event) : void
		{
			trace("Connection success!", inputId);
			dispatchEvent(new RemoteConnectionEvent(RemoteConnectionEvent.CONNECT_SUCCESS));
			isConnected = true;
		}
	}
}
