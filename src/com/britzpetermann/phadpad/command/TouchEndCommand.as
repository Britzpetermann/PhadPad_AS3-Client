package com.britzpetermann.phadpad.command
{

	[Event(name="end", type="com.britzpetermann.phadpad.command.TouchEvent")]
	public class TouchEndCommand extends TouchCommand
	{
		public function TouchEndCommand()
		{
			eventType = TouchEvent.END;
		}
	}
}
