package example1
{

	import mx.controls.Alert;
	import flash.display.LoaderInfo;

	import com.britzpetermann.phadpad.command.AccelerationCommand;
	import com.britzpetermann.phadpad.command.AccelerationEvent;
	import com.britzpetermann.phadpad.command.Touch;
	import com.britzpetermann.phadpad.command.TouchBeginCommand;
	import com.britzpetermann.phadpad.command.TouchEndCommand;
	import com.britzpetermann.phadpad.command.TouchEvent;
	import com.britzpetermann.phadpad.command.TouchMoveCommand;
	import com.britzpetermann.phadpad.core.CommandProcessor;
	import com.britzpetermann.phadpad.core.RemoteConnection;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class PhadpadFacade
	{
		[Bindable]
		public var phadpadAddress : String = "192.168.2.110";

		[Bindable]
		public var accelerationX : Number = 0;
		
		[Bindable]
		public var accelerationY : Number = 0;
		
		[Bindable]
		public var accelerationZ : Number = 0;

		[Bindable]
		public var remoteConnection : RemoteConnection;
		
		public var sprite : Sprite;

		private var commandProcessor : CommandProcessor;
		private var bitmapData : BitmapData;

		public function init() : void
		{
			commandProcessor = new CommandProcessor();
			commandProcessor.addCommand(1, new TouchBeginCommand().listen(handleTouchBegin));
			commandProcessor.addCommand(2, new TouchMoveCommand().listen(handleTouchMove));
			commandProcessor.addCommand(3, new TouchEndCommand().listen(handleTouchEnd));
			commandProcessor.addCommand(5, new AccelerationCommand().listen(handleAcceleration));

			remoteConnection = new RemoteConnection();
			remoteConnection.setInput(commandProcessor);

			bitmapData = new BitmapData(1024, 768, true, 0xffffffff);
			sprite.addChild(new Bitmap(bitmapData));
		}

		public function connect() : void
		{
			remoteConnection.inputId = 0;
			remoteConnection.connect(phadpadAddress, 4446);
		}

		public function disconnect() : void
		{
			remoteConnection.disconnect();
		}

		public function sendImage() : void
		{
			if (remoteConnection.socket != null && remoteConnection.socket.connected)
			{
				var bytes : ByteArray = bitmapData.getPixels(new Rectangle(0, 0, 1024, 768));
				remoteConnection.socket.writeBytes(bytes, 0, bytes.length);
				remoteConnection.socket.flush();
			}
			else
			{
				Alert.show("You are not connected...", "Cound not send image!");
			}
		}

		private function handleTouchBegin(event : TouchEvent) : void
		{
			drawTouch(event.touch, 10);
		}

		private function handleTouchMove(event : TouchEvent) : void
		{
			drawTouch(event.touch, 5);
		}

		private function handleTouchEnd(event : TouchEvent) : void
		{
			drawTouch(event.touch, 20);
		}

		private function handleAcceleration(event : AccelerationEvent) : void
		{
			accelerationX = event.acceleration.x;
			accelerationY = event.acceleration.y;
			accelerationZ = event.acceleration.z;
		}

		private function drawTouch(touch : Touch, radius : Number) : void
		{
			var x : Number = touch.x * 1024;
			var y : Number = touch.y * 768;

			var brush : Shape = new Shape();
			brush.graphics.lineStyle(3, touch.id);
			brush.graphics.drawCircle(0, 0, radius);

			var matrix : Matrix = new Matrix();
			matrix.translate(x, y);

			bitmapData.draw(brush, matrix);
		}
	}
}
